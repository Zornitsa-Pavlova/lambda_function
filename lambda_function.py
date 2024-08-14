import json
import boto3
import logging

s3 = boto3.client('s3')
dynamodb = boto3.client('dynamodb')
bucket_name = 'mybucket-properly-tightly-proud-rhino'
table_name = 'LambdaDynamodb'

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def lambda_handler(event, context):
    logger.info("Received event: " + json.dumps(event, indent=2))
    message = None
    file_key = "message.txt"
    dynamodb_data

    if 'Records' in event:
        for record in event['Records']:
            try:
                # Check if the event is from SNS
                if 'SNS' in record:
                    message = record['SNS']['Message']
                    logger.info(f"Message from SNS: {message}")
                else:
                    # Read message from SQS
                    message = record['body']
                    logger.info(f"Message from SQS: {message}")

                # Read data from DynamoDB
                response = dynamodb.get_item(
                    TableName=table_name,
                    Key={
                        'PrimaryKey': {'S': 'PrimaryKey'}
                    }
                )
                dynamodb_data = response.get('Item')
                logger.info(f"Data from DynamoDB: {dynamodb_data}")

                # Generate a unique ID for the file
                file_key = "message.txt"
                logger.info(f"Generated file key: {file_key}")

                # Upload a file to S3 with the unique ID as the key
                logger.info("Attempting to upload file to S3")
                s3.put_object(Bucket=bucket_name, Key=file_key, Body=message)
                logger.info(f"File uploaded successfully with key: {file_key}")

            except Exception as e:
                logger.error(f"Error processing record: {e}")
                # raise e  # Ensure the error is raised to trigger retries/DLQ

        return {
            'statusCode': 200,
            'body': json.dumps({
                'message': 'Messages processed successfully',
                'sqs_message': message,
                'file_key': file_key,
                'dynamodb_data': dynamodb_data,
                's3': 'Hello from S3'
            })
        }
    else:
        logger.error("No Records found in event")
        return {
            'statusCode': 400,
            'body': json.dumps('No Records found in event')
        }
