module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket_prefix = random_id.rando.hex
  acl           = "private"

  versioning = {
    enabled = true
  }

  # Object lock / governance coming soon
#  object_lock_enabled = true
#  object_lock_configuration = {
#    rule = {
#      default_retention = {
#        mode = "GOVERNANCE"
#        days = 14
#      }
#    }
#  }

  # Lifecycle rules coming soon
  #  lifecycle_rule = [
  #    {
  #    }
  #  ]




  tags = local.common-tags

}