# Provisions the Lambda function to handle SNS subscription

module "incoming_data_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "incoming_data-processor-${var.environment}-${random_id.rando.hex}"
  description   = "Subscribes to the incoming data SQS queue and processes it"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path = "./src/incoming-data-processor-lambda"

  attach_policy_json = true
  policy_json        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "sqs:ReceiveMessage",
              "sqs:DeleteMessage",
              "sqs:GetQueueAttributes"
            ],
            "Resource": [
              "${module.sqs_encrypted_incoming_data.sqs_queue_arn}"
              ]
        }
    ]
}
EOF

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }

  environment_variables = {
    KAFKA_BROKER = aws_msk_cluster.data_platform.bootstrap_brokers
    KAFKA_TOPIC = "test"
  }

  depends_on = [
    aws_msk_cluster.data_platform
  ]

}