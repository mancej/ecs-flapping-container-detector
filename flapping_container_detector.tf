# Used to track updates to lambdas, so CICD pipeline deploys of this module detect changes to the lambda and auto-deploy then
data "aws_s3_bucket_object" "flapping_container_lambda_hash" {
  bucket = "${var.lambda_bucket_id}"
  key    = "lambdas/flapping_container_detector.zip.sha256"
}

resource "aws_lambda_function" "flapping_container_detector" {
  s3_bucket                      = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key                         = "lambdas/${var.zip_name}.zip"
  function_name                  = "ecs-flapping-container-detector"
  handler                        = "flapping_container_detector.lambda_handler"
  role                           = "${aws_iam_role.flapping_container_detector.arn}"
  runtime                        = "python3.6"
  description                    = "Listens to ecs event stream, keeps track of container activity, and detects 'flapping' containers"
  depends_on                     = ["aws_iam_role.flapping_container_detector"]
  timeout                        = "${var.event_handler_timeout}"
  source_code_hash               = "${data.aws_s3_bucket_object.flapping_container_lambda_hash.body}"
  reserved_concurrent_executions = 5

  environment {
    variables = {
      run_env = "${var.run_env}"
    }
  }
}

resource "aws_cloudwatch_event_rule" "flapping_container_detector_rule" {
  name        = "ecs-task-state-change"
  description = "Capture ECS events"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ]
}
PATTERN
}

resource "aws_cloudwatch_event_target" "flapping_container_detector_target" {
  target_id  = "ecs-flapping-container-detector"
  arn        = "${aws_lambda_function.flapping_container_detector.arn}"
  rule       = "${aws_cloudwatch_event_rule.flapping_container_detector_rule.name}"
  depends_on = ["aws_lambda_function.flapping_container_detector"]
}

# IAM Permissions
resource "aws_lambda_permission" "flapping_container_lambda_permission" {
  statement_id  = "AllowInvokeFunction"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.flapping_container_detector.function_name}"
  principal     = "events.amazonaws.com"
  source_arn    = "${aws_cloudwatch_event_rule.flapping_container_detector_rule.arn}"
}
