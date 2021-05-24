# Scenario
Creating a VPC with 2 subnets in different availability zones. Launch two EC2 instances in each of the subnets. Above those instances, add an elastic load balancer to load balance the traffic between the four instances and a public DNS record associated with the Load Balancer. That way, if something happens to one of the instances or the availability zones, our application remains unaffected.
Introduce an S3 bucket, containing the website data, into the configuration.
EC2 instances should communicate with the S3 bucket to get the website information and publish it out.
Take the logs generated in the web servers and store them for long term retention and analysis in that same S3 bucket.
In order to do that, the four EC2 instances should have the permissions to access(both, read and write) the S3 bucket.  
Using Multiple Environments:  
We want to use 3 environments for our scenario: Development, QA/UAT and Production.  
Each environment might have slighlty different configurations. We take each configuration for the environment, feed that into Terraform, and that in turn deploys that environment in AWS.  
The image below represents the above mentioned scenario:  
![Scenario](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module5:Terraform-Workspaces/Scenario.png)

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

## Using variables to distinguish the environments
**1. Defining Variables:** We can use the variables to differenciate the environment in our use-case as follows:
```
# Specify default variable types
variable "environment" {
    type = string
    default = "development"
}
# Specify variable in a file
environment = "uat"

# Specify variable as in-line argument
terraform apply -var "environment=production" 

```
**2. Using Variables** 

```
# Create variable map
variable "cidr" {
    type = map(string)
    default = {
        development = "10.0.0.0/16"
        uat = "10.1.0.0/16"
        producation = "10.2.0.0/16" 
    }
}
# Use map based on environment
cidr_block = lookup(var.cidr, var.environment)
```
