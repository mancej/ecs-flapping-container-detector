import requests
import simplejson as json
import time
from config import *

bot_defaults = {
    "username": "DevOps-Bot",
    "icon_emoji": ":rainbow:"
}

class SlackService:
    def __init__(self, dynamo_dao, ssm_svc):
        self._suppress_flapper_action_name = ssm_svc.get_from_ps(SLACK_SUPPRESS_FLAPPER_ACTION_NAME)
        self._dynamo_dao = dynamo_dao
        self._ssm = ssm_svc

    def push_slack_notification(self, channel_name, message_props):
        # Merge the dicts, message_props, override defaults
        notification_props = {**bot_defaults, **message_props}
        notification_props["channel"] = channel_name

        webhook_url = self._ssm.get_from_ps(f'/devops/lambda/flapping_detector/webhooks/channel/{channel_name}')
        assert webhook_url, f"No webhook URL found for channel {channel_name}. Please add the mapping with the utils/add_webhook.sh script"

        requests.post(webhook_url, json.dumps(notification_props))

    # Perform slack action - Currently only flapper alarm suppression is supported.
    def perform_action(self, slack_action):
        print(f"Found slack action: {slack_action}")
        assert "actions" in slack_action, "No actions element found in json payload for suppress slack action!"
        actions = slack_action["actions"]

        assert actions, "Actions is empty, should be an array."

        for action in actions:
            assert "name" in action, "No name element found in json payload for suppress slack action!"
            name = action["name"]

            # The only current supported action is flapper suppression
            assert name == self._suppress_flapper_action_name, \
                "Action name does not match configured suppress flapper action name! Only flapper actions are supported!"

            service_name_env_duration = action["selected_options"][0]["value"]
            service_name, run_env, duration = service_name_env_duration.split("|")

            print(f"Slack webhook received, suppressing notifications for service {service_name} for {duration} minutes.")

            metrics = self._dynamo_dao.get_service_metrics(service_name, run_env)

            assert metrics, f"Metrics retrieve from dynamo for service {service_name} and env: {run_env} were empty!"

            # Since we wait for notification_interval_seconds after last notification to notify,
            # we need to back it out here for proper suppression calculation.
            notification_interval_seconds = int(self._ssm.get_from_ps(NOTIFICATION_INTERVAL_PATH))
            metrics["last_notification"] = time.time() + (int(duration) * 60) - notification_interval_seconds

            self._dynamo_dao.put_service_metrics(service_name, run_env, metrics)
            self._acknowledge_suppression(slack_action["original_message"], slack_action["response_url"], service_name,
                                          run_env, slack_action["user"]["name"], duration)

    # Respond to slack channel, acknowledging suppressed alarm.
    def _acknowledge_suppression(self, original_message, response_url, service_name, run_env, user, duration):
        suppression_attachment = {
            "attachment_type": "default",
            "text": f"::white_check_mark: *{user}* has suppressed *{service_name}* in *{run_env}* for *{duration}* minutes.",
            "color": "#439FE0",
        }

        count = 0
        for attachment in original_message["attachments"]:
            if "actions" in attachment and attachment["actions"][0]["name"] == self._suppress_flapper_action_name:
                original_message["attachments"][count] = suppression_attachment
            count = count + 1

        requests.post(response_url, json.dumps(original_message))