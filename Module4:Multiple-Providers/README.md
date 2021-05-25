# Scenario
Creating a VPC with 2 subnets in different availability zones. Launch two EC2 instances in each of the subnets. Above those instances, add an elastic load balancer to load balance the traffic between the four instances and a public DNS record associated with the Load Balancer. That way, if something happens to one of the instances or the availability zones, our application remains unaffected.
Introduce an S3 bucket, containing the website data, into the configuration.
EC2 instances should communicate with the S3 bucket to get the website information and publish it out.
Take the logs generated in the web servers and store them for long term retention and analysis in that same S3 bucket.
In order to do that, the four EC2 instances should have the permissions to access(both, read and write) the S3 bucket.  
The DNS of load balancer should be mapped with an official website name (webstie.xyz) 
This zone happens to be hosted in Microsoft Azure.  
Leverage Microsoft Azure provider to dynamically add entries to the website's zone.   
The image below represents the above mentioned scenario:  
![Scenario](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module4:Multiple-Providers/Scenario.png)

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
Azure RM

## Terraform Functions
Terraform has a sub command called **terraform console**, that opens an interpretation console, where you can have terraform evaluate functions and other expressions to see what it pops out.
### Common function categories:
#### Numeric
Functions to manipulate numbers. For example, to get the minimum number from a list of numbers, use:  
min(23,89,32,13)  
#### String
Functions to manipulate string. For example, to convert an uppercase string to lowercase string, use:  
lower(NAME)
#### Collection
Functions to manipulate lists and maps. For example, to merge two maps, use:  
merge(map1,map2)
#### FileSystem
Functions to manipulate with the file system. For example, to read the contents of the file, use: 
file(path)
#### IP Network
Dedicated fucntions for IP Networking. For example, to get the subnet from a large network range, use:  
cidrsubnet()
#### Date and Time
Functions to return the date and time. For example, to date and timestamp things, use:  
timestamp()

#### Example of a Terraformm function
1. To manage networking, if we need to break network range into subnets, we can use the cidrsubnet function in terraform.  
```
variable network_info{  
  default = "10.1.0.0/16"  
}  
cidr_block = cidrsubnet(varr.network_info,8,0)  
```
The function **cidrsubnet** takes:  
first argument as the network range,  
second argument is add this number of bits to the mask so the 16 turns to 24,    
third argument is based off breaking the large network address into bunch of subnets, which subnet is required.  
  
2. To lookup values in a map  
Lets create a map of AMIs  
```
variable "amis" {
  type = "map"
  default = {
      us-east-1 = "ami1"
      us-west-1 = "ami2"
  }
}
ami = lookup(var.amis, "us-east-1", error)  
```
  
We can use the **lookup** function to retrieve the value from a map. The third argument of lookup is a default value, if it does not find that key within a map.
  
## Terraform Console
Type in **terraform console** in a terraform initated directory.  
terraform console    
> min(23,89,32,13)  
  
## Terraform Providers
Terraform providers allows you to interact with things like infrastructure as a service, platform as a service, or even software as a service. Providers are a collection of defined resources and data sources. We can create multiple instances of the same provider in our configuration.
### Example:
```
provider "azurem" {
   subscription_id = "subscription-id-1" 
   client_id = "principal used for access"
   client_secret = "password of the principal"
   tenant_id = "tenant-id"
   alias = "arm-1"
}
provider "azurem" {
   subscription_id = "subscription-id-2" 
   client_id = "principal used for access"
   client_secret = "password of the principal"
   tenant_id = "tenant-id"
   alias = "arm-2"
}
resource "azurerm_resource_group" "azure_example" {
    name = "resource-group"
    location = "East US"
    provider = azurerm.arm1
}
```
  
## Resource Arguments
There are a number of different arguments you can specify within a resource that help you with more complex complications.  
1. **depends_on:** You can add a depends_on argument and then give a list of other resources that this resource is dependent on to make sure that Terraform creates things in the right order. Terraform creates things in the right order.  
2. **count:** Count is a way to implement a resource loop within Terraform configurations.  
3. **for_each:** You submit a map with a list of key-value pairs, and for each key-value pair within that map, it will create one of the resources.  
4. **provider:** There is a provider argument where you can specify which provider should be used for the creation of this resource if its not obvious to Terraform already.  
  
### Example
```
resource "aws_instance" "instance_example" {
  count = 2
  tags {
    Name = "customer=${count.index}"
  }
  depends_on = [aws_iam_role_policy.allow_S3]
}
resource "aws_s3_bucket" "s3_bucket" {
  for each = {
    public_bucket = "public"
    private_bucket = "private"
  }
  bucket = "${each.key}-${var.bucket_suffix}"
  acl = each.value

}
```
## Commands used
```bash
terraform init
terraform plan -out file.tfplan
terraform apply "file.tfplan"
```