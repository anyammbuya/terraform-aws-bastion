# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


variable "instance_type" {
  description = "Type of EC2 instance to use"
  type        = string
}

variable "subnet_id_private" {
  description = "Subnet ID for Private EC2 instances"
  type        = string
}

variable "subnet_id_public" {
  description = "Subnet ID for bastion host"
  type        = string
}

variable "security_group_id_bastion" {
  description = "Security group ID for bastion host"
  type        = list(string)
}

variable "security_group_id_app" {
  description = "Security group ID for app"
  type        = list(string)
}
