# s3 statefiles Log Bucket
resource "aws_s3_bucket" "statefile_log_bucket" {
  bucket = local.log_bucket_name
  tags   = local.statefile_log_bucket_tags
}
resource "aws_s3_bucket_server_side_encryption_configuration" "log_bucket_sse" {
  bucket = aws_s3_bucket.statefile_log_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "log_bucket_versioning" {
  bucket = aws_s3_bucket.statefile_log_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_public_access_block" "log_bucket_public_access" {
  bucket                  = aws_s3_bucket.statefile_log_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
# Statefiles Bucket
resource "aws_s3_bucket" "statefiles_bucket" {
  bucket = local.statefiles_bucket_name
  tags   = local.statefiles_bucket_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "statefiles_bucket_sse" {
  bucket = aws_s3_bucket.statefiles_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
resource "aws_s3_bucket_versioning" "statefiles_bucket_versioning" {
  bucket = aws_s3_bucket.statefiles_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}
resource "aws_s3_bucket_logging" "statefiles_bucket_logging" {
  bucket        = aws_s3_bucket.statefiles_bucket.id
  target_bucket = aws_s3_bucket.statefile_log_bucket.id
  target_prefix = "${local.env}-${local.app}/"
}

resource "aws_s3_bucket_public_access_block" "statefiles_bucket_public_access" {
  bucket                  = aws_s3_bucket.statefiles_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# DynamoDB Table
resource "aws_dynamodb_table" "terraform_lock_table" {
  name         = local.dynamodb_table_name
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = local.dynamodb_tags
}