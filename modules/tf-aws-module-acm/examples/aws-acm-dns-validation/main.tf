###############
# Providers
###############
terraform {
  required_version = ">= 1.5.6"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22"
    }
  }
  # backend "s3" {
  #   encrypt        = "true"
  #   bucket         = "devops-poc-statefiles"
  #   key            = "acm/terraform.tfstate"
  #   region         = "us-east-2"
  #   use_lockfile = true
  # }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

data "aws_route53_zone" "this" {
  name         = var.hosted_zone_name
  private_zone = false
}

##############################
# domain@xyz.com
##############################
module "acm" {
  source                    = "../../"
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  wait_for_validation       = true
  validate_certificate      = true
  validation_method         = "DNS"
  #  zone_id                   = data.aws_route53_zone.this.zone_id # use zone_id if cert has single url. use zones if alternative_names are also there
  zones = {
    "mockdns.devopswork.click"     = data.aws_route53_zone.this.zone_id
    "www.mockdns.devopswork.click" = data.aws_route53_zone.this.zone_id
  }
  tags = merge(var.tags["common_tags"], var.tags["acm"], { "Name" = "${var.env}-${var.app}-${var.res}-dns-valid" })
}
