# Provisions the Lambda function to handle data sourced from the MSK stream

module "data_platform_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "data_enrichment-processor-${var.environment}-${random_id.rando.hex}"
  description   = "Subscribes to the MSK stream and processes it"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path        = "./src/msk-processor-lambda"
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
        }
    ]
}
EOF

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }

}