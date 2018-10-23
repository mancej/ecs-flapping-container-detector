output "api_gateway_url" {
  value = "${aws_api_gateway_deployment.gateway_deployment.invoke_url}"
}