data "amazon-ami" "ubuntu" {
  filters = {
    name                = "ubuntu/images/*${var.source_ami_name}-*"
    root-device-type    = "ebs"
    virtualization-type = "hvm"
  }
  most_recent = true
  owners      = ["099720109477"]
}

source "amazon-ebs" "ubuntu-example" {
  ami_description = local.ami_description
  ami_name        = local.ami_name
  ami_regions     = [var.region]
  instance_type   = var.instance_type
  region          = var.region

  run_tags = {
    ami-create = local.ami_create
  }

  source_ami   = data.amazon-ami.ubuntu.id
  ssh_username = "ubuntu"
  subnet_id    = var.subnet_id

  tags = {
    Name        = local.ami_name
    OS_Name     = var.OS_Name
    OS_Version  = var.OS_Version
    PackerBuild = "true"
  }
}

build {
  sources = ["source.amazon-ebs.ubuntu-example"]
}

provisioner "shell" {
  inline = [
        "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done"
  ]
}

  provisioner "shell" {
    execute_command   = "echo 'ubuntu' | sudo -S env{{ .Vars }} {{ .Path }}"
    expect_disconnect = true

    scripts = [
        "${path.root}/scripts/update.sh",
        "${path.root}/scripts/cleanup.sh"
    ]

    post-processors {
      "manifest" {
        output     = "${path.root}/manifest.json"
        strip_path = true
      }
    }
  }