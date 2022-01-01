# IAM resources for the MSK Client

resource "aws_iam_instance_profile" "msk_client_profile" {
  name = "msk_client-${random_id.rando.hex}_profile"
  role = aws_iam_role.msk_client.name
}

resource "aws_iam_role" "msk_client" {
  name = "msk_client-${random_id.rando.hex}_role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "msk_client_policy" {
  name        = "msk_client-${random_id.rando.hex}_policy"
  description = "MSK Client Policy"
  policy      = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:Connect",
                "kafka-cluster:AlterCluster",
                "kafka-cluster:DescribeCluster"
            ],
            "Resource": [
                "${aws_msk_cluster.data_platform.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:*Topic*",
                "kafka-cluster:WriteData",
                "kafka-cluster:ReadData"
            ],
            "Resource": [
                "${aws_msk_cluster.data_platform.arn}/*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "kafka-cluster:AlterGroup",
                "kafka-cluster:DescribeGroup"
            ],
            "Resource": [
                "${aws_msk_cluster.data_platform.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "msk_client_policy_attach" {
  name       = "msk_client-${random_id.rando.hex}_policy_attach"
  roles      = ["aws_iam_role.msk_client.name"]
  policy_arn = aws_iam_policy.msk_client_policy.arn
}