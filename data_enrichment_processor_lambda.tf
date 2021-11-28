# Provisions the Lambda function to handle data sourced from the MSK stream

module "data_platform_lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "data_enrichment-processor-${random_id.rando.hex}"
  description   = "Subscribes to the MSK stream and processes it"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path = "./src/msk-processor-lambda"

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }

}