import boto3
import os
import re
import time
from dynamo_svc import DynamoDao
from slack import SlackService
from ssm import SsmSvc
from datetime import datetime, timedelta
from config import *
from botocore.exceptions import ClientError

# Init from ENV variables
run_env = os.environ['run_env']

# Init services
boto_ssm = boto3.client('ssm')
ssm = SsmSvc(boto_ssm)
dynamo = DynamoDao(boto3.resource('dynamodb'), ssm)
slack = SlackService(dynamo, ssm)

# By looking up and stores these in the global context, these don't have to be looked up every invocation.
recovery_period, notification_interval, start_of_business, end_of_business, default_channel = None, None, None, None, None


def lambda_handler(event, context):
    if event["detail-type"] == "ECS Task State Change":
        # Grab keys from PS & Init global properties - Lazy load, don't always init if improper type of message
        init_config()

        detail = event["detail"]
        if detail["desiredStatus"] == "RUNNING":
            exp = re.compile('.*task-definition/(.*):([0-9]+)')
            service_match = exp.match(detail["taskDefinitionArn"])
            service_name = service_match.group(1)
            cluster_name = detail["clusterArn"].split("/")[1]
            metrics = dynamo.get_service_metrics(service_name, run_env)

            if "recent_starts" in metrics and metrics["last_updated"] > time.time() - recovery_period:
                if exceeds_alarm_threshold(metrics["recent_starts"]) \
                        and notify_in_scope(metrics, notification_interval) \
                        and in_alert_window(start_of_business, end_of_business):

                    channel_name = get_channel(service_name)

                    if not channel_name:
                        channel_name = get_default_channel()

                    assert channel_name, "Channel name cannot be None or Empty!"
                    post_slack_message(cluster_name, service_name, metrics['recent_starts'], channel_name,
                                       recovery_period)
                    metrics["last_notification"] = time.time()

                metrics["recent_starts"] = int(metrics["recent_starts"]) + 1
            else:
                metrics["recent_starts"] = 1

            print(
                f'Pushing service metric information: service: {service_name}, run_env: {run_env}, metrics: {metrics}')
            metrics["last_updated"] = time.time()
            dynamo.put_service_metrics(service_name, run_env, metrics)


# In this case, it's not _required_, so we are ok with returning None this notification channel isn't configured
def get_channel(service_name):
    try:
        return ssm.get_from_ps(f"/devops/lambda/flapping_detector/notifications/channel/{service_name}")
    except ClientError:
        print(f"No channel override found for service {service_name}")
        return None


# Has enough time elapsed since the last notification that we now must renotify?
def notify_in_scope(metrics, notification_interval):
    return "last_notification" not in metrics or time.time() - notification_interval > metrics["last_notification"]


def get_alarm_threshold():
    try:
        return int(ssm.get_from_ps(ALARM_THRESHOLD_PATH))
    except ClientError:
        raise Exception(f"Alarm threshold must be set in Parameter Store: {ALARM_THRESHOLD_PATH}")


def exceeds_alarm_threshold(recent_starts):
    return recent_starts > get_alarm_threshold()


def in_alert_window(start_time, end_time):
    # Force to desired TZ (ish, due to DST)
    now = (datetime.utcnow() - timedelta(hours=HOURS_FROM_UTC))

    alert_weekends = ssm.get_from_ps(ALERT_WEEKENDS).lower() == "true"

    # 5/6 are Sat/Sun respectively, so don't notify on those days
    if now.weekday() > 4 and not alert_weekends:
        print(f"It's a weekend, and weekend alerting is disabled. Not alerting!")
        return False

    now_time = now.time()
    start_time = datetime.strptime(start_time, "%I:%M%p").time()
    end_time = datetime.strptime(end_time, "%I:%M%p").time()
    return is_now_time_in_period(start_time, end_time, now_time)


def is_now_time_in_period(start_time, end_time, now_time):
    if start_time < end_time:
        return start_time <= now_time <= end_time
    else:  # Over midnight
        return now_time >= start_time or now_time <= end_time


