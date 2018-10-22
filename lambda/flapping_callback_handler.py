import os
import boto3
from dynamo_svc import DynamoDao
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
    global ssm
    global slack

    print(f"Received Event: {event} and context: {context}")
    validate_slack_signature(event['headers'], event['body'])
    slack.perform_action(json.loads(unquote_plus(event['body']).replace("payload=", "")))


def validate_slack_signature(headers, body):
    global slack_signing_secret

    # Validate expected headers exist - Do not reveal what header is missing.
    assert TIMESTAMP_HEADER in headers, f"Expected header missing. Error Code: S1"
    assert SIGNATURE_HEADER in headers, f"Expected header missing. Error Code: S2"

    slack_signature = headers[SIGNATURE_HEADER]
    timestamp = headers[TIMESTAMP_HEADER]

    # Protects against replay attacks
    assert time.time() - int(timestamp) < 300, f"Bad Request. Error Code: S3"

    base_string = f"v0:{timestamp}:{body}"
    digest = hmac.new(bytes(slack_signing_secret, "utf-8"), bytes(base_string, 'utf-8'),
                      digestmod=hashlib.sha256).hexdigest()
    my_signature = f"v0={digest}"

    # Validate signature
    if not hmac.compare_digest(my_signature, slack_signature):
        # Uncomment for troubleshooting, but we don't want to log the calculated signature by default.
        #print(f"Signature is invalid, got: {my_signature} was expecting: {slack_signature}")
        raise Exception("Bad Request. Error Code: S4")
