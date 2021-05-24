variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "region" {
  default = "us-east-1"
}

variable "network_address_space" {
  default = "10.1.0.0/16"
}

variable "billing_code_tag" {}
variable "environment_tag" {}
variable "bucket_name_prefix" {}

variable "arm_subscription_id" {}
variable "arm_principal" {}
variable "arm_password" {}
variable "tenant_id" {}
variable "dns_zone_name" {}
variable "dns_resource_group" {}

variable "instance_count" {
  default = 2
}

variable "subnet_count" {
  default = 2
}