# Leverages standard slack message formatting: https://api.slack.com/docs/message-formatting
def post_slack_message(cluster_name, service_name, recent_starts, channel_name, recovery_period):
    global run_env
    global ssm
    print(f'Alerting slack channel: {channel_name} for non compliance of service {service_name}')

    # Post alert to slack
    slack.push_slack_notification(channel_name, {
        "attachments": [{
            "attachment_type": "default",
            "title": "Flapping Service Alarm",
            "title_link": f"https://console.aws.amazon.com/ecs/home?region=us-east-1#/clusters/"
                          f"{cluster_name}/services/{service_name}/events",
            "text": f"Service: *{service_name}* may be flapping in *{run_env}*. It has started *{recent_starts}* "
                    f"times since it last went {recovery_period / 60} minutes without restarting!",
            "color": "warning"
        },
            {
                "attachment_type": "default",
                "title": "Check the logs!",
                "title_link": f"https://queryable-link-to-your-log-solution",
                "text": f"Click the above link for a shortcut to the {run_env} *{service_name}* service logs",
                "color": "warning"
            },
            {
                "attachment_type": "default",
                "fallback": "Suppress Notifications",
                "title": "Suppress Notifications :no_bell: ",
                "color": "warning",
                "callback_id": f"{ssm.get_from_ps(SLACK_SUPPRESS_FLAPPER_CALLBACK_ID)}",
                "actions": [
                    {
                        "name": f"{ssm.get_from_ps(SLACK_SUPPRESS_FLAPPER_ACTION_NAME)}",
                        "text": "Suppress Notifications :no_bell:",
                        "type": "select",
                        "style": "danger",
                        "options": [
                            {
                                "text": "30m",
                                "value": f"{service_name}|{run_env}|30"
                            },
                            {
                                "text": "1 hour",
                                "value": f"{service_name}|{run_env}|60"
                            },
                            {
                                "text": "2 hours",
                                "value": f"{service_name}|{run_env}|120"
                            },
                            {
                                "text": "4 hours",
                                "value": f"{service_name}|{run_env}|240"
                            }
                        ],
                        "confirm": {
                            "title": f"So you're gonna fix it?",
                            "text": f"You betta fix {service_name} or get someone else to fix it if you're going to "
                                    f"silence this!",
                            "ok_text": "You betcha!",
                            "dismiss_text": "No way!"
                        }
                    }
                ]
            }
        ]
    })


# Slightly inefficient, double set - I'm ok with it.
def init_config():
    global recovery_period, notification_interval, start_of_business, end_of_business

    recovery_period = get_recovery_period()
    notification_interval = get_notification_interval()
    start_of_business = get_start_of_business()
    end_of_business = get_end_of_business()


def get_default_channel():
    global default_channel

    if not default_channel:
        default_channel = str_from_ssm(DEFAULT_CHANNEL)

    return default_channel


def get_recovery_period():
    global recovery_period

    if not recovery_period:
        recovery_period = int_from_ssm(RECOVERY_PERIOD)

    return recovery_period


def get_notification_interval():
    global notification_interval

    if not notification_interval:
        notification_interval = int_from_ssm(NOTIFICATION_INTERVAL_PATH)

    return notification_interval


def get_start_of_business():
    global start_of_business

    if not start_of_business:
        start_of_business = str_from_ssm(START_OF_BUSINESS_PATH)

    return start_of_business


def get_end_of_business():
    global end_of_business

    if not end_of_business:
        end_of_business = str_from_ssm(END_OF_BUSINESS_PATH)

    return end_of_business


def str_from_ssm(key):
    return str(safe_lookup_from_ssm(key))


def int_from_ssm(key):
    return int(safe_lookup_from_ssm(key))


def safe_lookup_from_ssm(key):
    try:
        return ssm.get_from_ps(key)
    except ClientError as ex:
        raise Exception(f"Unable to lookup {key} from parameter_store. This parameter is required.", ex)
