variable "aws_region" {
  description = "AWS region for all resources."
  type = string
  default = "eu-west-1"
}

variable "my_lambda_function" {
  description = "lambda_function"
  type        = string
}

variable "role_name" {
  description = "lambda_role"
  type        = string
}

variable "policy_name" {
  description = "lambda_policy"
  type        = string
}

