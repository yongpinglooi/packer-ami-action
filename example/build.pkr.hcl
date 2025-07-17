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

  # Shell provisioner to install Python 3.8 on Amazon Linux 2
  provisioner "shell" {
    inline = [
      "sudo amazon-linux-extras enable python3.8",
      "sudo yum clean metadata",
      "sudo yum install -y python3.8 python3.8-devel python3.8-pip",
      "sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2"
    ]
  }

  provisioner "ansible" {
    playbook_file    = "example/playbooks/cis.yml"
    command          = "ansible-playbook"
    ansible_env_vars = [
      "ANSIBLE_ROLES_PATH=example/roles",
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS=-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa -oIdentitiesOnly=yes"
    ]
    environment_vars = [
      "ANSIBLE_PYTHON_INTERPRETER=/usr/bin/python3"
    ]
  }
}
