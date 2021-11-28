# Provisions the inbound data Amazon SNS Topic

module "sns_encrypted_incoming_data" {
  source = "terraform-aws-modules/sns/aws"

  name_prefix       = "incoming-data-sns-${random_id.rando.hex}-"
  display_name      = "incoming-data-sns-${random_id.rando.hex}"
  kms_master_key_id = aws_kms_key.incoming_data_kms_key.id
  ############################################################
  # Lambda subscriptions to SNS topics only supports standard topics, not FIFO yet
  # fifo_topic = true
  # content_based_deduplication = true
  ############################################################

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id" = random_id.rando.hex
  }
}