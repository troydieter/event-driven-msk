module "sqs_encrypted_incoming_data_dlq" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "incoming-data-sqs-dlq-${random_id.rando.hex}-"

  kms_master_key_id = aws_kms_key.incoming_data_kms_key.id

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}