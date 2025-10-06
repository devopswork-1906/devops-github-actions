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
  region = var.region
}
# Data
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

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