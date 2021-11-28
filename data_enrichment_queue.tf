# Receives data from the data enrichment processor (sourced from MSK) - ready to move towards final processing

module "sqs_encrypted_data_enrichment" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "data-enrichment-sqs-${random_id.rando.hex}-"

  kms_master_key_id           = aws_kms_key.data_enrichment_kms_key.id
  content_based_deduplication = true
  fifo_queue                  = true

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}