# Provisions the KMS key for incoming data

resource "aws_kms_key" "incoming_data_kms_key" {
  description = "Incoming data encryption key"
  tags        = local.common-tags
}