variable "environment" {
  description = "Environment (dev/staging/prod)"
  type        = string
}

variable "application" {
  description = "Application name"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "tags" {
  type    = any
  default = {}
}