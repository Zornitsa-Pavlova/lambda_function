provider "aws" {
    region = var.aws_region
}

data "aws_caller_identity" "current" {}

resource "random_pet" lambda_bucket_name {
  prefix = "mybucket"
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
  name = "my_message_queue"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source_file = "/home/luser/project/lambda_function.py"
  output_path = "/home/luser/project/lambda_function.zip"
}


data "aws_iam_policy_document" "lambda_logging" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLog8Stream",
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


resource "aws_lambda_permission" "allow_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.lambda_alarm_topic.arn
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


#  dead_letter_config {
#     target_arn = aws_sqs_queue.dlq.arn
#   }


  environment {
      variables =  {
        BUCKET_NAME = aws_s3_bucket.lambda_bucket.id
}
}
}

resource "aws_lambda_event_source_mapping" "my_lambda" {
  event_source_arn = aws_sqs_queue.message_queue.arn
  function_name    = aws_lambda_function.lambda_function.arn
  enabled          = true
  batch_size        = 1

}

## DynamoDB

resource "aws_dynamodb_table" "LambdaDynamodb" {
  name           = "LambdaDynamodb"  # Directly setting the table name
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "PrimaryKey"

  attribute {
    name = "PrimaryKey"
    type = "S"  # 'S' stands for String type
  }

  tags = {
    Name = "LambdaDynamodb"
  }
}


# resource "aws_iam_role" "lambda_role" {
#   name = "lambda_function-role"

#   assume_role_policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [{
#     "Effect": "Allow",
#     "Action": "sts:AssumeRole",
#     "Principal": {
#       "Service": "lambda.amazonaws.com"
#     }
#   }]
# }
# EOF
# }

# resource "aws_iam_policy" "lambda_dynamodb_policy" {
#   name        = "lambda-dynamodb-policy"
#   description = "IAM policy for Lambda to access DynamoDB"

#   policy = <<EOF
# {
#   "Version": "2012-10-17",
#   "Statement": [
#     {
#       "Effect": "Allow",
#       "Action": [
#         "dynamodb:GetItem",
#         "dynamodb:Query",
#         "dynamodb:Scan"
#       ],
#       "Resource": "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/${var.dynamodb_table_name}"
#     }
#   ]
# }
# EOF
# }

# resource "aws_iam_role_policy_attachment" "lambda_dynamodb_policy_attachment" {
#   role       = aws_iam_role.lambda_role.name
#   policy_arn = aws_iam_policy.lambda_dynamodb_policy.arn
# }
