variable "environment" {
  type        = string
  description = "Environment (e.g. `dev`, `test`, `uat`, `prod`)."
  validation {
    condition     = contains(["dev", "test", "uat", "prod"], var.environment)
    error_message = "Environment must be one of: dev, test, uat, prod."
  }
}
variable "application" {
  type        = string
  description = "Application name"
}

variable "region" {
  type        = string
  default     = ""
  description = "AWS Region Name  (e.g. `us-east-2` or `us-east-1`)."
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

variable "asg_config" {
  description = "consolidated config for autoscaling group"
  type        = any
  default     = {}
}

variable "alb_config" {
  description = "consolidated config for alb"
  type        = any
  default     = {}
}

variable "acm_config" {
  description = "Consolidated ACM configuration"
  type = object({
    hosted_zone_name = string
    certs = map(object({
      domain_name               = string
      subject_alternative_names = optional(list(string), [])
      validation_method         = optional(string, "DNS")
      validate_certificate      = optional(bool, true)
      wait_for_validation       = optional(bool, true)
    }))
  })
}

variable "tags" {
  type = map(map(string))
}