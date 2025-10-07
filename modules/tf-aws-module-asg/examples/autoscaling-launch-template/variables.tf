variable "env" {
  type        = string
  description = "Environment (e.g. `prod`, `dev`, `uat`)."
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

variable "key_name" {
  type        = string
  description = "key-pair to be used in launch template for EC2"
}

variable "vpc_name" {
  type        = string
  description = "VPC Name where aws resources will be deployed"
}

variable "instance_type" {
  type        = string
  description = "Instance type of server"
}

variable "iam_instance_profile_name" {
  type        = string
  description = "IAM instance profile name, to be attached with ec2 part of autoscaling group"
}

variable "autoscaling_group_name" {
  description = "Name of the Auto Scaling group"
  type        = string
}

variable "launch_template_name" {
  description = "name of the launch template"
  type        = string
}

variable "launch_template_description" {
  description = "Description for the launch template"
  type        = string
}

variable "instance_name" {
  description = "Name of the EC2 instance"
  type        = string
}

variable "health_check_type" {
  description = "`EC2` or `ELB`. Controls how health checking is done"
  type        = string
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

variable "security_group_id" {
  type        = string
  description = "Security Group ID to be attached with ASG server"
}

variable "tags" {
  type = map(map(string))
}