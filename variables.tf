variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "vpc_name" {
  description = "Name of VPC"
  type        = string
  default     = "my-vpc-bastion"
}

variable "vpc_cidr_block" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "instance_type" {
  description = "ec2-instance type"
  type        = string
  default     = "t2.micro"
}



