#!/usr/bin/env bash

#### IMPORTANT ####
# Run this after you have applied all of your terraform to set required SSM values via prompts.
# Due to arguably one of the dumbest decisions ever, if you pass in a URL as a value to an SSM parameter, the AWS CLI
# tries to fetch the URL instead and pass the contents to SSM. As a result the workaround is this:
# In your ~/.aws/config for the profile you're using, add this flag: cli_follow_urlparam = false
# For instance:

#[profile dev]
#region = us-east-1
#output = json
#cli_follow_urlparam = false


# If you do not do this, your script will break. So please add cli_follow_urlparam to ~/.aws/config if you use this script!
. utils.sh


if [ "$#" != 1 ]; then
    e_error "Invalid parameters, requires: <aws profile>"
    e_notify "Your AWS Profile must have the 'cli_follow_urlparam = false' options set or this will not work. See comments in this script"
    e_notify " For example: ./add_webhook.sh default"
    exit 1
fi

profile=$1

read -p "Please input the channel name linked to this webhook: " channel
key="/devops/lambda/flapping_detector/webhooks/channel/$channel"
read -p "Please input the webhook URL linked to this channel for notifications: " webhook_url
output=$(aws ssm put-parameter --name "$key" --value="$webhook_url" --profile "$profile" --type String --overwrite)

if [ $? -eq 0 ]; then
    e_success "Successfully pushed webhook mapping for $channel to $key" || e_error "Error pushing parameter mapping to SSM"
else
    e_error "Failed to update SSM webhook mapping of key: [$key] to [$webhook_url] - output: $output"
fi