
variable "aws_region" {
  default = "us-east-1"
}

variable "dynamodb_table_name" {
  default = "CSPMFindings"
}

variable "lambda_function_name" {
  default = "cspmComplianceChecker"
}
