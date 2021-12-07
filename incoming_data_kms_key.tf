# Provisions the KMS key for incoming data

resource "aws_kms_key" "incoming_data_kms_key" {
  description = "Incoming data encryption key"
  enable_key_rotation = true
  tags        = local.common-tags
}