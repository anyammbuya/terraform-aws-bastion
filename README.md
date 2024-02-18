# Deploying a Bastion Host

This is an example Terraform configuration the allows the deployment of a bastion host for an instance in a private subnet on AWS.

## What are the resources used in this architecture?

A VPC

Availability Zones

Internet gateway

A public subnets in one availability zone

A private subnets in another availability zone

Route tables

Public IP for the bastion host

Security group for the bastion host

Security group for the private subnet

A key pair

Bastion Host