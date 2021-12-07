module "sqs_encrypted_data_enrichment_dlq" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "${random_id.rando.hex}-data-enrichment-sqs-dlq"

  kms_master_key_id           = aws_kms_key.data_enrichment_kms_key.id
  content_based_deduplication = true
  fifo_queue                  = true

  tags = local.common-tags
}