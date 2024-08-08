import unittest
from unittest.mock import patch, MagicMock
from lambda_function import lambda_handler
import json
import boto3
from moto import mock_aws

s3 = boto3.client('s3')
class TestLambdaFunction(unittest.TestCase):
    
    @patch('lambda_function.boto3.client')
    def test_lambda_handler_success(self, mock_boto_client):
        # Mock S3 client
        mock_s3 = MagicMock()
        mock_boto_client.return_value = mock_s3

        # Define the event and context
        event = {
            'Records': [
                {
                    'body': 'Hello, world!'
                }
            ]
        }
        context = {}

        # Call the lambda handler
        response = lambda_handler(event, context)

        # Assertions
        self.assertEqual(response['statusCode'], 200)
        self.assertIn('Messages processed successfully', response['body'])
        # mock_s3.put_object.assert_called_once_with(
        #     Bucket='dreamsofcode-noticeably-constantly-wondrous-wolf',
        #     Key='message.txt',
        #     Body='Hello, world!'
        # )

    @patch('lambda_function.boto3.client')
    def test_lambda_handler_no_records(self, mock_boto_client):
        # Define the event and context with no records
        event = {}
        context = {}

        # Call the lambda handler
        response = lambda_handler(event, context)

        # Assertions
        self.assertEqual(response['statusCode'], 400)
        self.assertIn('No Records found in event', response['body'])

    @patch('lambda_function.boto3.client')
    def test_lambda_handler_s3_error(self, mock_boto_client):
        # Mock S3 client and simulate an error
        mock_s3 = MagicMock()
        mock_s3.put_object.side_effect = Exception('S3 error')
        mock_boto_client.return_value = mock_s3

        # Define the event and context
        event = {
            'Records': [
                {
                    'body': 'Hello, world!'
                }
            ]
        }
        context = {}

        # Call the lambda handler
        # with self.assertRaises(Exception) as context_manager:
        #     lambda_handler(event, context)

        # # Assertions
        # self.assertEqual(str(context_manager.exception), 'S3 error')

if __name__ == '__main__':
    unittest.main()
