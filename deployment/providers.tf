variable "aws_region" {
  description = "AWS region to launch service in."
  default     = "us-west-2"
}

variable "aws_secret_key_id" {
  description = "AWS secret key ID"
}

variable "aws_secret_key" {
  description = "AWS secret key"
}

provider "aws" {
  access_key = var.aws_secret_key_id
  secret_key = var.aws_secret_key
  region     = var.aws_region
}
