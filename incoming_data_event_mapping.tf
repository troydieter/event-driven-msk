# Provisions the subscriptions

resource "aws_sns_topic_subscription" "sns_processor_sub" {
  topic_arn = module.sns_encrypted_incoming_data.sns_topic_arn
  protocol  = "sqs"
  endpoint  = module.sqs_encrypted_incoming_data.sqs_queue_arn
}

resource "aws_lambda_event_source_mapping" "sqs_processor_lambda_event_mapping" {
  event_source_arn = module.sqs_encrypted_incoming_data.sqs_queue_arn
  function_name    = module.incoming_data_lambda_function.lambda_function_arn
}

resource "aws_lambda_permission" "allow_sqs_invoke" {
  statement_id  = "AllowExecutionFromSQS"
  action        = "lambda:InvokeFunction"
  function_name = "incoming_data-processor-${var.environment}-${random_id.rando.hex}"
  principal     = "sqs.amazonaws.com"
  source_arn    = module.sqs_encrypted_incoming_data.sqs_queue_arn
  depends_on = [
    module.incoming_data_lambda_function
  ]
}