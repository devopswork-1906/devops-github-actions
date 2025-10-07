# VPC and Subnets
module "vpc" {
  source                             = "../"
  name                               = local.vpc_config.name
  cidr                               = local.vpc_config.vpc_cidr
  azs                                = data.aws_availability_zones.available.names
  public_subnets                     = local.vpc_config.public_subnets_cidr
  private_subnets                    = local.vpc_config.private_subnets_cidr
  database_subnets                   = local.vpc_config.database_subnets_cidr
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true
  vpc_tags                           = merge(local.common_tags, { name = local.vpc_config.name })
  tags                               = var.tags
}
