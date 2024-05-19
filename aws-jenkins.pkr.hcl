packer {
  required_plugins {
    amazon = {
      version = ">= 1.2.8"
      source  = "github.com/hashicorp/amazon"
    }
    ansible = {
      version = "~> 1"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "instance_type" {}
variable "aws_profile" {}
variable "region" {}

source "amazon-ebs" "jenkins-master" {
  ami_description = "Amazon Linux Image with Jenkins"
  ami_name        = "jenkins-master-{{timestamp}}"
  instance_type   = "${var.instance_type}"
  profile         = "${var.aws_profile}"
  region          = "${var.region}"
  source_ami_filter {
    filters = {
      name                = "amzn2-ami-kernel-5.10-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"] #or use "self", which use the credentials' account as owner
  }
  ssh_username = "ec2-user"
  tags = {
    "Name"        = "Jenkins Master"
    "Environment" = "SandBox"
    "OS_Version"  = "Amazon Linux 2"
    "Release"     = "Latest"
    "Created-by"  = "Packer"
  }
}

build {
  name = "jenkins-master"
  sources = [
    "source.amazon-ebs.jenkins-master"
  ]

  provisioner "ansible" {
    playbook_file = "./main.yml"
    roles_path    = "./roles"
  }
}