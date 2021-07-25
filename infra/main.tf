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
  tags = {
    Name = "VPC"
  }
}



resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc_devops.id
  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "public_subnet_one" {
  availability_zone       = "us-east-1a"
  vpc_id                  = aws_vpc.vpc_devops.id
  cidr_block              = var.public_subnet_one_cidr
  map_public_ip_on_launch = true
  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "public_subnet_two" {
  availability_zone = "us-east-1b"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = var.public_subnet_two_cidr
  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "private_subnet_one" {
  availability_zone = "us-east-1c"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = var.private_subnet_one_cidr
  tags = {
    Name = "VPC"
  }
}

resource "aws_subnet" "private_subnet_two" {
  availability_zone = "us-east-1d"
  vpc_id            = aws_vpc.vpc_devops.id
  cidr_block        = var.private_subnet_two_cidr
  tags = {
    Name = "VPC"
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
    Name = "VPC"
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.vpc_devops.id
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "VPC"
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

# Launch Configuration
resource "aws_launch_configuration" "launch_configuartion" {
  image_id        = data.aws_ami.ubuntu.id
  instance_type   = var.instance_type
  security_groups = [aws_security_group.instance_security_group.id]

  lifecycle {
    create_before_destroy = true
  }
}
# IAM Role for EC2 Instance
resource "aws_iam_role" "instance_iam_role" {
  name = "instance_iam_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    tag-key = "instance_iam_role"
  }
}


resource "aws_security_group" "instance_security_group" {
  name   = "instance_security_group"
  vpc_id = aws_vpc.vpc_devops.id

  # Inbound SSH
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound All Protocols
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  name                 = "auto_scaling_group"
  launch_configuration = aws_launch_configuration.launch_configuartion.name
  min_size             = 1
  max_size             = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet_one.id, aws_subnet.public_subnet_two.id]
  lifecycle {
    create_before_destroy = true
  }
}