#This local block will be used for naming and tagging of resources
locals {
  app                     = var.application
  env                     = var.environment
  region                  = var.region
  vpc_name                = "${local.env}-${local.app}-vpc"
  alb_name                = "${local.env}-${local.app}-alb"
  alb_security_group_name = "${local.env}-${local.app}-alb-sg"
  key_name                = "${local.env}${local.app}key"
  asg_config = merge(
    var.asg_config, {
      autoscaling_group_name      = "${local.env}-${local.app}-asg"
      launch_template_name        = "${local.env}-${local.app}-lt"
      launch_template_description = "Launch template for ${local.env}-${local.app}-lt"
      instance_name               = "${local.env}${local.app}"
  })
}