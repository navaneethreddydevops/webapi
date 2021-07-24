resource "aws_s3_bucket" "s3_bucket" {
  bucket = "github-actions-workflow-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}