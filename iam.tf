# Role Declaration & Attachments
resource "aws_iam_role" "flapping_container_detector" {
  name               = "ecs-flapping-container-detector"
  assume_role_policy = "${file("${path.module}/policies/assume_role.json")}"
}

resource "aws_iam_role_policy_attachment" "flapping_container_detector_attachment" {
  policy_arn = "${aws_iam_policy.flapping_container_detector_policy.arn  }"
  role       = "${aws_iam_role.flapping_container_detector.name}"
}

resource "aws_iam_role_policy_attachment" "flapping_container_ssm_read_access_attachment" {
  policy_arn = "${aws_iam_policy.flapping_container_ssm_read_access.arn  }"
  role       = "${aws_iam_role.flapping_container_detector.name}"
}

resource "aws_iam_role_policy_attachment" "flapping_container_dynamo_rw_attachment" {
  policy_arn = "${aws_iam_policy.flapping_dynamo_rw_policy.arn  }"
  role       = "${aws_iam_role.flapping_container_detector.name}"
}

# Generic lambda access
data "template_file" "flapping_container_vpc_lambda_policy" {
  template = "${file("${path.module}/policies/non_vpc_lambda.json.tpl")}"
}

resource "aws_iam_policy" "flapping_container_detector_policy" {
  name   = "ecs-flapping-container-detector-generic"
  policy = "${data.template_file.flapping_container_vpc_lambda_policy.rendered}"
}

# Parameter Store access
data "template_file" "flapping_container_parameter_store_read" {
  template = "${file("${path.module}/policies/ssm_lambda_access.json.tpl")}"

  vars {
    account_id = "${data.aws_caller_identity.current.account_id}"
    region     = "${var.default_region}"
  }
}

resource "aws_iam_policy" "flapping_container_ssm_read_access" {
  name   = "ecs-flapping-ssm-read"
  policy = "${data.template_file.flapping_container_parameter_store_read.rendered}"
}

# R/W To Dynamo Tables
resource "aws_iam_policy" "flapping_dynamo_rw_policy" {
  name   = "ecs-flapping-container-dynamo-access"
  policy = "${data.template_file.flapping_dynamo_rw_template.rendered}"
}

data "template_file" "flapping_dynamo_rw_template" {
  template = "${file("${path.module}/policies/dynamo_rw.json.tpl")}"

  vars {
    account_id   = "${data.aws_caller_identity.current.account_id}"
    region       = "${var.default_region}"
    dynamo_table = "${aws_dynamodb_table.ecs_service_metrics.name}"
  }
}
