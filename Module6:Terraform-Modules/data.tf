data "aws_availability_zones" "available" {}

data "aws_ami" "aws-linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}
#template file creates a text string based off of a template that we give it
# Here, we need a certain number of subnet IP address spaces.
#So we are going to feed it the subnet count for our workspace and then the template is invoking the CIDR subnet function,
# handing it the vpc_cidr address space, the bis that we want to add to that, and the current count of the loop that we're
# going through in this template file.
data "template_file" "public_cidrsubnet" {
  count = var.subnet_count[terraform.workspace]

  template = "$${cidrsubnet(vpc_cidr,8,current_count)}"

  vars = {
    vpc_cidr      = var.network_address_space[terraform.workspace]
    current_count = count.index
  }
}
