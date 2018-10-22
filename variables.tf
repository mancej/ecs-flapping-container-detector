variable "alert_interval" {
  description = "How regularly to send notifications in slack for flapping containers. (in seconds)"
}

variable "recovery_period" {
  description = "New containers must not have started for N seconds for the flapping detector to consider this service stable"
}

variable "sequential_start_alarm_threshold" {
  description = "If a service has N starts in a row without going recovery_period time without a start, trigger alarm."
}

variable "start_of_business" {
  description = "E.G. 8:00AM - flapping detector will only alert in the time window between start/end of business"
}

variable "end_of_business" {
  description = "E.G. 6:00PM - flapping detector will only alert in the time window between start/end of business"
}

variable "alert_weekends" {
  description = "Send alerts to Slack on weekends?"
}

variable "default_slack_channel" {
  description = "Default channel to push all slack notifications to. Every service's notification can be remapped to any arbitrary channel."
}

variable "default_slack_channel_webhook" {
  description = "Slack webhook URL for the default channel"
}

variable "slack_suppress_flapper_callback_id" {
  description = "Maps to a slack action callback id as configured in your slack application. Used for routing suppression requests back to your lambda"
}

variable "slack_suppress_flapper_action_name" {
  description = "Action name as defined in your slack application. Used for routing suppression requests back to your lambda."
}

variable "default_region" {
  description = "Your aws region"
}

variable "run_env" {
  description = "Leverage this to deploy your detector across many accounts."
}

variable "lambda_bucket_id" {
  description = "Bucket to deploy this lambda into."
}

variable "event_handler_timeout" {
  description = "Timeout for this lambda function"
}

variable "handler_reserved_concurrent_executions" {
  description = "Maximum # of concurrent executions for the callback handler. Recommended: 3"
  default = 3
}
variable "detector_reserved_concurrent_executions" {
  description = "Maximum # of concurrent executions for the flapping container detector. For extremely active accounts with large amounts of container starts/stops, increase this beyond 5."
  default = 5
}

variable "dynamo_read_max_capacity" {
  description = "Maximum value dynamo can scale up to for reads."
}

variable "dynamo_read_min_capacity" {
  description = "Dynamo will never scale down below this capacity."
}

variable "dynamo_write_max_capacity" {
  description = "Maximum value dynamo can scale up to for writes."
}

variable "dynamo_write_min_capacity" {
  description = "Dynamo will never scale down below this capacity."
}

variable "dynamo_default_read_capacity" {
  description = "Dynamo will be provisioned at this read capacity."
}

variable "dynamo_read_target_utilization" {
  description = "Scaling will target this percentage of utilization. I.E. If current load is 20 read ops, scaling will target a total read capacity of 40."
}

variable "dynamo_default_write_capacity" {
  description = "Dynamo will be provisioned at this write capacity"
}

variable "dynamo_write_target_utilization" {
  description = "Scaling will target this percentage of utilization. I.E. If current load is 20 write ops, scaling will target a total read capacity of 40."
}

variable "zip_name" {
  description = "Name of zip file (without suffix) that this will be deployed into S3 as."
  default     = "flapping_container_detector"
}

variable "dynamo_profile" {
  description = "Profile in ~/.aws/credentials to use to provision the dynamo tables"
}

variable "default_profile" {
  description = "Profile in ~/.aws/credentials to use to provision everything else in"
}
