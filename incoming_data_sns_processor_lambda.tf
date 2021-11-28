# Provisions the Lambda function to handle SNS subscription

module "lambda_function" {
  source = "terraform-aws-modules/lambda/aws"

  function_name = "sns-processor-${random_id.rando.hex}"
  description   = "Subscribes to the incoming data SNS topic and processes it"
  handler       = "index.handler"
  runtime       = "python3.8"

  source_path = "./src/sns-processor-lambda"

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id" = random_id.rando.hex
  }

}