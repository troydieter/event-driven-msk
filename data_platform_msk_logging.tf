# Provisions the S3 bucket for MSK broker logs

module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}-msk-logs"
  acl    = "private"

  versioning = {
    enabled = true
  }

  tags = local.common-tags
}

resource "aws_cloudwatch_log_group" "msk-cw-loggroup" {
  name       = "${var.cluster_name}-${var.environment}-${random_id.rando.hex}"
  kms_key_id = aws_kms_key.data_platform_kms_key.arn
  tags       = local.common-tags
}