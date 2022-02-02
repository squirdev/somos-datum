data "aws_caller_identity" "current" {}

variable "deployment_id" {
  ### increment to force deployment
  default = "2"
}
resource "aws_api_gateway_rest_api" "api" {
  name = "SomosDownload"
}

resource "aws_api_gateway_resource" "resource" {
  path_part = "resource"
  parent_id = aws_api_gateway_rest_api.api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.api.id
}

resource "aws_api_gateway_method" "post" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.download.invoke_arn
}

resource "aws_lambda_permission" "apigw_lambda" {
  statement_id = "AllowExecutionFromAPIGateway"
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.download.function_name
  principal = "apigateway.amazonaws.com"
  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:us-west-2:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*/${aws_api_gateway_method.post.http_method}${aws_api_gateway_resource.resource.path}"
}

resource "aws_api_gateway_deployment" "deploy" {
  depends_on = [
    aws_api_gateway_resource.resource,
    aws_s3_bucket.lambda,
    aws_lambda_function.download
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name = lower(terraform.workspace)
  variables = {
    // force deployment
    "answer" = var.deployment_id
  }
}
