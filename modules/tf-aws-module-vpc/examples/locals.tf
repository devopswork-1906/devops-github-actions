#This local block will be used for naming and tagging of resources
locals {
  app         = var.application
  env         = var.environment
  region      = var.region
  name_prefix = "${local.env}-${local.app}"
  vpc_config  = merge(var.vpc_config, { name = "${local.name_prefix}-vpc" })
  alb_config  = merge(var.alb_config, { name = "${local.name_prefix}-lb" })
  asg_config = merge(
    var.asg_config, {
      autoscaling_group_name      = "${local.name_prefix}-asg"
      launch_template_name        = "${local.name_prefix}-lt"
      launch_template_description = "Launch template for ${local.name_prefix}-lt"
      instance_name               = "${local.name_prefix}"
  })
  common_tags = {
    Application       = local.app
    Environment       = local.env
    Owner             = "Naveen Kumar"
    Owner_Email       = "devopswork1906@gmail.com"
    snassignmentgroup = "am_gi_technical"
    SNResolver        = "AM GI Technical"
    region            = local.region
    ManagedBy         = "terraform"
    GithubOrg         = "devopswork-1906"
  }
}