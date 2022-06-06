resource "aws_lambda_function" "download" {
  function_name = "SomosDownload"
  s3_bucket = aws_s3_bucket_object.lambda.bucket
  s3_key = aws_s3_bucket_object.lambda.key
  role = aws_iam_role.lambda.arn
  handler = "index.handler"
  # The filebase64sha256() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the base64sha256() function and the file() function:
  # source_code_hash = "${base64sha256(file("lambda_function_payload.zip"))}"
  source_code_hash = filebase64sha256(var.lambda_source)
  runtime = "nodejs12.x"
  timeout = 60
}

resource "aws_cloudwatch_log_group" "example" {
  name = "/aws/lambda/${aws_lambda_function.download.function_name}"
  retention_in_days = 14
}
