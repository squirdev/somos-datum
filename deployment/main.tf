module lambda {
  source = "../download/target/terraform"
  main_lambda_role_arn = aws_iam_role.lambda.arn
}
