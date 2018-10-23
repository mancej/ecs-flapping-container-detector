# Comment this bucket out if you don't want to create a new bucket, but instead want to use an existing one.
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${var.lambda_bucket_id}"
  acl    = "private"

  tags {
    Name        = "${var.lambda_bucket_id}"
    Environment = "${var.run_env}"
  }
}
