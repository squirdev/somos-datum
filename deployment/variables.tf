variable "domain_name" {
  description = "url"
  default = "store.somos.world"
}

variable "lambda_bucket_name" {
  description = "bucket name"
  default = "somos-download-lambda"
}

variable "lambda_source" {
  description = "source"
  default = "../download/function.zip"
}

variable "artifacts_bucket_name" {
  description = "bucket name"
  default = "somos-download-artifacts"
}

variable "artifact_01" {
  description = "source"
  default = "artifacts/01/01.zip"
}
