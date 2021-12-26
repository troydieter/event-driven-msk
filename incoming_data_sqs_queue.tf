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

  tags = local.common-tags
}

resource "aws_sqs_queue_policy" "incoming_data" {
  queue_url = module.sqs_encrypted_incoming_data.sqs_queue_id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sqspolicy",
  "Statement": [
    {
      "Sid": "AllowSNSSQS",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${module.sqs_encrypted_incoming_data.sqs_queue_arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${module.sns_encrypted_incoming_data.sns_topic_arn}"
        }
      }
    }
  ]
}
POLICY
}