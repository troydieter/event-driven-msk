# Provisions the IAM roles and policies for feedback in CloudWatch
resource "aws_iam_role" "sns_topic_role" {
  name = "sns_topic_role-${random_id.rando.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "sns.amazonaws.com"
        }
      },
    ]
  })

  tags = local.common-tags
}

resource "aws_iam_role_policy" "sns_topic_feedback" {
  name = "sns_feedback_policy-${random_id.rando.hex}"
  role = aws_iam_role.sns_topic_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:PutMetricFilter",
          "logs:PutRetentionPolicy"
        ],
        "Resource" : [
          "*"
        ]
      }
    ]
  })

}

# Provisions the inbound data Amazon SNS Topic

module "sns_encrypted_incoming_data" {
  source = "terraform-aws-modules/sns/aws"

  name_prefix                      = "incoming-data-sns-${random_id.rando.hex}-"
  display_name                     = "incoming-data-sns-${random_id.rando.hex}"
  kms_master_key_id                = aws_kms_key.incoming_data_kms_key.id
  fifo_topic                       = true
  content_based_deduplication      = true
  sqs_success_feedback_role_arn    = aws_iam_role.sns_topic_role.arn
  sqs_failure_feedback_role_arn    = aws_iam_role.sns_topic_role.arn
  sqs_success_feedback_sample_rate = "100"

  tags = local.common-tags
}