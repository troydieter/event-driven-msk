# Provisions the subscriptions

resource "aws_sns_topic_subscription" "sns_processor_sub" {
  topic_arn = module.sns_encrypted_incoming_data.sns_topic_arn
  protocol  = "sqs"
  endpoint  = module.incoming_data_lambda_function.lambda_function_arn
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

# IAM Policies for Lambda execution against MSK

data "aws_iam_policy" "iam_msk_lambda_access" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaMSKExecutionRole"
}

resource "aws_iam_role_policy_attachment" "iam_msk_lambda_access-policy-attach" {
  role       = module.incoming_data_lambda_function.lambda_role_name
  policy_arn = data.aws_iam_policy.iam_msk_lambda_access.arn
}

resource "aws_sqs_queue_policy" "sqs_encrypted_incoming_data" {
    queue_url = module.sqs_encrypted_incoming_data.sqs_queue_id

    policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "${random_id.rando.hex}-sqs_encrypted_incoming_data",
  "Statement": [
    {
      "Sid": "First",
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