# Provisions the KMS key for MSK CloudWatch data

resource "aws_kms_key" "data_platform_kms_key" {
  description = "Data Platform KMS Key"
  enable_key_rotation = true
  tags        = local.common-tags
}