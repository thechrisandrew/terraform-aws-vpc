variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnets"
}

variable "private_subnets" {
  type        = list(string)
  description = "List of private subnets"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "nat_gateway_type" {
  type        = string
  description = <<EOT
  (Optional) Type of NAT gateway to use
  
  Options:
    - none(default): No NAT gateway will be created.
    - single_instance: NAT gateway will be created using a single EC2 instance(not highly available). Only use this in development
    - single_gateway: NAT gateway will be created using AWS-managed NAT gateway on a single subnet(not highly available). Only use this in development.
    - multi_gateway: NAT gateway will be created using AWS-managed NAT gateway on all public subnets in each avaibility zone. Recommended for production.

  Default: none
  EOT

  default = "none"
}

variable "nat_instance_type" {
  type        = string
  default     = "t4g.nano"
  description = <<EOT
  (Optional) Type of NAT instance to use. Only used when nat_gateway_type is set to single_instance.
  
  Default: t4g.nano
  EOT
}

variable "environment" {
  type        = string
  description = "The environment name"
}

variable "vpc_name" {
  type        = string
  description = "The name of the VPC"
}
