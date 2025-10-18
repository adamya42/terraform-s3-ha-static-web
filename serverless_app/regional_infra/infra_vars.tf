variable "domain_name" {
  description = "The domain name for the application."
  type        = string

}

variable "pyton_runtime" {
  description = "The Python runtime version for Lambda functions."
  type        = string
  default     = "python3.9"

}

variable "frontend_bucket_name" {
  description = "The name of the frontend S3 bucket"
  type        = string
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table"
  type        = string
}

variable "lambda_read_object_url" {
  description = "The S3 URL for the read Lambda zip"
  type        = string
}

variable "lambda_write_object_url" {
  description = "The S3 URL for the write Lambda zip"
  type        = string
}


variable "lambda_read_zip_path" {
  description = "The path to the zipped read Lambda function"
  type        = string
}

variable "lambda_write_zip_path" {
  description = "The path to the zipped write Lambda function"
  type        = string
}

variable "lambda_exec_role_arn" {
  description = "The ARN of the Lambda execution IAM role"
  type        = string
}

variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
}