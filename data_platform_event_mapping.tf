# Maps Amazon MSK to a Lambda function

resource "aws_lambda_event_source_mapping" "decision_processor_event_mapping" {
  event_source_arn  = aws_msk_cluster.data_platform.arn
  function_name     = "data_enrichment-processor-${var.environment}-${random_id.rando.hex}"
  topics            = var.platform_topic
  starting_position = "LATEST"
}

resource "aws_lambda_permission" "allow_msk_invoke" {
  statement_id  = "AllowExecutionFromMSK"
  action        = "lambda:InvokeFunction"
  function_name = "data_enrichment-processor-${var.environment}-${random_id.rando.hex}"
  principal     = "msk.amazonaws.com"
  source_arn    = module.data_platform_lambda_function.lambda_function_arn
  depends_on = [
    module.data_platform_lambda_function
  ]
}