variable "name" {
  type    = string
  default = "ubuntu-example"
}

variable "instance_type" {
  type        = string
  description = "AWS instance type"
  default     = "t2.micro"
}

variable "region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

variable "source_ami" {
  type        = string
  description = "AWS source AMI"
  default     = "ami-0a313d6098716f372"
}

variable "subnet_id" {
  type        = string
  description = "AWS subnet ID"
}

locals {
  ami_create      = "packer ${var.name}"
  ami_description = "Ubuntu Example"
  ami_name        = "${var.name}-{{timestamp}}"
}