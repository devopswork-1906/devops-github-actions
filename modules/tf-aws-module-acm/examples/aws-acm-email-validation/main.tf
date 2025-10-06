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

##############################
# domain@xyz.com
##############################
module "acm" {
  source                    = "../../"
  domain_name               = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  wait_for_validation       = false
  validate_certificate      = false
  validation_method         = "EMAIL"
  tags                      = merge(var.tags["common_tags"], var.tags["acm"], { "Name" = "${var.env}-${var.app}-${var.res}-email-valid" })
}