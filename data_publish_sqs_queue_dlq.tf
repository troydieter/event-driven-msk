module "sqs_encrypted_data_publish_dlq" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "data-publish-sqs-dlq-${random_id.rando.hex}-"

  kms_master_key_id           = aws_kms_key.data_enrichment_kms_key.id

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}