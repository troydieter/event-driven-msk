# Provisions the Lambda function to handle data sourced from the SQS stream in data enrichment

module "data_publish_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "data_publish-processor-${var.environment}-${random_id.rando.hex}"
  description   = "Subscribes to the data enrichment SQS queue and publishes to the external API"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path = "./src/sqs-processor-lambda"

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }

}