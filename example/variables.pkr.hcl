variable "region" {}
variable "source_ami_name" {}
variable "instance_type" {}
variable "ami_users" {
  type    = list(string)
  default = []
}
variable "subnet_id" {}
variable "security_group_id" {}
variable "name" {}
variable "OS_Name" {}
variable "OS_Version" {}
