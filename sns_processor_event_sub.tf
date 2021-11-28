# Provisions the subscription for the SNS processor to the SNS topic

resource "aws_sns_topic_subscription" "sns_processor_sub" {
  topic_arn = module.sns_encrypted_incoming_data.sns_topic_arn
  protocol  = "lambda"
  endpoint  = module.lambda_function.lambda_function_arn
}

resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = module.lambda_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_encrypted_incoming_data.sns_topic_arn
}