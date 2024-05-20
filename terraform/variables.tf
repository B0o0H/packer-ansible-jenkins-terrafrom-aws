variable "ami_owner" {
  type = string
  description = "Filter for ami owner"
  default = "self"
}

variable "instance_type" {
  type = string
  description = "instance type"
  default = "t2.micro"
}

variable "key_name" {
  type = string
  description = "key pair for instance"
  default = "ansible"
}

variable "ingress_rules" {
  type = map(object({
    from_port = number
    protocol = string
    to_port = number
  }))
  description = "security group ingress rules"
  default = {
    "rule1" = {
      from_port = 8080
      protocol = "tcp"
      to_port = 8080
    },
    "rule2" = {
      from_port = 22 
      protocol = "tcp"
      to_port = 22
    }
    "rule3" = {
      from_port = 80
      protocol = "tcp"
      to_port = 80
    }
  }
}

variable "public_subnets" {
  type = map(object({
    cidr_block = string
    availability_zone = string
  }))
  description = "Public Subnet CIDR with AZ"
  default = {
    "PublicSubnetA" = {
      cidr_block = "10.0.1.0/24"
      availability_zone = "us-west-2a"
    },
    "PublicSubnetB" = {
      cidr_block = "10.0.2.0/24"
      availability_zone = "us-west-2b"
    }
  }
}

variable "subnet_name" {
  description = "Name of the subnet to use for the instance"
  type        = string
  default     = "PublicSubnetA"
}
