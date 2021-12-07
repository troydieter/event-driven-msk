# Receives data from the data enrichment processor (sourced from MSK) - ready to move towards final processing

module "sqs_encrypted_data_enrichment" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "data-enrichment-sqs-${random_id.rando.hex}-"

  kms_master_key_id           = aws_kms_key.data_enrichment_kms_key.id
  content_based_deduplication = true
  fifo_queue                  = true

  redrive_policy = <<EOF
  {
      "maxReceiveCount": 3,
      "deadLetterTargetArn": "${module.sqs_encrypted_incoming_data_dlq.sqs_queue_arn}"
  }
  EOF

  tags = local.common-tags
}