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
  region = var.aws_region
}

# Create a VPC
resource "aws_vpc" "vpc_devops" {
  cidr_block           = var.cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  enable_classiclink   = "false"
  instance_tenancy     = "default"
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

resource "aws_subnet" "public_subnet_one" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.vpc_devops.id
  cidr_block              = var.public_subnet_one_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-One"
  }
}

resource "aws_subnet" "public_subnet_two" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = var.public_subnet_two_cidr
  tags = {
    Name = "Public-Subnet-Two"
  }
}

resource "aws_subnet" "private_subnet_one" {
  availability_zone = "us-east-1c"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = var.private_subnet_one_cidr
  tags = {
    Name = "Private-Subnet-One"
  }
}

resource "aws_subnet" "private_subnet_two" {
  availability_zone = "us-east-1d"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = var.private_subnet_two_cidr
  tags = {
    Name = "Private-Subnet-One"
  }
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.vpc_devops.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_devops.id
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "PrivateRoute-Table"
  }
}

resource "aws_main_route_table_association" "vpc_main_route_table" {
  vpc_id         = aws_vpc.vpc_devops.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_one_association" {
  subnet_id      = aws_subnet.public_subnet_one.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_two_association" {
  subnet_id      = aws_subnet.public_subnet_two.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "private_subnet_one_association" {
  subnet_id      = aws_subnet.private_subnet_one.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "private_subnet_two_association" {
  subnet_id      = aws_subnet.private_subnet_two.id
  route_table_id = aws_route_table.private_route_table.id
}

