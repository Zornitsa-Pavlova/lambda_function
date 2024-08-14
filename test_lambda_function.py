import unittest
from unittest.mock import patch, MagicMock
import json
from lambda_function import lambda_handler

class TestLambdaFunction(unittest.TestCase):

    @patch('boto3.client')
    def test_lambda_handler(self, mock_boto_client):
        # Mock S3 and DynamoDB clients
        mock_s3 = MagicMock()
        mock_dynamodb = MagicMock()
        mock_boto_client.side_effect = [mock_s3, mock_dynamodb]

        # Mock DynamoDB response
        mock_dynamodb.get_item.return_value = {
            'Item': {
                'PrimaryKey': {'S': 'PrimaryKey'},
                'Data': {'S': 'Some data'}
            }
        }

        # Define a sample event with 'Records' key
        event = {
            'Records': [
                {
                    'body': 'Test message from SQS'
                }
            ]
        }

        # Call the lambda handler
        response = lambda_handler(event, None)

        # Debugging: Print the response and check if put_object was called
        print(response)
        print(mock_s3.put_object.call_args_list)

        # Assertions
        self.assertEqual(response['statusCode'], 200)
        self.assertIn('Messages processed successfully', response['body'])
        mock_s3.put_object.assert_called_once_with(
            Bucket='mybucket-properly-tightly-proud-rhino',
            Key='message.txt',
            Body='Test message from SQS'
        )
        mock_dynamodb.get_item.assert_called_once_with(
            TableName='LambdaDynamodb',
            Key={'PrimaryKey': {'S': 'PrimaryKey'}}
        )

if __name__ == '__main__':
    unittest.main()
