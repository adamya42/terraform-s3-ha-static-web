output "lambda_exec_role_name" {
  description = "The name of the Lambda execution IAM role"
  value       = aws_iam_role.lambda_exec.name
}

output "lambda_exec_role_arn" {
  description = "The ARN of the Lambda execution IAM role"
  value       = aws_iam_role.lambda_exec.arn
}

output "cloudfront_distribution_id" {
  description = "The ID of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend_cdn.id
}

output "cloudfront_domain_name" {
  description = "The domain name of the CloudFront distribution"
  value       = aws_cloudfront_distribution.frontend_cdn.domain_name
}