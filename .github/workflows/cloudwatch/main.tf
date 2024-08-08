
resource "aws_cloudwatch_event_rule" "every_one_minute" {
  name                = "every-one-minute"
  description         = "Fires every one minutes"
  schedule_expression = "rate(1 minute)"
}

resource "aws_cloudwatch_event_target" "check_foo_every_one_minute" {
  rule      = "${aws_cloudwatch_event_rule.every_one_minute.name}"
  target_id = "lambda"
  arn       = "${aws_lambda_function.lambda.arn}"
}

resource "aws_lambda_permission" "allow_cloudwatch_to_call_check_foo" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.every_one_minute.arn}"
}


# S3 Bucket configure
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket"
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}


# SQS Bucket configure
resource "aws_sqs_queue" "my_queue" {
  name = "my-queue"
}

resource "aws_cloudwatch_metric_alarm" "sqs_alarm" {
  alarm_name          = "sqs-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "60"
  statistic           = "Average"
  threshold           = "10"
  alarm_description   = "Alarm when there are more than 10 messages in the queue"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.sqs_alarm_topic.arn]
  dimensions = {
    QueueName = aws_sqs_queue.my_queue.name
  }
}
#lambda function matric
resource "aws_cloudwatch_metric_alarm" "lambda_alarm" {
  alarm_name          = "lambda-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = "Errors"
  namespace           = "AWS/Lambda"
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"
  alarm_description   = "Alarm when the Lambda function errors"
  actions_enabled     = true
  alarm_actions       = [aws_sns_topic.lambda_alarm_topic.arn]
  dimensions = {
    FunctionName = aws_lambda_function.my_lambda.function_name
  }
}

