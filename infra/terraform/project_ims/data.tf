# Data
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

# data block to fetch hosted zone id based on hosted zone name
data "aws_route53_zone" "this" {
  name         = var.acm_config.hosted_zone_name
  private_zone = false
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
