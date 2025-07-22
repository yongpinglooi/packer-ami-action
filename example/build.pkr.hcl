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

  # Step 1: Install Python 3.8
  provisioner "shell" {
    inline = [
      "echo 'Installing Python 3.8 at: $(date)'",
      "timeout 300s sudo amazon-linux-extras enable python3.8 || echo 'Timeout hit on enabling python3.8'",
      "timeout 300s sudo yum clean metadata || echo 'Timeout hit on yum clean'",
      "timeout 300s sudo yum install -y python38 python38-pip || echo 'Timeout hit on Python install'",
      "sudo alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 2"
    ]
  }

# Step 2: Install Ansible using pip
provisioner "shell" {
  inline = [
    "echo 'Installing Ansible at: $(date)'",
    "timeout 300s sudo python3 -m pip install --upgrade pip || echo 'Timeout hit on pip upgrade'",
    "timeout 300s sudo python3 -m pip install 'ansible-core>=2.12,<2.14' || echo 'Timeout hit on Ansible install'"
  ]
}

  # Step 3: Confirm Ansible is installed
  provisioner "shell" {
    inline = [
      "echo 'Verifying Ansible installation at: $(date)'",
      "ansible --version",
      "which ansible"
    ]
  }

  # Step 4: Heartbeat before running Ansible
  provisioner "shell" {
    inline = [
      "echo 'Reached Ansible playbook phase at: $(date)'"
    ]
  }

  # Step 5: Run the Ansible playbook
  provisioner "ansible" {
    playbook_file   = "example/playbooks/cis.yml"
    extra_arguments = [
      "--skip-tags=rule_4.5.2.4"
    ]
    ansible_env_vars = [
      "ANSIBLE_ROLES_PATH=example/roles",
      "ANSIBLE_HOST_KEY_CHECKING=False",
      "ANSIBLE_SSH_ARGS=-oHostKeyAlgorithms=+ssh-rsa -oPubkeyAcceptedAlgorithms=+ssh-rsa -oIdentitiesOnly=yes"
    ]
  }
}
