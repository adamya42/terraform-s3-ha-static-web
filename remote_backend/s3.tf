resource "aws_s3_bucket" "backend" {
  bucket = "backend-bucket-name"

  tags = {
    Name        = "bucket-name"
  }
}