locals {
  common-tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}


data "aws_caller_identity" "current" {}

resource "random_id" "rando" {
  byte_length = 2
}