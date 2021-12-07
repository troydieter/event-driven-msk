# Provisions the KMS key for data enrichment

resource "aws_kms_key" "data_enrichment_kms_key" {
  description = "Data enrichment encryption key"
  enable_key_rotation = true
  tags        = local.common-tags
}