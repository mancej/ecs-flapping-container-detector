target_account_id = "12346789"
alert_interval = 900
recovery_period = 600
sequential_start_alarm_threshold = 5
start_of_business = "8:00AM"
end_of_business = "6:00PM"
alert_weekends = "true"
default_slack_channel = "engineering-alerts"
default_slack_channel_webhook = "https://hooks.slack.com/services/?????/some-other-stuff-here...."
slack_suppress_flapper_callback_id = "suppress_service_action"
slack_suppress_flapper_action_name = "Flapper Suppression"
default_region = "us-east-1"
run_env = "dev"
lambda_bucket_id = "your-lambda-bucket..."
event_handler_timeout = "60"
handler_reserved_concurrent_executions = 3
detector_reserved_concurrent_executions = 5

