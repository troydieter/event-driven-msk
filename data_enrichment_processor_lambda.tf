# Provisions the Lambda function to handle data sourced from the MSK stream

module "data_platform_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "data_enrichment-processor-${var.environment}-${random_id.rando.hex}"
  description   = "Subscribes to the MSK stream and processes it"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path        = "./src/data-enrichment-processor-lambda"
  attach_policy_json = true
  policy_json        = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "kafka:*"
            ],
            "Resource": [
              "${aws_msk_cluster.data_platform.arn}",
              "${aws_msk_cluster.data_platform.arn}/*"
              ]
        },
                {
            "Effect": "Allow",
            "Action": [
              "SQS:Receive*",
              "SQS:Send*"
            ],
            "Resource": [
              "${module.sqs_encrypted_data_enrichment.sqs_queue_arn}",
              "${module.sqs_encrypted_data_enrichment.sqs_queue_arn}/*"
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
              "${aws_kms_key.data_enrichment_kms_key.arn}"
              ]
        },
        {
            "Effect": "Allow",
            "Action": [ 
        "ec2:CreateNetworkInterface",
        "ec2:DescribeNetworkInterfaces",
        "ec2:DescribeVpcs",
        "ec2:DeleteNetworkInterface",
        "ec2:DescribeSubnets",
        "ec2:DescribeSecurityGroups"
      ],
            "Resource": [ "*" ]
        }
    ]
}
EOF

  tags = local.common-tags

}