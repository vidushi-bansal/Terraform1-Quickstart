# Scenario
Creating a VPC with 2 subnets in different availability zones. Launch two EC2 instances in each of the subnets. Above those instances, add an elastic load balancer to load balance the traffic between the four instances and a public DNS record associated with the Load Balancer. That way, if something happens to one of the instances or the availability zones, our application remains unaffected.
Introduce an S3 bucket, containing the website data, into the configuration.
EC2 instances should communicate with the S3 bucket to get the website information and publish it out.
Take the logs generated in the web servers and store them for long term retention and analysis in that same S3 bucket.
In order to do that, the four EC2 instances should have the permissions to access(both, read and write) the S3 bucket.  
Using Multiple Environments:  
We want to use 3 environments for our scenario: Development, QA/UAT and Production.  
Each environment might have slighlty different configurations. We take each configuration for the environment, feed that into Terraform, and that in turn deploys that environment in AWS. 

There are multiple applications being built by several teams. All of these applications have one thing in common. They are all based off of a VPC. That VPC has subnets, internet gateway, routing configurations for the application in it. We need to take all these components and bundle them into a single module for VPC. In addition to the VPC, many of the applications have the smae requirement to create an instance profile and allow EC2 instances to access S3 buckets. So we can also create an S3 module that does this work for us.  
The image below represents the above mentioned scenario:  
![Scenario](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module6:Terraform-Modules/Scenario.png)

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

## Terraform Modules
One of the core principals of infrastructure as a code is the ability to create reusable components that you can reuse over and over in multiple different configurations. Its that sort of abstraction that helps make your life a little bit better. We will be using Terraform Modules to make code reuse easier. Modules cpntain outputs, and there is a whole process flow by which we can consume modules or create them. Contents of the module can be remote or stored locally. For remote, terraform actually has a public facing registry of modules already available, and we can add our module to that collection or try to find one that fits our needs.  
### Example of an S3 module in terrform:
**Creating an S3 module**  
```
variable "name" {}
resource "aws_s3_bucket" "bucket"{
    name = var.name
    [...]
}

ouput "bucket_id"{
    value = aws_s3_bucket.bucket.id
}
```  
**Calling the S3 module**  
```
#Create module bucket
module "bucket"{
    name   = "my-bucket"
    source = ".\\Modules\\s3
}
#Use bucket
resource "aws_s3_bucket_object" {
    bucket = module.bucket.buckt_id
    [...]
} 
```  
## Commands used
```bash
terraform init
terraform workspace new Development
terraform plan -out file.tfplan
terraform apply "file.tfplan"

terraform destroy

terraform workspace new UAT
terraform plan -out file.tfplan
terraform apply "file.tfplan"

terraform destroy

terraform workspace new Production
terraform plan -out file.tfplan
terraform apply "file.tfplan"

terraform destroy 
```
To switch to other workspace    
```bash
terraform workspace select <WORKSPACE-NAME>
```
To delete a worspace:  
(You will have to switch to the other workspace to delete the current workspace)  
```bash
terraform workspace delete <WORKSPACE-NAME>
```