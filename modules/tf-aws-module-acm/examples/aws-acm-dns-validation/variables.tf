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

variable "hosted_zone_name" {
  type        = string
  description = "Hosted zone where CNAME of the new cert will be added for validation"
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

variable "tags" {
  type        = map(map(string))
  description = "Tags for different AWS resources"
}