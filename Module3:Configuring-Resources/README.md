# Scenario
Creating a VPC with 2 subnets in different availability zones. Launch one EC2 instance in each of the subnets. Above those instances, add an elastic load balancer to load balance the traffic between the two instances and a public DNS record associated with the Load Balancer. That way, if something happens to one of the instances or the availability zones, our application remains unaffected.
Introduce an S3 bucket, containing the website data, into the configuration.
EC2 instances should communicate with the S3 bucket to get the website information and publish it out.
Take the logs generated in the web servers and store them for long term retention and analysis in that same S3 bucket.
In order to do that, the two EC2 instances should have the permissions to access(both, read and write) the S3 bucket.  

The image below represents the above mentioned scenario:  
![Scenario](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module3:Configuring-Resources/Scenario.png)

### Resources Created:
VPC  
Internet Gateway  
Subnets  
Route Tables  
Route Table Asssociation  
Security Groups  
Load Balancer  
EC2 Instances  
S3 Bucket

## Provisioners  
Provisioners in Terraform are used to do post-deployment configurations.    
Provisioners can be local, that executes on your local machine, or remote, that executes on the remote instance that it's configured for.  
Provisioners can fire off either during creation(for example, to run a script or add some files to your ec2 instances), or destruction of an object( for example, graceful termination of the processes).  
We can add multiple provisioners to a particular resource.  
### Example:  
**Get files from your local machine to a remote resource thats being created.**  
  
provisioner "file"{  
  connection {  
    type = "ssh"  
    user = "root"  
    private_key = var.private_key  
    host = var.hostname  
  }  
  source = "/local/path/to/file.txt"  
  destination = "/path/to/file.txt"  
}  
  
**Local Exec Provisioner:**  
  
provisioner "local-exec"{  
  command = "local command here"  
}  
  
**Remote Exec Provisioner:**  
  
provisioner "local-exec"{  
  script = ["list" , "of" ,"remote" , "scripts"]    
}  