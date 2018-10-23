# Backend
terraform {
  backend "local" {
    path = "states/dev/terraform.tfstate"
  }
}

data "aws_caller_identity" "current" {}

# Providers
provider "aws" {
  region = "${var.default_region}"
  profile = "${var.default_profile}"
}
