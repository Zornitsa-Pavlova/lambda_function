provider "aws" {
    region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "random_pet" lambda_bucket_name {
  prefix = "dreamsofcode"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id

}

resource "aws_s3_bucket_public_access_block" "lambda_bucket_public_access_block" {
  bucket = aws_s3_bucket.lambda_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets = true
}

resource "aws_sqs_queue" "message_queue" {
  name = "message_queue"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "/home/luser/project/modules/lambda_function.py"
  output_path = "/home/luser/project/modules/lambda_function.zip"
}


data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["arn:aws:logs:*:*:*"]
  }
}

resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"
  policy      = data.aws_iam_policy_document.lambda_logging.json
}


resource "aws_lambda_function" "lambda_function" {
  function_name = "lambda_function"
  filename      = data.archive_file.lambda_zip.output_path
  runtime       = "python3.8"
  handler       = "lambda_function.lambda_handler"
  role          = aws_iam_role.lambda_role.arn
  source_code_hash = filebase64sha256(data.archive_file.lambda_zip.output_path)
  memory_size      = 128
  timeout          = 10

  environment {
      variables =  {
        BUKET_NAME = aws_s3_bucket.lambda_bucket.id
}
}
}

resource "aws_lambda_event_source_mapping" "my_lambda" {
  event_source_arn = aws_sqs_queue.message_queue.arn
  function_name    = aws_lambda_function.lambda_function.arn
  enabled          = true
  batch_size        = 1

}

