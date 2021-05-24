locals {
  common_tags = {
    Owner = var.owner
    Environment = var.environment
  }

  s3_bucket_name = "${var.bucket_name_prefix}-${var.environment}-${random_integer.rand.result}"
}
#Random ID
resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

# NETWORKING #
# Creating a VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.network_address_space

  tags = merge(local.common_tags, { Name = "${var.environment}-vpc" })

}
# Creating an Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(local.common_tags, { Name = "${var.environment}-igw" })

}
# Creating subnet
resource "aws_subnet" "subnet" {
  count                   = var.subnet_count
  cidr_block              = cidrsubnet(var.network_address_space, 8, count.index)
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = merge(local.common_tags, { Name = "${var.environment}-subnet${count.index + 1}" })

}

# ROUTING #
# Creating a route table
resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-rtb" })
}
# Associating the route table with the subnet
resource "aws_route_table_association" "rta-subnet" {
  count          = var.subnet_count
  subnet_id      = aws_subnet.subnet[count.index].id
  route_table_id = aws_route_table.rtb.id
}

# SECURITY GROUPS #
resource "aws_security_group" "elb-sg" {
  name   = "nginx_elb_sg"
  vpc_id = aws_vpc.vpc.id

  #Allow HTTP from anywhere
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #allow all outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-elb-sg" })
}

# Nginx security group 
resource "aws_security_group" "nginx-sg" {
  name   = "nginx_sg"
  vpc_id = aws_vpc.vpc.id

  # SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from the VPC
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.network_address_space]
  }

  # outbound internet access
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-nginx-sg" })
}

# LOAD BALANCER #
resource "aws_elb" "web" {
  name = "nginx-elb"

  subnets         = aws_subnet.subnet[*].id
  security_groups = [aws_security_group.elb-sg.id]
  instances       = aws_instance.nginx[*].id

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-elb" })
}

# INSTANCES #
resource "aws_instance" "nginx" {
  count                  = var.instance_count
  ami                    = data.aws_ami.aws-linux.id
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.subnet[count.index % var.subnet_count].id
  vpc_security_group_ids = [aws_security_group.nginx-sg.id]
  key_name               = var.key_name
  iam_instance_profile   = aws_iam_instance_profile.nginx_profile.name
  depends_on             = [aws_iam_role_policy.allow_s3_all]

  connection {
    type        = "ssh"
    host        = self.public_ip
    user        = "ec2-user"
    private_key = file(var.private_key_path)

  }

  provisioner "file" {
    content = <<EOF
access_key =
secret_key =
security_token =
use_https = True
bucket_location = US
EOF
    destination = "/home/ec2-user/.s3cfg"
  }

  provisioner "file" {
    content = <<EOF
/var/log/nginx/*log {
    daily
    rotate 10
    missingok
    compress
    sharedscripts
    postrotate
    endscript
    lastaction
        INSTANCE_ID=`curl --silent http://169.254.169.254/latest/meta-data/instance-id`
        sudo /usr/local/bin/s3cmd sync --config=/home/ec2-user/.s3cfg /var/log/nginx/ s3://${aws_s3_bucket.web_bucket.id}/nginx/$INSTANCE_ID/
    endscript
}
EOF

    destination = "/home/ec2-user/nginx"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install nginx -y",
      "sudo service nginx start",
      "sudo cp /home/ec2-user/.s3cfg /root/.s3cfg",
      "sudo cp /home/ec2-user/nginx /etc/logrotate.d/nginx",
      "sudo pip install s3cmd",
      "s3cmd get s3://${aws_s3_bucket.web_bucket.id}/website/index.html .",
      "s3cmd get s3://${aws_s3_bucket.web_bucket.id}/website/Ingo.png .",
      "sudo rm /usr/share/nginx/html/index.html",
      "sudo cp /home/ec2-user/index.html /usr/share/nginx/html/index.html",
      "sudo cp /home/ec2-user/Ingo.png /usr/share/nginx/html/Ingo.png",
      "sudo logrotate -f /etc/logrotate.conf"
      
    ]
  }

  tags = merge(local.common_tags, { Name = "${var.environment}-nginx${count.index + 1}" })
}

# S3 Bucket config#
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name
}

resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
                "arn:aws:s3:::${local.s3_bucket_name}",
                "arn:aws:s3:::${local.s3_bucket_name}/*"
            ]
    }
  ]
}
EOF

  }

  resource "aws_s3_bucket" "web_bucket" {
    bucket        = local.s3_bucket_name
    acl           = "private"
    force_destroy = true

    tags = merge(local.common_tags, { Name = "${var.environment}-web-bucket" })

  }

  resource "aws_s3_bucket_object" "website" {
    bucket = aws_s3_bucket.web_bucket.bucket
    key    = "/website/index.html"
    source = "./index.html"

  }

  resource "aws_s3_bucket_object" "graphic" {
    bucket = aws_s3_bucket.web_bucket.bucket
    key    = "/website/Ingo.png"
    source = "./Ingo.png"

  }

  # Azure RM DNS #
  # Creating a CNAME record. 
  resource "azurerm_dns_cname_record" "elb" {
    name                = "${var.environment}-website"
    zone_name           = var.dns_zone_name
    resource_group_name = var.dns_resource_group
    ttl                 = "30"
    # DNS record name
    record              = aws_elb.web.dns_name
    provider            = azurerm.arm-1

    tags = merge(local.common_tags, { Name = "${var.environment}-website" })
  }
