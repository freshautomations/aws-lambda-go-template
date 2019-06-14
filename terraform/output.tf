output "lambda_base_url" {
  value = "${aws_api_gateway_deployment.lambda.invoke_url}"
}
