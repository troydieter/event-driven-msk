# Provisions the KMS key for MSK CloudWatch data

resource "aws_kms_key" "data_platform_kms_key" {
  description = "${random_id.rando.hex}-data_platform_kms_key"
  enable_key_rotation = true
  policy = <<EOF
{
  "Version" : "2012-10-17",
  "Id" : "${random_id.rando.hex}-data_platform_kms_key",
  "Statement" : [ {
      "Sid" : "Enable IAM User Permissions",
      "Effect" : "Allow",
      "Principal" : {
        "AWS" : "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      },
      "Action" : "kms:*",
      "Resource" : "*"
    },
    {
      "Effect": "Allow",
      "Principal": { "Service": "logs.${var.aws_region}.amazonaws.com" },
      "Action": [ 
        "kms:Encrypt*",
        "kms:Decrypt*",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:Describe*"
      ],
      "Resource": "*"
    }  
  ]
}
EOF
  tags        = local.common-tags
}