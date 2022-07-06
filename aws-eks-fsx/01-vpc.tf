################################################################################
# Provider: AWS Provider Configuration
################################################################################
provider "aws" {
  region = var.region
}

################################################################################
# Data Sources: AWS Availability Zones
################################################################################
data "aws_availability_zones" "available" {
  state = "available"
}

################################################################################
# Resources: random_pet
################################################################################
resource "random_pet" "prefix" {
  length = 1
}

resource "random_id" "suffix" {
  byte_length = 1
}

################################################################################
# Module: AWS VPC Module Configurations
################################################################################
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 3.14.0"

  name                 = "vpc-${local.environment_name}"
  cidr                 = var.vpc_cidr
  azs                  = local.sliced_availability_zones
  private_subnets      = [for k, v in "${local.sliced_availability_zones}" : cidrsubnet("${var.vpc_cidr}", 8, k + 10)]
  public_subnets       = [for k, v in "${local.sliced_availability_zones}" : cidrsubnet("${var.vpc_cidr}", 8, k + 20)]
  enable_nat_gateway   = true
  single_nat_gateway   = true
  enable_dns_hostnames = true # enable_dns_support is set to true by default

  tags = {
    "kubernetes.io/cluster/${local.environment_name}" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/${local.environment_name}" = "shared"
    "kubernetes.io/role/elb"                          = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${local.environment_name}" = "shared"
    "kubernetes.io/role/internal-elb"                 = "1"
  }
}