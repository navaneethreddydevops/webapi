terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
  backend "s3" {
    bucket = "terraform-state-bucket-cicd"
    key    = "non-prod/terraform-state-non-prod.json"
    region = "us-east-1"
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "vpc_devops" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_devops.id
  tags = {
    Name = "IGW"
  }
}

resource "aws_subnet" "subnet_1" {
  availability_zone = element(data.aws_availability_zones.us-east-azs.names, 0)
  vpc_id            = "us-east-1a"
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "subnet_2" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = "10.0.2.0/24"
}