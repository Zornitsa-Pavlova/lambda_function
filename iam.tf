resource "aws_iam_role" "lambda_role" {
  name = "lambda_function-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": "sts:AssumeRole",
    "Principal": {
      "Service": "lambda.amazonaws.com"
    }
  }]
}
EOF
}

resource "aws_cloudwatch_log_group" "lambda_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.lambda_function.function_name}"
  retention_in_days = 7
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-s3-policy"
  description = "IAM policy for Lambda to access S3"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject"
        
  lifecycle_rule {
    id      = "block-public-access"
    status  = "Enabled"

    block_public_acls       = true
    block_public_policy     = true
    ignore_public_acls      = true
    restrict_public_buckets = true
      ],
      "Resource": "${aws_s3_bucket.lambda_bucket.arn}/*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "sqs:ReceiveMessage",
        "sqs:DeleteMessage",
        "sqs:GetQueueAttributes"
      ],
      "Resource": "${aws_sqs_queue.message_queue.arn}"
    }
  ]
}
EOF
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Id      = "lambda_bucket_policy",
    Statement = [
      {
        Sid       = "HTTPSOnly",
        Effect    = "Deny",
        Principal = "*",
        Action    = "s3:*",
        Resource = [
          "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.id}",
          "arn:aws:s3:::${aws_s3_bucket.lambda_bucket.id}/*"
        ],
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_bucket.id

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${aws_iam_role.lambda_role.name}"
      },
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": [
        "${aws_s3_bucket.lambda_bucket.arn}/*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy" "function_logging_policy" {
  name   = "function-logging-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        Action : [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect : "Allow",
        Resource : "arn:aws:logs:eu-west-1:555256523315:log-group:/aws/lambda/lambda_function:*"
      }
    ]
  })
}

resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda_function"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      LOG_GROUP_NAME = aws_cloudwatch_log_group.lambda_log_group.name
    }
  }
}

resource "aws_iam_role_policy_attachment" "lambda_logging_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.function_logging_policy.arn
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "lambda_s3_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}
