# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

# VPC
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.10.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"

  tags = {
    Name = "public"
  }
}


resource "aws_subnet" "private" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.20.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "us-east-1b"

  tags = {
    Name = "private"
  }
}


# Internet GW
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "main-public"
  }
}

# route associations public

resource "aws_route_table_association" "main-public-1-a" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.main-public.id
}


# Security group for the bastion host

resource "aws_security_group" "bastion-allow-ssh" {
  vpc_id      = aws_vpc.main.id
  name        = "bastion-allow-ssh"
  description = "security group for bastion that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "bastion-allow-ssh"
  }
}

module "app_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.13.1"

  vpc_id = aws_vpc.main.id

  use_name_prefix = false

  name        = "app-sg"
  description = "Web server security group"

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "ssh-tcp"
      source_security_group_id = aws_security_group.bastion-allow-ssh.id
      description              = "Allow ssh from bastion host sg"
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_with_cidr_blocks = [
    {
      rule        = "http-80-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 80 at any destination"
    },
    {
      rule        = "https-443-tcp"
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 443 at any destination"
    },
    {
      rule = "ssh-tcp"
      #cidr_blocks= module.vpc.public_subnets_cidr_blocks[0]
      cidr_blocks = "0.0.0.0/0"
      description = "Allows all IPs outbound going to port 22 at any destination"


    }
  ]
}


module "ec2_instances" {
  source = "./modules/aws-instance"

  instance_type             = var.instance_type
  subnet_id_private         = aws_subnet.private.id
  subnet_id_public          = aws_subnet.public.id
  security_group_id_app     = [module.app_security_group.security_group_id]
  security_group_id_bastion = [aws_security_group.bastion-allow-ssh.id]


}
