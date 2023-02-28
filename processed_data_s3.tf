module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = "${random_id.rando.hex}"
  acl    = "private"

  versioning = {
    enabled = true
  }

}