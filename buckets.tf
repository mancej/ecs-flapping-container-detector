resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.lambda_bucket_id}"
  acl    = "private"

  tags {
    Name        = "${var.lambda_bucket_id}"
    Environment = "${var.run_env}"
  }
}
