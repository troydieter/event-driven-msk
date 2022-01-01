# Provisions the VPC for MSK

data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az" {
  input = data.aws_availability_zones.available.names
  result_count = 3
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "msk-vpc"
  cidr = "172.16.16.0/20"

  azs             = ["${element(random_shuffle.az.result, 0)}", "${element(random_shuffle.az.result, 1)}", "${element(random_shuffle.az.result, 2)}"]
  private_subnets = ["172.16.16.0/25", "172.16.17.0/25", "172.16.18.0/25"]
  public_subnets  = ["172.16.16.128/25", "172.16.17.128/25", "172.16.18.128/25"]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false
  enable_vpn_gateway = true
  enable_ipv6 = true

  tags = local.common-tags
  public_subnet_tags = {
    connectivity = "public"
  }
  private_subnet_tags = {
    connectivity = "private"
  }
}