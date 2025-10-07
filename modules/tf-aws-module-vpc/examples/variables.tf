variable "environment" {
  type        = string
  description = "Environment (e.g. `prod`, `dev`, `uat`)."
  validation {
    condition     = contains(["dev", "test", "prod", "uat"], var.environment)
    error_message = "Environment must be one of: dev, test, prod, uat."
  }
}
variable "aws_account_id" {
  type        = list(string)
  default     = []
  description = "list of allowed account_ids"
}
variable "application" {
  type        = string
  description = "Application name"
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

variable "vpc_config" {
  description = "consolidated config for vpc"
  type        = any
  default     = {}
}
variable "alb_config" {
  description = "consolidated config for alb"
  type        = any
  default     = {}
}
variable "asg_config" {
  description = "consolidated config for autoscaling group"
  type        = any
  default     = {}
}
variable "tags" {
  type    = any
  default = {}
}