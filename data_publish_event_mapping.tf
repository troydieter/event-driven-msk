# Maps the enrichment / platform Amazon SQS queue to the published Lambda

resource "aws_lambda_event_source_mapping" "data_publish_event_mapping" {
  event_source_arn = module.sqs_encrypted_data_enrichment.sqs_queue_arn
  function_name    = "data_publish-processor-${var.environment}-${random_id.rando.hex}"
  depends_on = [
    module.data_publish_lambda_function
  ]
}