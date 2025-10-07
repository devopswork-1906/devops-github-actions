variable "environment" {
  type        = string
  description = "Environment (e.g. `prod`, `dev`, `uat`)."
  validation {
    condition     = contains(["dev", "test", "prod", "uat"], var.environment)
    error_message = "Environment must be one of: dev, test, prod, uat."
  }
}

variable "application" {
  type        = string
  description = "Application name"
}

variable "acm_config" {
  description = "consolidated cofig for acm"
  type        = any
  default     = {}
}

variable "alb_config" {
  description = "consolidated cofig for alb"
  type        = any
  default     = {}
}

variable "asg_config" {
  description = "consolidated cofig for autscaling group"
  type        = any
  default     = {}
}

variable "vpc_name" {
  type        = string
  description = "VPC Name where aws resources will be deployed"
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

variable "tags" {
  type = map(map(string))
}

variable "security_group_ingress_rules" {
  type    = any
  default = {}
}

variable "security_group_egress_rules" {
  type    = any
  default = {}
}