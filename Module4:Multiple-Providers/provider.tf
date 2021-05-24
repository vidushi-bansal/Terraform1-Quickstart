provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.region
}

provider "azurerm" {
  subscription_id = var.arm_subscription_id
  client_id       = var.arm_principal
  client_secret   = var.arm_password
  tenant_id       = var.tenant_id
  alias           = "arm-1"
  
  #Added when using service principal with limited permissions
  skip_provider_registration = true

  #Required for version 2.0 of provider
  features {}
}