packer {
  required_plugins {
    amazon = {
      source  = "github.com/hashicorp/amazon"
      version = "~> 1"
    }
  }
}

source "amazon-ebs" "amazon-linux2" {
  ami_description             = local.ami_description
  ami_name                    = local.ami_name
  ami_regions                 = [var.region]
  instance_type               = var.instance_type
  region                      = var.region
  subnet_id                   = var.subnet_id
  security_group_id           = var.security_group_id
  associate_public_ip_address = true

  run_tags = {
    ami-create = local.ami_create
  }

  source_ami_filter {
    filters = {
      name                = "${var.source_ami_name}-*"
      virtualization-type = "hvm"
    }
    owners      = ["137112412989"]
    most_recent = true
  }

  ssh_username = "ec2-user"

  tags = {
    Name        = local.ami_name
    OS_Name     = var.OS_Name
    OS_Version  = var.OS_Version
    PackerBuild = "true"
  }
}

build {
  sources = ["source.amazon-ebs.amazon-linux2"]

  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
    ]
  }

  provisioner "shell" {
    scripts = [
      "${path.root}/scripts/update.sh",
      "${path.root}/scripts/cleanup.sh"
    ]
  }

  post-processor "manifest" {
    output     = "${path.root}/manifest.json"
    strip_path = true
  }
}
