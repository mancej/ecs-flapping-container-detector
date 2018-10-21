# ParameterStore Config Paths
RECOVERY_PERIOD = "/devops/lambda/flapping_detector/recovery_period"
NOTIFICATION_INTERVAL_PATH = "/devops/lambda/flapping_detector/notification_interval"
START_OF_BUSINESS_PATH = "/devops/lambda/flapping_detector/start_of_business"
END_OF_BUSINESS_PATH = "/devops/lambda/flapping_detector/end_of_business"
ALARM_THRESHOLD_PATH = "/devops/lambda/flapping_detector/sequential_start_alarm_threshold"
DEFAULT_CHANNEL = "/devops/lambda/flapping_detector/notifications/channel/default"
SERVICE_METRICS_TABLE_NAME = "/devops/dynamo/service_metrics_table_name"
SERVICE_METRICS_HASH_KEY_NAME = "/devops/dynamo/service_metrics_hash_key_name"
ALERT_WEEKENDS = "/devops/lambda/flapping_detector/alert_weekends"
SLACK_SIGNING_SECRET = "/devops/lambda/flapping_detector/signing_secret"
SLACK_SUPPRESS_FLAPPER_ACTION_NAME = "/devops/lambda/flapping_detector/suppress_flapper_slack_action_name"
SLACK_SUPPRESS_FLAPPER_CALLBACK_ID = "/devops/lambda/flapping_detector/suppress_flapper_slack_action_callback_id"

# Other global configs
HOURS_FROM_UTC = 4  # 4 = EST

# Constants
TIMESTAMP_HEADER = 'X-Slack-Request-Timestamp'
SIGNATURE_HEADER = 'X-Slack-Signature'
