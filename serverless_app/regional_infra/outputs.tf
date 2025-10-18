output "read_function_names" {
  description = "The names of the read Lambda functions per region"
  value       = [for func in aws_lambda_function.read_function : func.function_name]
}

output "write_function_names" {
  description = "The names of the write Lambda functions per region"
  value       = [for func in aws_lambda_function.write_function : func.function_name]
}

output "api_gateway_domain_name" {
  description = "The custom domain name for the API Gateway"
  value       = aws_api_gateway_domain_name.api_domain.domain_name
}

output "api_gateway_domain_target" {
  description = "The target domain name for Route53 alias (regional domain name)"
  value       = aws_api_gateway_domain_name.api_domain.regional_domain_name
}

output "api_gateway_domain_zone_id" {
  description = "The Route53 zone ID for the API Gateway custom domain"
  value       = aws_api_gateway_domain_name.api_domain.regional_zone_id
}

output "api_gateway_rest_api_ids" {
  description = "The IDs of the API Gateway REST APIs"
  value       = { for k, v in aws_api_gateway_rest_api.api : k => v.id }
}

output "api_gateway_stage_names" {
  description = "The stage names for each API Gateway instance"
  value       = { for k, v in aws_api_gateway_stage.prod : k => v.stage_name }
}