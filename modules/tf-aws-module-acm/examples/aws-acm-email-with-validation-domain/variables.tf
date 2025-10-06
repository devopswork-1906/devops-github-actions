variable "env" {
  type        = string
  description = "Environment (e.g. `dev`, `test`, `uat`, `prod`)."
  validation {
    condition     = contains(["dev", "test", "prod", "uat"], var.env)
    error_message = "Environment must be one of: dev, test, prod, uat."
  }
}

variable "app" {
  type        = string
  description = "Application name"
}

variable "res" {
  type        = string
  description = "Resource type Ex ec2, s3, iam etc"
}

variable "region" {
  type        = string
  default     = ""
  description = "Name  (e.g. `us-east-2` or `us-east-1`)."
  validation {
    condition     = can(regex("[a-z][a-z]-[a-z]+-[1-9]", var.region))
    error_message = "Must be valid AWS Region names."
  }
}

variable "domain_name" {
  type        = string
  description = "Common Name for cert"
}

variable "subject_alternative_names" {
  description = "A list of domains that should be SANs in the issued certificate"
  type        = list(string)
  default     = []
}

variable "validation_option" {
  description = "The domain name that you want ACM to use to send you validation emails. This domain name is the suffix of the email addresses that you want ACM to use."
  type        = any
  default     = {}
}

variable "tags" {
  type        = map(map(string))
  description = "Tags for different AWS resources"
}