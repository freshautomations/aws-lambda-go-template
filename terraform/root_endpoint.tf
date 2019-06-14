resource aws_api_gateway_method root_endpoint {
  rest_api_id   = "${aws_api_gateway_rest_api.lambda.id}"
  resource_id   = "${aws_api_gateway_rest_api.lambda.root_resource_id}"
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method_response" "root_endpoint" {
  depends_on  = ["aws_api_gateway_method.root_endpoint"]
  rest_api_id = "${aws_api_gateway_rest_api.lambda.id}"
  resource_id = "${aws_api_gateway_rest_api.lambda.root_resource_id}"
  http_method = "POST"
  status_code = "200"

  response_models {
    "application/json" = "Empty"
  }
}

resource aws_api_gateway_integration root_endpoint {
  depends_on              = ["aws_api_gateway_method.root_endpoint"]
  rest_api_id             = "${aws_api_gateway_rest_api.lambda.id}"
  resource_id             = "${aws_api_gateway_rest_api.lambda.root_resource_id}"
  http_method             = "POST"
  type                    = "AWS_PROXY"
  integration_http_method = "POST"
  content_handling        = "CONVERT_TO_TEXT"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
}

resource aws_api_gateway_integration_response root_endpoint {
  depends_on  = ["aws_api_gateway_integration.root_endpoint"]
  rest_api_id = "${aws_api_gateway_rest_api.lambda.id}"
  resource_id = "${aws_api_gateway_rest_api.lambda.root_resource_id}"
  http_method = "POST"
  status_code = "200"

  response_templates {
    "application/json" = "Empty"
  }
}

resource "aws_lambda_permission" "root_endpoint" {
  function_name = "${aws_lambda_function.lambda.function_name}"
  statement_id  = "root_endpoint_apigateway_perm"
  action        = "lambda:InvokeFunction"
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:us-east-1:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.lambda.id}/${var.link_prefix}/POST/"
}
