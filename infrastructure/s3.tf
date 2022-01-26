resource "aws_s3_bucket" "code" {
  bucket        = "${local.prefix}-lambda-code"
  force_destroy = true
}