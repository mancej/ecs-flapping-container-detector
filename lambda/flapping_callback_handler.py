import os
import boto3
from dynamo import DynamoDao
from slack import SlackService
from ssm import SsmSvc
from config import *
import time
import hmac
import hashlib
import json
from urllib.parse import unquote_plus

# Init from ENV variables
run_env = os.environ['run_env']

boto_ssm = boto3.client('ssm')
ssm = SsmSvc(boto_ssm)
dynamo = DynamoDao(boto3.resource('dynamodb'), ssm)
slack = SlackService(dynamo, ssm)
slack_signing_secret = ssm.get_from_ps(SLACK_SIGNING_SECRET)


def lambda_handler(event, context):
    print(f"Received Event: {event} and context: {context}")

    if slack_signature_is_valid(event['headers'], event['body']):
        slack.perform_action(json.loads(unquote_plus(event['body']).replace("payload=", "")))

# Throwing an exception will probably result in a 500, which is not useful.
# Todo: Figure out how to throw an exception that results in a 403 + Error code
def slack_signature_is_valid(headers, body):
    # Validate expected headers exist - Do not reveal what header is missing.
    assert TIMESTAMP_HEADER in headers, "Expected header missing. Error Code: S1"
    assert SIGNATURE_HEADER in headers, "Expected header missing. Error Code: S2"

    slack_signature = headers[SIGNATURE_HEADER]
    timestamp = headers[TIMESTAMP_HEADER]

    # Protects against replay attacks
    assert time.time() - int(timestamp) < 300, "Bad Request. Error Code: S3"

    base_string = f"v0:{timestamp}:{body}"
    digest = hmac.new(bytes(slack_signing_secret, 'utf-8'), bytes(base_string, 'utf-8'),
                      digestmod=hashlib.sha256).hexdigest()
    my_signature = f"v0={digest}"

    # Validate signature
    if hmac.compare_digest(my_signature, slack_signature):
        return True
    else:
        # Uncomment for troubleshooting, but we don't want to log the calculated signature by default.
        #print(f"Signature is invalid, got: {my_signature} was expecting: {slack_signature}")
        raise Exception("Bad Request. Error Code: S4")

