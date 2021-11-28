module "sqs_encrypted_incoming_data" {
  source = "terraform-aws-modules/sqs/aws"

  name_prefix = "incoming-data-sqs-${random_id.rando.hex}-"

  kms_master_key_id           = aws_kms_key.incoming_data_kms_key.id
  content_based_deduplication = true
  fifo_queue                  = true
  redrive_policy              = <<EOF
  {
      "maxReceiveCount": 3,
      "deadLetterTargetArn": "${module.sqs_encrypted_incoming_data_dlq.sqs_queue_arn}"
  }
  EOF

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }
}