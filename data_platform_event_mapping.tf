# Maps Amazon MSK to a Lambda function

resource "aws_lambda_event_source_mapping" "decision_processor_event_mapping" {
  event_source_arn  = aws_msk_cluster.data_platform.arn
  function_name     = "data_enrichment-processor-${var.environment}-${random_id.rando.hex}"
  topics            = var.platform_topic
  starting_position = "LATEST"
}