locals {
  common-tags = {
    "project"     = "${upper("${substr("${var.aws-profile}", 0, 3)}")}-event-driven-msk"
    "environment" = var.environment
  }
}


data "aws_caller_identity" "current" {}
