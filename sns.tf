# Provisions the inbound data Amazon SNS Topic

resource "aws_kms_key" "sns_kms_key" {}

module "sns_encrypted_incoming_data" {
  source = "terraform-aws-modules/sns/aws"

  name_prefix       = "incoming-data-"
  display_name      = "incoming-data"
  kms_master_key_id = aws_kms_key.sns_kms_key.id

  tags = {
    "project"     = "${upper("${substr("${var.aws-profile}", 0, 3)}")}-event-driven-msk"
    "environment" = var.environment
  }
}