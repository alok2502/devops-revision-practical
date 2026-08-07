variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "CIDR for the public subnet"
  type        = string
}

variable "availability_zone" {
  description = "AZ for the subnet"
  type        = string
  default     = "us-east-1a"
}

variable "environment" {
  description = "Environment name"
  type        = string
}
