
# API Gateway
resource "aws_api_gateway_domain_name" "api_domain" {
  # for_each                 = local.instances
  domain_name              = "api.${var.domain_name}"
  regional_certificate_arn = aws_acm_certificate.multi_region.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }
  depends_on = [aws_acm_certificate_validation.multi_region]
}


resource "aws_api_gateway_rest_api" "api" {
  for_each = local.instances
  name     = "${var.api_gateway_name}-${each.key}"
  #provider = each.value
  description = "API Gateway for High Availability"
}

resource "aws_api_gateway_resource" "read_resource" {
  for_each    = local.instances
  rest_api_id = aws_api_gateway_rest_api.api[each.key].id
  parent_id   = aws_api_gateway_rest_api.api[each.key].root_resource_id
  path_part   = "read"
  #provider = each.value
}

resource "aws_api_gateway_resource" "write_resource" {
  for_each    = local.instances
  rest_api_id = aws_api_gateway_rest_api.api[each.key].id
  parent_id   = aws_api_gateway_rest_api.api[each.key].root_resource_id
  path_part   = "write"
  #provider = each.value
}

resource "aws_api_gateway_method" "get_method" {
  for_each      = local.instances
  rest_api_id   = aws_api_gateway_rest_api.api[each.key].id
  resource_id   = aws_api_gateway_resource.read_resource[each.key].id
  http_method   = "GET"
  authorization = "NONE"
  #provider = each.value
}

resource "aws_api_gateway_method" "post_method" {
  for_each      = local.instances
  rest_api_id   = aws_api_gateway_rest_api.api[each.key].id
  resource_id   = aws_api_gateway_resource.write_resource[each.key].id
  http_method   = "POST"
  authorization = "NONE"
  #provider = each.value
}

resource "aws_api_gateway_integration" "get_integration" {
  for_each                = local.instances
  rest_api_id             = aws_api_gateway_rest_api.api[each.key].id
  resource_id             = aws_api_gateway_resource.read_resource[each.key].id
  http_method             = aws_api_gateway_method.get_method[each.key].http_method
  integration_http_method = "GET"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.read_function[each.key].invoke_arn

  depends_on = [aws_lambda_function.read_function]
  #provider = each.value
}

resource "aws_api_gateway_integration" "post_integration" {
  for_each                = local.instances
  rest_api_id             = aws_api_gateway_rest_api.api[each.key].id
  resource_id             = aws_api_gateway_resource.write_resource[each.key].id
  http_method             = aws_api_gateway_method.post_method[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.write_function[each.key].invoke_arn

  depends_on = [aws_lambda_function.write_function]
  #provider = each.value
}

resource "aws_api_gateway_deployment" "api_deployment" {
  for_each = local.instances
  depends_on = [
    aws_api_gateway_integration.get_integration,
    aws_api_gateway_integration.post_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.api[each.key].id
  description = "Deployment for High Availability API"
  #provider = each.value
}

resource "aws_api_gateway_stage" "prod" {
  for_each      = local.instances
  stage_name    = "prod"
  rest_api_id   = aws_api_gateway_rest_api.api[each.key].id
  deployment_id = aws_api_gateway_deployment.api_deployment[each.key].id
  description   = "Production stage for High Availability API"
  #provider = each.value
}