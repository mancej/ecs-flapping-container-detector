locals {
  dynamo_aws_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/dynamodb.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"
}

resource "aws_dynamodb_table" "ecs_service_metrics" {
  provider       = "aws.dynamo_env"
  name           = "ecs-service-metrics"
  read_capacity  = "${var.dynamo_default_read_capacity}"
  write_capacity = "${var.dynamo_default_write_capacity}"
  hash_key       = "service_key"

  attribute {
    name = "service_key"
    type = "S"
  }

  tags {
    Name = "ecs-service-metrics"
  }

  lifecycle {
    # Ignore changes b/c these are autoscaled. Don't want to overwrite the scaled value.
    ignore_changes = "read_capacity, write_capacity"
  }
}

# Read Scaling
resource "aws_appautoscaling_target" "ecs_service_metrics_read_target" {
  provider           = "aws.dynamo_env"
  max_capacity       = "${var.dynamo_read_max_capacity}"
  min_capacity       = "${var.dynamo_read_min_capacity}"
  resource_id        = "table/${aws_dynamodb_table.ecs_service_metrics.name}"
  role_arn           = "${local.dynamo_aws_role}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "ecs_service_metrics_read_policy" {
  provider           = "aws.dynamo_env"
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.ecs_service_metrics_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_service_metrics_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service_metrics_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service_metrics_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = "${var.dynamo_read_target_utilization}"
  }
}

# Write scaling
resource "aws_appautoscaling_policy" "ecs_service_metrics_write_policy" {
  provider           = "aws.dynamo_env"
  name               = "DynamoDBWriteCapacityUtilization:${aws_appautoscaling_target.ecs_service_metrics_write_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_service_metrics_write_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service_metrics_write_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service_metrics_write_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBWriteCapacityUtilization"
    }

    target_value = "${var.dynamo_write_target_utilization}"
  }
}

resource "aws_appautoscaling_target" "ecs_service_metrics_write_target" {
  provider           = "aws.dynamo_env"
  max_capacity       = "${var.dynamo_write_max_capacity}"
  min_capacity       = "${var.dynamo_write_min_capacity}"
  resource_id        = "table/${aws_dynamodb_table.ecs_service_metrics.name}"
  role_arn           = "${local.dynamo_aws_role}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}
