# Provisions the Lambda function to handle SNS subscription

module "incoming_data_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "incoming_data-processor-${var.environment}-${random_id.rando.hex}"
  description   = "Subscribes to the incoming data SQS queue and processes it"
  handler       = "index.handler"
  runtime       = "python3.8"
  timeout       = 30
  source_path   = "./src/incoming-data-processor-lambda"
  environment_variables = {
    "BUCKET_NAME" = module.s3_bucket.s3_bucket_bucket_domain_name
    "RANDO_ID" = random_id.rando.hex
  }

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
              "${aws_kms_key.incoming_data_kms_key.arn}"
              ]
        },
      {
            "Effect": "Allow",
              "Action": [
              "s3:*"
      ],
            "Resource": [
              "${module.s3_bucket.s3_bucket_arn}",
              "${module.s3_bucket.s3_bucket_arn}/*"
              ]
        },
      {
            "Effect": "Allow",
              "Action": [
              "s3:List*"
      ],
            "Resource": "*"
        }
    ]
}
EOF

  tags = local.common-tags

  depends_on = [
    module.sqs_encrypted_incoming_data
  ]

}