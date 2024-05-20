terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

resource "aws_vpc" "JenkinsVPC" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_hostnames = true
  tags = {
    Name = "FirstVPC"
  }
}

resource "aws_subnet" "public_subnets" {
  vpc_id = aws_vpc.JenkinsVPC.id
  for_each = var.public_subnets
  cidr_block = each.value.cidr_block
  availability_zone = each.value.availability_zone
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet - ${each.value.availability_zone}"
  }
}

resource "aws_internet_gateway" "FirstIG" {
  vpc_id = aws_vpc.JenkinsVPC.id
}

resource "aws_route_table" "FirstRT" {
  vpc_id = aws_vpc.JenkinsVPC.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.FirstIG.id
  }
}

resource "aws_route_table_association" "name" {
  for_each = aws_subnet.public_subnets
  subnet_id = each.value.id
  route_table_id = aws_route_table.FirstRT.id
}

resource "aws_security_group" "JenkinsSG" {
  vpc_id = aws_vpc.JenkinsVPC.id
  name = "Jenkins-master-terraform"
  description = "Allow SSH and HTTP inbound traffic from local IP"
}

resource "aws_security_group_rule" "JenkinsSG_ingress" {
  for_each = var.ingress_rules
  type = "ingress"
  cidr_blocks = [format("%s/32", trimspace(data.http.my_public_ip.response_body))]
  from_port = each.value.from_port
  protocol = each.value.protocol
  to_port = each.value.to_port
  security_group_id = aws_security_group.JenkinsSG.id
}


resource "aws_instance" "Jenkins-master" {
  ami           = data.aws_ami.Jenkins.id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public_subnets[var.subnet_name].id
  key_name = data.aws_key_pair.Jenkins.key_name
  vpc_security_group_ids = [aws_security_group.JenkinsSG.id]
  associate_public_ip_address = true

  tags = {
    Name = "Jenkins Master"
  }
}

