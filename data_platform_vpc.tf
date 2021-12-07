# Provisions the VPC for MSK

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "msk-vpc"
  cidr = "172.16.16.0/20"

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["172.16.16.0/25", "172.16.17.0/25", "172.16.18.0/25"]
  public_subnets  = ["172.16.16.128/25", "172.16.17.128/25", "172.16.18.128/25"]

  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = local.common-tags
}