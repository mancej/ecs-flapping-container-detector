resource "aws_ssm_parameter" "notification_interval" {
  name        = "${local.notification_interval}"
  description = "Alert every N seconds for flapping containers."
  type        = "String"
  value       = "${var.alert_interval}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "default_notification_channel" {
  name        = "${local.default_notification_channel}"
  description = "Default channel for all alerts that have not be remapped to a differnet alert channel."
  type        = "String"
  value       = "${var.default_slack_channel}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "default_channel_webhook" {
  name        = "${local.default_channel_webhook}"
  description = "Default channel for all alerts that have not be remapped to a different alert channel."
  type        = "String"
  value       = "${var.default_slack_channel_webhook}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "recovery_period" {
  name        = "${local.recovery_period}"
  description = "New containers must not have started for N seconds for the flapping detector to consider this service stable"
  type        = "String"
  value       = "${var.recovery_period}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "start_of_business" {
  name        = "${local.start_of_business}"
  description = "E.G. 8:00AM - flapping detector will only alert in the time window between start/end of business"
  type        = "String"
  value       = "${var.start_of_business}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "end_of_business" {
  name        = "${local.end_of_business}"
  description = "E.G. 6:00PM - flapping detector will only alert in the time window between start/end of business"
  type        = "String"
  value       = "${var.end_of_business}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "sequential_start_alarm_threshold" {
  name        = "${local.sequential_start_alarm_threshold}"
  description = "If a service has N starts in a row without going recovery_period time without a start, trigger alarm."
  type        = "String"
  value       = "${var.sequential_start_alarm_threshold}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "suppress_flapper_action_name" {
  name        = "${local.suppress_flapper_action_name}"
  description = "Maps to a slack action configured in your slack application. Used for routing suppression requests back to your callback handler lambda"
  type        = "String"
  value       = "${var.slack_suppress_flapper_callback_id}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "slack_action_name" {
  name        = "${local.slack_action_name}"
  description = "Action name as defined in your slack application. Used for routing suppression requests back to your lambda."
  type        = "String"
  value       = "${var.slack_suppress_flapper_action_name}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "alert_weekends" {
  name        = "${local.alert_weekends}"
  description = "true / false - Do you want alerts to propagate to Slack on weekends?"
  type        = "String"
  value       = "${var.alert_weekends}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "dynamo_service_metrics_table" {
  name        = "${local.dynamo_service_metrics_table}"
  description = "Dynamo table name for service-metrics table"
  type        = "String"
  value       = "${aws_dynamodb_table.ecs_service_metrics.name}"
  overwrite   = "true"
}

resource "aws_ssm_parameter" "dynamo_service_metrics_hash_key" {
  name        = "${local.dynamo_service_metrics_hash_key}"
  description = "Name of PK for dynamo table name for service-metrics table"
  type        = "String"
  value       = "${aws_dynamodb_table.ecs_service_metrics.hash_key}"
  overwrite   = "true"
}
