# Provisions the MSK Secret Association

resource "aws_msk_scram_secret_association" "data_platform_secret_associate" {
  cluster_arn     = aws_msk_cluster.data_platform.arn
  secret_arn_list = [aws_secretsmanager_secret.data_platform_secret.arn]
  depends_on = [
    aws_secretsmanager_secret_version.data_platform_secret,
    aws_msk_cluster.data_platform
  ]
}

resource "aws_secretsmanager_secret" "data_platform_secret" {
  name       = "AmazonMSK_secret_${random_id.rando.hex}"
  kms_key_id = aws_kms_key.data_platform_kms_key.key_id
}

resource "aws_secretsmanager_secret_version" "data_platform_secret" {
  secret_id     = aws_secretsmanager_secret.data_platform_secret.id
  secret_string = jsonencode({ username = "t_user", password = "majic" })
}

resource "aws_secretsmanager_secret_policy" "data_platform" {
  secret_arn = aws_secretsmanager_secret.data_platform_secret.arn
  policy     = <<POLICY
{
  "Version" : "2012-10-17",
  "Statement" : [ {
    "Sid": "AWSKafkaResourcePolicy",
    "Effect" : "Allow",
    "Principal" : {
      "Service" : "kafka.amazonaws.com"
    },
    "Action" : "secretsmanager:getSecretValue",
    "Resource" : "${aws_secretsmanager_secret.data_platform_secret.arn}"
  } ]
}
POLICY
}