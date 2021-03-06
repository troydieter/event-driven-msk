# Provisions the inbound data Amazon SNS Topic

module "sns_encrypted_incoming_data" {
  source = "terraform-aws-modules/sns/aws"

  name_prefix                 = "incoming-data-sns-${random_id.rando.hex}-"
  display_name                = "incoming-data-sns-${random_id.rando.hex}"
  kms_master_key_id           = aws_kms_key.incoming_data_kms_key.id
  fifo_topic                  = true
  content_based_deduplication = true
  tags                        = local.common-tags
}