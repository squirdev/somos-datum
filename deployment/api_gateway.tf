data "aws_caller_identity" "current" {}

variable "deployment_id" {
  ### increment to force deployment
  default = "1"
}
resource "aws_api_gateway_rest_api" "api" {
  name = "SomosDownload"
}

########################################################################################################################
## POST Method #########################################################################################################
########################################################################################################################

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

########################################################################################################################
## CORS (Mock Method) ##################################################################################################
########################################################################################################################
resource "aws_api_gateway_method" "cors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.cors.http_method
  type = "MOCK"
  depends_on = [
    aws_api_gateway_method.cors]
  passthrough_behavior = "WHEN_NO_TEMPLATES"
  request_templates = {
    "application/json" = <<EOF
    {
      statusCode: 200
    }
    EOF
  }
}

resource "aws_api_gateway_method_response" "cors" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = "200"
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
  depends_on = [
    aws_api_gateway_method.cors]
}

resource "aws_api_gateway_integration_response" "cors" {
  depends_on = [
    aws_api_gateway_integration.cors
  ]
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_resource.resource.id
  http_method = aws_api_gateway_method.cors.http_method
  status_code = aws_api_gateway_method_response.cors.status_code
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
  }
}

########################################################################################################################
## Deployment ##########################################################################################################
########################################################################################################################

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
