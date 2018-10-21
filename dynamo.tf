locals {
  dynamo_aws_role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/aws-service-role/dynamodb.application-autoscaling.amazonaws.com/AWSServiceRoleForApplicationAutoScaling_DynamoDBTable"
}

resource "aws_dynamodb_table" "ecs_service_metrics" {
  provider = "aws.dynamo_env"
  name           = "ecs-service-metrics"
  read_capacity  = 40
  write_capacity = 20
  hash_key       = "service_key"

  attribute {
    name = "service_key"
    type = "S"
  }

  tags {
    Name        = "ecs-service-metrics"
  }

  lifecycle {
    ignore_changes = "read_capacity"
  }
}

resource "aws_appautoscaling_target" "ecs_service_metrics_read_target" {
  provider = "aws.dynamo_env"
  max_capacity       = 100
  min_capacity       = 30
  resource_id        = "table/${aws_dynamodb_table.ecs_service_metrics.name}"
  role_arn           = "${local.dynamo_aws_role}"
  scalable_dimension = "dynamodb:table:ReadCapacityUnits"
  service_namespace  = "dynamodb"
}

resource "aws_appautoscaling_policy" "ecs_service_metrics_read_policy" {
  provider = "aws.dynamo_env"
  name               = "DynamoDBReadCapacityUtilization:${aws_appautoscaling_target.ecs_service_metrics_read_target.resource_id}"
  policy_type        = "TargetTrackingScaling"
  resource_id        = "${aws_appautoscaling_target.ecs_service_metrics_read_target.resource_id}"
  scalable_dimension = "${aws_appautoscaling_target.ecs_service_metrics_read_target.scalable_dimension}"
  service_namespace  = "${aws_appautoscaling_target.ecs_service_metrics_read_target.service_namespace}"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "DynamoDBReadCapacityUtilization"
    }

    target_value = 50
  }
}

resource "aws_appautoscaling_target" "ecs_service_metrics_write_target" {
  provider = "aws.dynamo_env"
  max_capacity       = 100
  min_capacity       = 20
  resource_id        = "table/${aws_dynamodb_table.ecs_service_metrics.name}"
  role_arn           = "${local.dynamo_aws_role}"
  scalable_dimension = "dynamodb:table:WriteCapacityUnits"
  service_namespace  = "dynamodb"
}
