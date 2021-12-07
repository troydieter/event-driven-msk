# Provisions the S3 bucket for MSK broker logs

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-msk-logs"
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = {
    "project"     = "${lower("${var.aws-profile}")}-event-driven-msk"
    "environment" = var.environment
    "id"          = random_id.rando.hex
  }

}