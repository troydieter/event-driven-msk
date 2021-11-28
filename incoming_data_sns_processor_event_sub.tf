# Provisions the subscription for the SNS processor to the SNS topic

resource "aws_sns_topic_subscription" "sns_processor_sub" {
  topic_arn = module.sns_encrypted_incoming_data.sns_topic_arn
  protocol  = "sqs"
  endpoint  = module.sqs_encrypted_incoming_data.sqs_queue_arn
}