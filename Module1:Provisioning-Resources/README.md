## Provisioning Resources
In this module, we will learn to deploy and configure the basic resources using Terraform

### Scenario:
Provision a development environment to turn an existing product to a SAAS product.
Application info: 
2-tier application:
 > web front,
 > database backend,
 > Public DNS record.
Cloud: AWS

### Terraform Components
1. Terraform Executable: It is self-contained, written in GO, and available for any operating system. 
2. Terraform Files: Terraform stiches the contents of the terraform files to form a suitable architecture.
3. Terraform Plugins: Terraform makes use of plugins to interact with providers.
4. State File: It stores the current state of the configuration in it. Anytime a change is requested, terraform compares the new state with the existing state and makes the changes accordingly.

### Terraform Files
#### Variable:
Terraform provides you with the ability to define variables to store important information.
#### Provider:
It consist of the information related to the provider we are trying to create our in. For example: aws.
#### Data:
Once we have connected to the provider, we may want to get some information about the resources that exist in that provider. For instance, in AWS, we may want to get a list of all the AMIs for a particular region that we are using. For that, we use a data source. Once we have defined a provider, we can then ask for the information via a data source about that provider. Nother good example would be availability zones in AWS.
#### Resource:
We would want to create several resources according to our use case. For that we use resource. A resource takes several arguments and those arguments can either be hard coded or passed as a variable or a data source.
#### Output:
You might want to get some information out of your deployment. For example, a public IP  of your server. In Terraform, outputs serve that function admirably.