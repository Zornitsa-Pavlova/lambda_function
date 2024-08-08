
resource "aws_cloudwatch_metric_alarm" "lambda_error_alarm" {
  alarm_name          = "lambda_error_alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm when Lambda function errors exceed 1"
  dimensions = {
    FunctionName = aws_lambda_function.lambda_function.function_name
  }
}


# resource "aws_cloudwatch_alarm" "lambda_error_alarm" {
#   alarm_name          = "lambda_error_alarm"
#   comparison_operator = "GreaterThanOrEqualToThreshold"
#   evaluation_periods  = "1"
#   metric_name         = aws_cloudwatch_metric_filter.lambda_metric_filter.metric_transformation[0].name
#   namespace           = aws_cloudwatch_metric_filter.lambda_metric_filter.metric_transformation[0].namespace
#   period              = "60"
#   statistic           = "Sum"
#   threshold           = "1"

#   alarm_description   = "Alarm when Lambda function errors exceed 1"
#   actions_enabled     = true
# }



resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
  lifecycle {
    prevent_destroy = false
  }
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
}

resource "aws_cloudwatch_log_stream" "lambda_log_stream" {
  name           = "lambda_log_stream"
  log_group_name = aws_cloudwatch_log_group.function_log_group.name
}

resource "aws_cloudwatch_log_metric_filter" "lambda_metric_filter" {
  name           = "lambda_metric_filter"
  log_group_name = aws_cloudwatch_log_group.function_log_group.name
  pattern        = "ERROR"

  metric_transformation {
    name      = "LambdaErrors"
    namespace = "LambdaMetrics"
    value     = "1"
  }
}


