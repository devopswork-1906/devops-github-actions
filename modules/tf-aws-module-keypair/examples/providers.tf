terraform {
  required_version = ">= 1.8.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.74.0"
    }
  }
  # backend "s3" {
  #   encrypt = "true"
  # }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}
