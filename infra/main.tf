resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "vpc"
  }

}

resource "aws_internet_gateway" "igw" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc.id
  tags = {
    Name = "igw"
  }
}

resource "aws_subnet" "subnet_1" {
  provider          = aws.region_master
  availability_zone = element(data.aws_availability_zones.us-east-azs.names, 0)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "subnet_2" {
  provider          = aws.region_master
  availability_zone = element(data.aws_availability_zones.us-east-azs.names, 1)
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
}

# US-EAST Route Table
resource "aws_route_table" "internet-route" {
  provider = aws.region_master
  vpc_id   = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block                = "10.0.0.0/16"
  }
  lifecycle {
    ignore_changes = all
  }
  tags = {
    Name = "VPC"
  }
}