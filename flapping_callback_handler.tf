resource "aws_lambda_function" "flapping_callback_handler" {
  s3_bucket        = "${aws_s3_bucket.lambda_bucket.id}"
  s3_key           = "lambdas/${var.zip_name}.zip"
  function_name    = "ecs-flapping-callback-handler"
  handler          = "flapping_callback_handler.lambda_handler"
  role             = "${aws_iam_role.flapping_container_detector.arn}"
  runtime          = "python3.6"
  description      = "Receives callback events from slack notification suppressions through API Gateway"
  depends_on       = ["aws_iam_role.flapping_container_detector"]
  timeout          = "${var.event_handler_timeout}"
  source_code_hash = "${data.aws_s3_bucket_object.flapping_container_lambda_hash.body}"
  reserved_concurrent_executions = 5

  environment {
    variables = {
      run_env = "${var.run_env}"
    }
  }
}

resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowMyDemoAPIInvoke"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.flapping_callback_handler.function_name}"
  principal     = "apigateway.amazonaws.com"

  # The /*/*/* part allows invocation from any stage, method and resource path
  # within API Gateway REST API.
  source_arn = "${aws_api_gateway_rest_api.flapping_callback_api.execution_arn}/*/*/*"
}