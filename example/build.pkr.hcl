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

locals {
  ami_create      = "packer-${var.name}"
  ami_description = "Amazon Linux 2 Hardened Example"
  ami_name        = "${var.name}-${timestamp()}"
}

source "amazon-ebs" "linux" {
  region           = var.region
  source_ami_filter {
    filters = {
      name                = var.source_ami_name
      virtualization-type = "hvm"
      root-device-type    = "ebs"
    }
    most_recent = true
    owners      = ["amazon"]
  }
  instance_type      = var.instance_type
  subnet_id          = var.subnet_id
  security_group_id  = var.security_group_id
  ami_name           = local.ami_name
  ami_description    = local.ami_description
  ami_users          = var.ami_users
  ssh_username       = "ec2-user"
}

build {
  name    = "build-amazon-linux"
  sources = ["source.amazon-ebs.linux"]
}
