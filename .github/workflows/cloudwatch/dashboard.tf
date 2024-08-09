provider "aws" {
  region = "eu-west-1"
}

resource "aws_cloudwatch_dashboard" "lambda_dashboard" {
  dashboard_name = "lambda_dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric",
        x = 0,
        y = 0,
        width = 6,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/Lambda", "Invocations", "FunctionName", "lambda_function" ],
            [ ".", "Errors", ".", "." ],
            [ ".", "Duration", ".", "." ],
            [ ".", "Throttles", ".", "." ],
            [ ".", "IteratorAge", ".", "." ]
          ],
          period = 300,
          stat = "Sum",
          region = "eu-west-1",
          title = "Lambda Metrics"
        }
      },
      {
        type = "metric",
        x = 6,
        y = 0,
        width = 6,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/SQS", "NumberOfMessagesSent", "QueueName", "message_queue" ],
            [ ".", "NumberOfMessagesReceived", ".", "." ],
            [ ".", "NumberOfMessagesDeleted", ".", "." ],
            [ ".", "ApproximateNumberOfMessagesVisible", ".", "." ]
          ],
          period = 300,
          stat = "Sum",
          region = "eu-west-1",
          title = "SQS Metrics"
        }
      },
      {
        type = "metric",
        x = 0,
        y = 6,
        width = 6,
        height = 6,
        properties = {
          metrics = [
            [ "AWS/S3", "NumberOfObjects", "BucketName", "dreamsofcode-noticeably-constantly-wondrous-wolf" ],
            [ ".", "BucketSizeBytes", ".", "." ],
            [ ".", "AllRequests", ".", "." ],
            [ ".", "GetRequests", ".", "." ],
            [ ".", "PutRequests", ".", "." ]
          ],
          period = 300,
          stat = "Sum",
          region = "eu-west-1",
          title = "S3 Metrics"
        }
      }
    ]
  })
}
