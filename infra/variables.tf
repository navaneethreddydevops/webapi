variable "aws_region" {
  default = "us-east-1"
}

variable "cidr_block" {
  default = "10.0.0.0/16"
}

variable "public_subnet_one_cidr" {
  default = "10.0.1.0/24"
}

variable "public_subnet_two_cidr" {
  default = "10.0.2.0/24"
}

variable "private_subnet_one_cidr" {
  default = "10.0.3.0/24"
}

variable "private_subnet_two_cidr" {
  default = "10.0.4.0/24"
}