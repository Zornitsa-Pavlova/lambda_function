import unittest
from unittest.mock import patch, MagicMock
from lambda_function import lambda_handler
import json
import boto3

s3 = boto3.client('s3')
class TestLambdaFunction(unittest.TestCase):

    @patch('boto3.client')
    def test_lambda_handler(self, mock_boto_client):
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

        # Debug prints
        print(response)

        # Assertions
        self.assertEqual(response['statusCode'], 200)
        self.assertIn('Messages processed successfully', response['body'])
        self.assertIn('Hello, world!', response['body'])

        response = s3.put_object(
         Bucket='dreamsofcode-noticeably-constantly-wondrous-wolf',
            Key='message.txt',
            Body='Hello, world!'
                   )
#       print(response)
if __name__ == '__main__':
    unittest.main()

 
