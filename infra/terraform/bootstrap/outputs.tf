output "log_bucket_name" {
  value = aws_s3_bucket.statefile_log_bucket.id
}

output "statefiles_bucket_name" {
  value = aws_s3_bucket.statefiles_bucket.id
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock_table.name
}