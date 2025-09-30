locals {
  env                    = var.environment
  app                    = var.application
  log_bucket_name        = "${local.env}-${local.app}-statefiles-bucket-logs"
  statefiles_bucket_name = "${local.env}-${local.app}-tf-statefiles"
  dynamodb_table_name    = "${local.env}-${local.app}-tf-lock"
  common_tags = {
    Application       = local.app
    Environment       = local.env
    Owner             = "Naveen Kumar"
    Owner_Email       = "devopswork1906@gmail.com"
    snassignmentgroup = "am_gi_technical"
    SNResolver        = "AM GI Technical"
    region            = var.aws_region
    ManagedBy         = "terraform"
    GithubOrg         = "devopswork-1906"
  }
  statefile_log_bucket_tags = merge(
    local.common_tags,
    {
      Name        = local.log_bucket_name
      Description = "S3 bucket for ${local.env} ${local.app} statefiles logs"
    }
  )
  statefiles_bucket_tags = merge(
    local.common_tags,
    {
      Name        = local.statefiles_bucket_name
      Description = "S3 bucket for ${local.env} ${local.app} terraform statefiles"
    }
  )
  dynamodb_tags = merge(
    local.common_tags,
    {
      Name        = local.dynamodb_table_name
      Description = "DynamoDB state lock table for ${local.env} ${local.app}"
    }
  )
}