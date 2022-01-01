# Provisions a MSK Client

# AMI Info
data "aws_ami" "amazon-linux-2" {
  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
}

locals {
  user_data = <<-EOF

#!/bin/bash
yum -y update
yum -y install git 
yum install -y https://s3.us-east-1.amazonaws.com/amazon-ssm-us-east-1/latest/linux_amd64/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent
systemctl start amazon-ssm-agent
git clone https://github.com/aws-samples/amazon-msk-client-authentication.git /tmp/amazon-msk-client-authentication

  
  EOF
}

# SSH Keypair
variable "generated_key_name" {
  type        = string
  default     = "msk-client-key-pair"
  description = "Key-Pair used for MSK Client authentication"
}

resource "tls_private_key" "client_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.generated_key_name
  public_key = tls_private_key.client_key.public_key_openssh

  provisioner "local-exec" {
    command = <<EOT
      echo '${tls_private_key.client_key.private_key_pem}' > ./'${var.generated_key_name}'.pem
      chmod 400 ./'${var.generated_key_name}'.pem
EOT
  }

}

# Security Group

resource "aws_security_group" "msk_client" {
  name_prefix = "${var.cluster_name}-client-${random_id.rando.hex}"
  vpc_id      = module.vpc.vpc_id
  description = "${var.cluster_name}-${var.environment}-client-${random_id.rando.hex}-sg"
}

resource "aws_security_group_rule" "msk-client" {
  description       = "${var.cluster_name}-${var.environment}-client-${random_id.rando.hex}"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.msk_client.id
  type              = "ingress"
  cidr_blocks       = var.cidr_blocks
}

module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "~> 3.0"

  name = "msk-client-${random_id.rando.hex}"

  ami                         = data.aws_ami.amazon-linux-2.id
  instance_type               = "t3.small"
  key_name                    = var.generated_key_name
  monitoring                  = true
  vpc_security_group_ids      = ["${aws_security_group.msk_client.id}"]
  subnet_id                   = module.vpc.public_subnets[0]
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.msk_client_profile.name
  user_data_base64            = base64encode(local.user_data)

  tags = local.common-tags
}

resource "aws_eip" "msk_client" {
  vpc = true

  instance                  = module.ec2_instance.id
  associate_with_private_ip = module.ec2_instance.private_ip
  depends_on = [
    module.vpc,
    module.ec2_instance
  ]
  tags = local.common-tags
}

output "pubip" {
  value       = aws_eip.msk_client.public_ip
  description = "Public IP Address for the MSK Client"
}

output "clientarn" {
  value       = module.ec2_instance.arn
  description = "ARN of the MSK Client"
}