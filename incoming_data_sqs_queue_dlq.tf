module "sqs_encrypted_incoming_data_dlq" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "incoming-data-sqs-dlq-${random_id.rando.hex}-"

  # kms_master_key_id           = aws_kms_key.incoming_data_kms_key.id
  content_based_deduplication = true
  fifo_queue                  = true

  tags = local.common-tags
}