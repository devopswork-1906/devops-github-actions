# VPC and Subnets
module "vpc" {
  source                             = "../../../modules/tf-aws-module-vpc/"
  name                               = local.vpc_name
  cidr                               = var.vpc_config.vpc_cidr
  azs                                = data.aws_availability_zones.available.names
  public_subnets                     = var.vpc_config.public_subnets_cidr
  private_subnets                    = var.vpc_config.private_subnets_cidr
  database_subnets                   = var.vpc_config.database_subnets_cidr
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true
  tags                               = merge(var.tags["common_tags"], { name = local.vpc_name })
}
