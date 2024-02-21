variable "OS_Name" {
  type    = string
  default = "Ubuntu"
}

variable "OS_Version" {
  type    = string
}

variable "name" {
  type    = string
  default = "ubuntu-example"
}

variable "instance_type" {
  type        = string
  description = "AWS instance type"
}

variable "region" {
  type        = string
  description = "AWS region"
}

variable "source_ami_name" {
  description = "The AMI name to filter for."
  type = string
}

variable "subnet_id" {
  type        = string
  description = "The subnet ID to launch the instance in."
}

locals {
  ami_create      = "packer ${var.name}"
  ami_description = "Ubuntu Example"
  ami_name        = "${var.name}-{{timestamp}}"
}