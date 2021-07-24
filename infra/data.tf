# Data to get all availability zones of VPC for master region
data "aws_availability_zones" "us-east-azs" {
  provider = "aws.us-east-1"
  state    = "available"
}