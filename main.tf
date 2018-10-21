# Backend
terraform {
  backend "local" {
    path = "states/dev/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}

# Providers
provider "aws" {
  alias  = "dynamo_env"
  region = "${var.default_region}"
  profile = "${var.dynamo_profile}"
}

provider "aws" {
  region = "${var.default_region}"
  profile = "${var.default_profile}"
}
