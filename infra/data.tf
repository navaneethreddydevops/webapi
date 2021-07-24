# Data to get all availability zones of VPC for master region
data "aws_availability_zones" "us-east-azs" {
  provider = aws.region_master
  state    = "available"
}

# Data to get all availability zones of VPC for worker region
data "aws_availability_zones" "us-west-azs" {
  provider = aws.region_worker
  state    = "available"
}