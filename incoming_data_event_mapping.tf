# Provisions the subscriptions

resource "aws_sns_topic_subscription" "sns_processor_sub" {
  topic_arn = module.sns_encrypted_incoming_data.sns_topic_arn
  protocol  = "lambda"
  endpoint  = module.incoming_data_lambda_function.lambda_function_arn
}

# IAM Policies for Lambda execution against MSK

data "aws_iam_policy" "iam_msk_lambda_access" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

resource "aws_lambda_permission" "iam_msk_lambda_access-sns" {
  statement_id  = "${random_id.rando.hex}-iam_msk_lambda_access-sns"
  action        = "lambda:InvokeFunction"
  function_name = module.incoming_data_lambda_function.lambda_function_name
  principal     = "sns.amazonaws.com"
  source_arn    = module.sns_encrypted_incoming_data.sns_topic_arn
}

resource "aws_iam_role_policy_attachment" "iam_msk_lambda_access-policy-attach" {
  role       = module.incoming_data_lambda_function.lambda_role_name
  policy_arn = data.aws_iam_policy.iam_msk_lambda_access.arn
}