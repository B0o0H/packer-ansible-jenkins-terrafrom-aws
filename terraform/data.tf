data "aws_ami" "Jenkins" {
  most_recent = true

  owners = ["self"]
  filter {
    name = "name"
    values = ["jenkins-master-*"]
  } 
}

data "aws_key_pair" "Jenkins" {
  key_name = var.key_name
  include_public_key = true
}

data "http" "my_public_ip" {
  url = "http://checkip.amazonaws.com/"
}
