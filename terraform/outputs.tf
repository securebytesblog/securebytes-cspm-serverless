
output "dynamodb_table_name" {
  value = aws_dynamodb_table.cspm_findings.name
}

output "lambda_execution_role_arn" {
  value = aws_iam_role.lambda_exec_role.arn
}

output "api_gateway_url" {
  value = aws_apigatewayv2_api.cspm_api_gateway.api_endpoint
}
