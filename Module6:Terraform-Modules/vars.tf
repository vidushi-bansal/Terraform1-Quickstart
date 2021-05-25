variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "private_key_path" {}
variable "key_name" {}
variable "owner" {}
variable "region" {
  default = "us-east-1"
}
# IP address range that we use to construct our VPC
variable network_address_space {
  type = map(string)
}
variable "instance_size" {
  type = map(string)
}
variable "subnet_count" {
  type = map(number)
}
variable "instance_count" {
  type = map(number)
}
variable "bucket_name_prefix" {}
locals {
  #We are extracting the value of environment name from terraform.workspace
  env_name = lower(terraform.workspace)

  common_tags = {
    Owner = var.owner
    Environment = local.env_name
  }

  s3_bucket_name = "${var.bucket_name_prefix}-${local.env_name}-${random_integer.rand.result}"
}