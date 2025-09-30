variable "env" {
  type        = string
  description = "Environment (e.g. `prod`, `dev`, `uat`)."
  validation {
    condition     = contains(["dev", "test", "prod", "uat"], var.env)
    error_message = "Environment must be one of: dev, test, prod, uat."
  }
}
variable "aws_account_id" {
  type = list(string)
  default = []
  description = "list of allowed account_ids"
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

variable "vpc_cidr" {
  description = "VPC CIDR"
  type        = string
  default     = ""
}

variable "public_subnets_cidr" {
  description = "A list of public subnets inside the VPC"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for cidr in var.public_subnets_cidr : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", cidr))
    ])
    error_message = "Each value in public_subnets_cidr must be a valid CIDR (e.g., 10.0.0.0/24)."
  }
}

variable "private_subnets_cidr" {
  description = "A list of private subnets inside the VPC"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for cidr in var.private_subnets_cidr : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", cidr))
    ])
    error_message = "Each value in private_subnets_cidr must be a valid CIDR (e.g., 10.0.0.0/24)."
  }
}

variable "database_subnets_cidr" {
  description = "A list of database subnets"
  type        = list(string)
  default     = []
  validation {
    condition = alltrue([
      for cidr in var.database_subnets_cidr : can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]+$", cidr))
    ])
    error_message = "Each value in database_subnets_cidr must be a valid CIDR (e.g., 10.0.0.0/24)."
  }
}
