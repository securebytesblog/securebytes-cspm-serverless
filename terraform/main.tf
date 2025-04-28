
resource "aws_dynamodb_table" "cspm_findings" {
  name           = var.dynamodb_table_name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "ResourceId"
  range_key      = "Timestamp"

  attribute {
    name = "ResourceId"
    type = "S"
  }

  attribute {
    name = "Timestamp"
    type = "S"
  }

  point_in_time_recovery {
    enabled = true
  }

  server_side_encryption {
    enabled = true
  }

  tags = {
    Name = "CSPM Compliance Findings"
  }
}

resource "aws_iam_role" "lambda_exec_role" {
  name = "cspmLambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "cspm_lambda_policy" {
  name        = "CSPMLambdaPolicy"
  description = "Allow Lambda to write findings to DynamoDB and get logs"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = aws_iam_policy.cspm_lambda_policy.arn
}

resource "aws_lambda_function" "cspm_api" {
  filename         = "lambda_query_findings.zip"
  function_name    = "cspmQueryFindingsAPI"
  role             = aws_iam_role.lambda_exec_role.arn
  handler          = "lambda_query_findings.lambda_handler"
  runtime          = "python3.11"
  timeout          = 30
  memory_size      = 128
}

resource "aws_apigatewayv2_api" "cspm_api_gateway" {
  name          = "CSPMFindingsAPI"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_integration" "cspm_lambda_integration" {
  api_id             = aws_apigatewayv2_api.cspm_api_gateway.id
  integration_type   = "AWS_PROXY"
  integration_uri    = aws_lambda_function.cspm_api.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "cspm_api_route" {
  api_id    = aws_apigatewayv2_api.cspm_api_gateway.id
  route_key = "GET /findings"
  target    = "integrations/${aws_apigatewayv2_integration.cspm_lambda_integration.id}"
}

resource "aws_apigatewayv2_stage" "cspm_api_stage" {
  api_id      = aws_apigatewayv2_api.cspm_api_gateway.id
  name        = "$default"
  auto_deploy = true
}

resource "aws_lambda_permission" "allow_apigw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cspm_api.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.cspm_api_gateway.execution_arn}/*/*"
}
