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
## Working with Multiple Environments
We can easily work in multiple environments. Our environments are going to have more in common than the differences between them. Development will be very close to UAT, and everything that we test or validate in UAT would be very close to production. It also means that it is very important to have some abstaction in our configurations, in which we can apply different values and make our code more reusable. One of the ways to create multiple environments in terraform is using some functionality called Terraform Workspaces.  
### Decisions you have to make while working with multiple environments
**1. State Management:** Where is your state going to be stored and how will the state of each environment will be managed individually?  
**2. Variables Data:** Where to store your variable's data?  
**3. Credentials Management:** You are not necessarily going to use the same credentials for all three environments. How will the credentials for each environment be managed individually and where will they be stored?  
**4. Complexity and Overhead:** There is a balance to be struck between the complexity of our configuration and the amount of administrative overhead there is to maintain the configuration. So you could go with something that is relatively simple, but requires a significant amount of administrative overhead going forward, or make something that's fairly complex but also dynamic and robust so when you want to add or edit an environment, there is not a whole lot of administrative overhead to do so.   
  
**Example to maintain state file of different environments**
![Example](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module5:Terraform-Workspaces/Example.png)  
  
```bash 
terraform plan -state=".\dev\dev.state"
            -var-file="common.tfvars"
            -var-file=".\dev\dev.tfvars"  
```
## Terraform Workspaces
Another potential way to maintain different environments is via workspace. In workspaces, we still have a primary directory where our main config and terraform.tfvars exist. Workspace will manage the state for us. It creates a terraform.tfstate.d directory and places the state file in child directories within that main directory.  
 ![Worspace](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module5:Terraform-Workspaces/Workspace.png)  

When we want to create a new workspace, we can simply run: 
```bash 
terraform workspace new develop
```  
Terraform will create that workspace and switch over to that context. Then we can run  
```bash
terraform plan
```    
using our main config and the terraform.tfvars. Rather than manually managing the states, terraform will manage the state for us.  
  
## Commands used
```bash
terraform init
terraform workspace new Development
terraform plan
terraform apply

terraform destroy

terraform workspace new UAT
terraform plan
terraform apply

terraform destroy

terraform workspace new Production
terraform plan
terraform apply

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