# Provisions the KMS key for data enrichment

resource "aws_kms_key" "data_enrichment_kms_key" {
  description = "Data enrichment encryption key"
  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}