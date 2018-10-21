#!/usr/bin/env bash

# We do not keep this parameter in terraform since it would prompt you every time to enter it, or you'd have to
# commit it into github which would be insecure. Use this bash script to push up your slack signing secret to
# parameter store

. utils.sh

if [ "$#" != 1 ]; then
    e_error "Invalid parameters, requires: <aws profile>"
    e_notify "Your <aws profile> is the name you use to define your AWS profile on the AWS cli. I.E. aws s3 ls s3:// --profile my_profile"
    exit 1
fi

profile=$1

key="/devops/lambda/flapping_detector/signing_secret"
read -p "Please enter Slack App generated SIGNING secret:" signing_secret
$(aws ssm put-parameter --name "$key" --value "$signing_secret" --profile "$profile" --type SecureString --overwrite)

if [ $? -ne 0 ]; then
    die "Failed to update SSM key $key with your signing secret"
fi

key="/devops/lambda/flapping_detector/client_secret"
read -p "Please enter Slack App generated CLIENT secret: " client_secret
$(aws ssm put-parameter --name "$key" --value "$client_secret" --profile "$profile" --type SecureString --overwrite)

if [ "$?" -eq 0 ]; then
    e_success "Client secret and signing secret have been securely stored in the AWS account linked to your profile [$profile]"
else
    e_error "Failure updating SSM key $key with your client secret"
fi