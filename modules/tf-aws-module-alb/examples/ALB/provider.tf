# Providers
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22"
    }
  }
}

provider "aws" {
  region     = var.region
}


data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}
# Route 53
data "aws_route53_zone" "this" {
  name         = var.acm_config.hosted_zone_name
  private_zone = false
}

# VPC and Subnet Discovery based on VPC Name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"] # Replace with your actual VPC name tag
  }
}
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private*"] # Adjust this based on your subnet naming convention
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# ALB
locals {
  app = var.application
  env = var.environment
  alb_config = {
    lb_name             = "${var.environment}-${var.application}-alb"
    security_group_name = "${var.environment}-${var.application}-alb-sg"
  }
  asg_config = {
    autoscaling_group_name      = "${var.environment}-${var.application}-asg"
    instance_name               = "${var.environment}-${var.application}"
    launch_template_name        = "${var.environment}-${var.application}-lt"
    launch_template_description = "Launch template for ${var.environment}-${var.application}-lt"
  }
  common_tags = {
    Application       = var.application
    Environment       = var.environment
    Owner             = "Naveen K"
    Owner_Email       = "devopswork1906@gmail.com"
    snassignmentgroup = "am_gi_technical"
    SNResolver        = "AM GI Technical"
    region            = var.region
    ManagedBy         = "terraform"
    GithubRepo        = "tf-aws-modules-app"
    GithubOrg         = "devopswork-1906"
  }
}

# AMI Lookup from Account
data "aws_ami" "ubuntu_base_image" {
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "tag:type"
    values = ["ubuntu-base"]
  }
  filter {
    name   = "tag:ImageType"
    values = ["base-ami"]
  }
  owners = ["099720109477"]
}