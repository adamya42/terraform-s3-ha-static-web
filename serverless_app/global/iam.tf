# IAM Role for Lambda
resource "aws_iam_role" "lambda_exec" {
  # for_each = local.instances
  # tags = {
  #   Name = "LambdaExecutionRole-${each.key}"
  # }
  name = "LambdaDynamoDBRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "dynamodb" {
  # for_each = local.instances
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonDynamoDBFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_exec_role_attachment" {
  # Attach the basic execution role for Lambda
  # for_each = local.instances
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
resource "aws_iam_role_policy_attachment" "api_gateway" {
  # for_each = local.instances
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonAPIGatewayInvokeFullAccess"
}