# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = "${file("${path.module}/mykey.pub")}"
}

resource "aws_instance" "app" {
 
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  subnet_id              = var.subnet_id_private
  vpc_security_group_ids = var.security_group_id_app

  key_name = aws_key_pair.mykeypair.key_name

}

resource "aws_instance" "bastion" {
 
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  
  subnet_id              = var.subnet_id_public
  associate_public_ip_address = true
  vpc_security_group_ids = var.security_group_id_bastion

  key_name = aws_key_pair.mykeypair.key_name

 
}

