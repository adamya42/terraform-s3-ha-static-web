# S3 for Frontend already created while creting backened bucket
resource "aws_s3_bucket" "frontend" {
  bucket = var.frontend_bucket_name
  tags = {
    Name = var.frontend_bucket_name
  }
}

resource "aws_s3_bucket_website_configuration" "frontend_website" {
  bucket = aws_s3_bucket.frontend.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "frontend_policy" {
  bucket = aws_s3_bucket.frontend.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Sid       = "PublicReadGetObject",
      Effect    = "Allow",
      Principal = "*",
      Action    = ["s3:GetObject"],
      Resource  = ["${aws_s3_bucket.frontend.arn}/*"]
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.frontend]
}


data "archive_file" "lambda_read" {
  type = "zip"

  source_dir  = "../lambda_functions/read"
  output_path = "../read.zip"
}

data "archive_file" "lambda_write" {
  type = "zip"

  source_dir  = "../lambda_functions/write"
  output_path = "../write.zip"
}

resource "aws_s3_object" "lambda_read" {
  bucket = aws_s3_bucket.frontend.id

  key    = "lambda/read_function.zip"
  source = data.archive_file.lambda_read.output_path

  etag = filemd5(data.archive_file.lambda_read.output_path)
}

resource "aws_s3_object" "lambda_write" {
  bucket = aws_s3_bucket.frontend.id

  key    = "lambda/write_function.zip"
  source = data.archive_file.lambda_write.output_path

  etag = filemd5(data.archive_file.lambda_write.output_path)
}

resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.frontend.id

  key    = "index.html"
  source = "../index.html"
  etag   = filemd5("../index.html")
}

