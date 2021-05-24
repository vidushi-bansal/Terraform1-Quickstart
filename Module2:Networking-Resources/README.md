# Scenario
Creating a VPC with 2 subnets in different availability zones. Launch one EC2 instance in each of the subnets. Above those instances, add an elastic load balancer to load balance the traffic between the two instances and a public DNS record associated with the Load Balancer. That way, if something happens to one of the instances or the availability zones, our application remains unaffected.

The image below represents the above mentioned scenario  
![Scenario](https://github.com/vidushi-bansal/Terraform1-Quickstart/blob/main/Module2:Networking-Resources/Scenario.png)

### Resources Created:
VPC
Internet Gateway
Subnets
Route Tables
Route Table Asssociation
Security Groups
Load Balancer
EC2 Instances