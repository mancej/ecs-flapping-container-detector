resource "aws_dynamodb_table" "ecs_service_metrics" {
  name           = "ecs-service-metrics"
  hash_key       = "service_key"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "service_key"
    type = "S"
  }

  tags {
    Name = "ecs-service-metrics"
  }
}