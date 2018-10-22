resource "aws_api_gateway_rest_api" "flapping_callback_api" {
  name        = "FlappingCallbackLambda"
  description = "Used to trigger the Flapping Container Callback API"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.flapping_callback_api.id}"
  parent_id   = "${aws_api_gateway_rest_api.flapping_callback_api.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.flapping_callback_api.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "flapping_callback_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.flapping_callback_api.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.flapping_callback_handler.invoke_arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.flapping_callback_api.id}"
  resource_id   = "${aws_api_gateway_rest_api.flapping_callback_api.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "flapping_callback_root_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.flapping_callback_api.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "ANY"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.flapping_callback_handler.invoke_arn}"
}

resource "aws_api_gateway_deployment" "gateway_deployment" {
  depends_on = [
    "aws_api_gateway_integration.flapping_callback_integration",
    "aws_api_gateway_integration.flapping_callback_root_integration",
  ]

  rest_api_id = "${aws_api_gateway_rest_api.flapping_callback_api.id}"
  stage_name  = "${var.run_env}"
}
