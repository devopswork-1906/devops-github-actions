# VPC and Subnets
module "vpc" {
  source                             = "../../tf-aws-module-vpc"
  name                               = "${var.env}-${var.app}"
  cidr                               = var.vpc_cidr
  azs                                = data.aws_availability_zones.available.names
  public_subnets                     = var.public_subnets_cidr
  private_subnets                    = var.private_subnets_cidr
  database_subnets                   = var.database_subnets_cidr
  enable_nat_gateway                 = true
  single_nat_gateway                 = true
  one_nat_gateway_per_az             = false
  create_database_subnet_route_table = true
  create_database_nat_gateway_route  = true
  vpc_tags                           = merge(module.labels.tags, { "Name" = "${var.env}-${var.app}-vpc" })
  tags                               = var.tags
}
