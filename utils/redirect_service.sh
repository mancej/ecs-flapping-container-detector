#!/usr/bin/env bash

. utils.sh
# Redirects notifications for service X to a different channel. Useful when you have hundreds of services owned by
# different teams and you want different teams to get notified, rather than a single channel being spammed for all
# flapping services.

if [ "$#" != 1 ]; then
    e_error "Invalid parameters, requires: <aws profile>"
    e_notify " For example: ./add_webhook.sh default"
    exit 1
fi

profile=$1

read -p "Please input the ecs service name you'd like to redirect: " service
key="/devops/lambda/flapping_detector/notifications/channel/$service"
read -p "Please input channel you'd like to send notifications for $service to: " channel
aws ssm put-parameter --name "$key" --value="$channel" --profile "$profile" --type String --overwrite

if [ $? -eq 0 ]; then
    e_success "Successfully redirected notifications for $service to $channel"
else
    e_error "Failure updating service -> Channel mapping!"
fi

e_notify "Don't forget to configure the webhook mapping for channel $channel if you haven't already"