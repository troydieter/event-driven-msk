# Provisions the KMS key for incoming data

resource "aws_kms_key" "incoming_data_kms_key" {
  description = "Incoming data encryption key"
  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}