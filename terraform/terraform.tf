provider "aws" {
  region = "us-east-1"
}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "code_permissions" {
  name        = "code_permissions"
  description = "Lambda function permissions"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_policy" "code_policy" {
  name        = "code_policy"
  path        = "/"
  description = "IAM policy for the Lambda function execution"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.lambda.arn}",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda" {
  depends_on = ["aws_iam_policy.code_policy"]
  role       = "${aws_iam_role.code_permissions.name}"
  policy_arn = "${aws_iam_policy.code_policy.arn}"
}

resource aws_lambda_function lambda {
  function_name = "mylambda"

  filename    = "../build/mylambda.zip"
  description = "lambda function"

  handler = "build/aws-lambda-go-template"
  runtime = "go1.x"

  role    = "${aws_iam_role.code_permissions.arn}"
/*
  environment {
    variables {
      "TEMPVAR": "value"
    }
  }
*/
  timeout = "${var.lambda_timeout}"

  tags {
    "Name" = "mylambda"
  }
}

resource aws_cloudwatch_log_group lambda {
  name              = "/aws/lambda/${aws_lambda_function.lambda.function_name}"
  retention_in_days = 30
}

resource aws_api_gateway_rest_api lambda {
  name        = "lambda"
  description = "Lambda API"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "lambda" {
  depends_on        = [
    "aws_api_gateway_integration.root_endpoint"
  ]
  rest_api_id       = "${aws_api_gateway_rest_api.lambda.id}"
  stage_name        = "${var.link_prefix}"
  stage_description = "lambda deployment"
  description       = "Automated Lambda deployment using Terraform"
}
