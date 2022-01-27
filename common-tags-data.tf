locals {
  common-tags = {
    "project"     = "event-processor"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}


data "aws_caller_identity" "current" {}

resource "random_id" "rando" {
  byte_length = 2
}

resource "random_integer" "rando_int" {
  min = 1
  max = 100
}