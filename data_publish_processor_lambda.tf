# Provisions the Lambda function to handle data sourced from the SQS stream in data enrichment

module "data_publish_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "data_publish-processor-${var.environment}-${random_id.rando.hex}"
  description   = "Subscribes to the data enrichment SQS queue and publishes to the external API"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path        = "./src/data-publish-processor-lambda"
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
              "${module.sqs_encrypted_data_enrichment.sqs_queue_arn}"
              ]
        },
                        {
            "Effect": "Allow",
            "Action": [ 
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
            "Resource": [
              "${aws_kms_key.data_publish_processor_kms_key.id}"
              ]
        }
    ]
}
EOF

  tags = local.common-tags

}