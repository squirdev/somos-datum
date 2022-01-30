resource "aws_s3_bucket" "artifacts" {
  bucket = var.artifacts_bucket_name
  // todo: pre-signed url
  acl = "public-read"
  tags = {
    Name = "somos"
    Environment = "prod"
  }
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.artifacts.bucket
  key = "01/01.zip"
  source = var.artifact_01
  # The filemd5() function is available in Terraform 0.11.12 and later
  # For Terraform 0.11.11 and earlier, use the md5() function and the file() function:
  # etag = "${md5(file("path/to/file"))}"
  etag = filemd5(var.artifact_01)
}
