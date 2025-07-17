packer {
  required_version = ">= 1.7.10"

  required_plugins {
    amazon = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "region" {}
variable "source_ami_name" {}
variable "instance_type" {}
variable "subnet_id" {}
variable "security_group_id" {}
variable "name" {}
variable "OS_Name" {}
variable "OS_Version" {}
variable "ami_users" {
  type    = list(string)
  default = []
}

source "amazon-ebs" "amzn2" {
  region                      = var.region
  source_ami_filter {
    filters = {
      name                = var.source_ami_name
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  ami_users                   = var.ami_users
  ami_name                    = "${var.name}-{{timestamp}}"
  associate_public_ip_address = true
  ssh_username                = "ec2-user"
}

build {
  sources = ["source.amazon-ebs.amzn2"]

  provisioner "ansible" {
    playbook_file = "example/playbooks/cis.yml"
    command       = "ANSIBLE_ROLES_PATH=example/roles ansible-playbook"
    user          = "ec2-user"
  }
}
