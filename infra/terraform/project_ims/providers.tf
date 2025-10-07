# Providers
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22"
    }
  }
  backend "s3" {
    encrypt = true
  }
}
provider "aws" {
  region = var.region
}