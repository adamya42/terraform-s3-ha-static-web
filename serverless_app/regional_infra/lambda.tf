

# Lambda Functions
resource "aws_lambda_function" "read_function" {
  for_each = local.instances
  #provider = each.value
  function_name    = "ReadFunction-${each.key}"
  s3_bucket        = var.frontend_bucket_name
  s3_key           = var.lambda_read_object_url
  role             = var.lambda_exec_role_arn
  handler          = "read_function.lambda_handler"
  runtime          = var.pyton_runtime
  source_code_hash = var.lambda_read_zip_path
  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}

resource "aws_lambda_function" "write_function" {
  for_each = local.instances
  #provider = each.value
  function_name = "WriteFunction-${each.key}"

  s3_bucket        = var.frontend_bucket_name
  s3_key           = var.lambda_write_object_url
  role             = var.lambda_exec_role_arn
  handler          = "write_function.lambda_handler"
  runtime          = var.pyton_runtime
  source_code_hash = var.lambda_write_zip_path
  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }
}