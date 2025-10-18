

variable "regions" {
  type        = list(string)
  description = "List of AWS regions to deploy the certificate"
  default     = ["us-east-1", "us-west-2"] # modify as needed
}

variable "cloudwatch_period" {
  description = "The period for CloudWatch metrics."
  type        = number
  default     = 300 # 5 minutes

}

variable "metric_stat" {
  description = "Statistic type for CloudWatch metrics"
  type        = string
  default     = "Sum"
}

variable "frontend_bucket_name_east" {
  description = "The name of the S3 bucket for storing frontend assets."
  type        = string
  default     = "<bucket-name>-east"
}

variable "frontend_bucket_name_west" {
  description = "The name of the S3 bucket for storing frontend assets."
  type        = string
  default     = "<bucket-name>-west"
}

variable "ha_table_name" {
  description = "The name of the High Availability Set."
  type        = string
  default     = "ha-dr-table"
}

variable "dynamodb_billing_mode" {
  description = "The billing mode for the DynamoDB table."
  type        = string
  default     = "PAY_PER_REQUEST"
}

variable "secondary_region" {
  description = "The secondary AWS region for disaster recovery."
  type        = string
  default     = "us-west-2"
}

variable "domain_name" {
  description = "The domain name for the application."
  type        = string
  default     = "your-domain.com" # replace with your actual domain

}

variable "api_gateway_name" {
  description = "The name of the API Gateway"
  type        = string
  default     = "HighAvailabilityAPI"
}