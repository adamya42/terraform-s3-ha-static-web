output "frontend_bucket_name" {
  description = "The name of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.bucket
}

output "frontend_bucket_arn" {
  description = "The ARN of the frontend S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "frontend_website_endpoint" {
  description = "The website endpoint of the frontend S3 bucket"
  value       = aws_s3_bucket_website_configuration.frontend_website.website_endpoint
}

output "lambda_read_object_url" {
  description = "S3 URL for the Lambda read function zip"
  value       = aws_s3_object.lambda_read.id
}

output "lambda_write_object_url" {
  description = "S3 URL for the Lambda write function zip"
  value       = aws_s3_object.lambda_write.id
}

output "index_html_object_url" {
  description = "S3 URL for the index.html file"
  value       = aws_s3_object.index_html.id
}

output "lambda_read_zip_path" {
  description = "The path to the zipped read Lambda function"
  value       = data.archive_file.lambda_read.output_base64sha256
}

output "lambda_write_zip_path" {
  description = "The path to the zipped write Lambda function"
  value       = data.archive_file.lambda_write.output_base64sha256
}