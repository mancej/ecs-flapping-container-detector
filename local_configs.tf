# Your one stop shop for customizing your installation

locals {
  # Parameter Store Key Mappings - If you change these, you MUST update the mappings in lambda/config.py!
  notification_interval = "/devops/lambda/flapping_detector/notification_interval"
  default_notification_channel = "/devops/lambda/flapping_detector/notifications/channel/default"
  default_channel_webhook = "/devops/lambda/flapping_detector/webhooks/channel/${aws_ssm_parameter.default_notification_channel.value}"
  recovery_period = "/devops/lambda/flapping_detector/recovery_period"
  start_of_business = "/devops/lambda/flapping_detector/start_of_business"
  end_of_business = "/devops/lambda/flapping_detector/end_of_business"
  sequential_start_alarm_threshold = "/devops/lambda/flapping_detector/sequential_start_alarm_threshold"
  suppress_flapper_action_name = "/devops/lambda/flapping_detector/suppress_flapper_slack_action_callback_id"
  slack_action_name = "/devops/lambda/flapping_detector/suppress_flapper_slack_action_name"
  alert_weekends = "/devops/lambda/flapping_detector/alert_weekends"
  dynamo_service_metrics_table = "/devops/dynamo/service_metrics_table_name"
  dynamo_service_metrics_hash_key = "/devops/dynamo/service_metrics_hash_key_name"
}
