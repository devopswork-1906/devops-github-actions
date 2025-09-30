# Terraform Module: EC2 Auto Scaling Group

## Table of Contents

- [Overview](#overview)
- [Features](#Features)
- [Requirements](#Requirements)
- [Usage](#usage)
- [Inputs](#inputs)
- [Outputs](#outputs)
## Overview

This Terraform module creates and manages an Amazon EC2 Auto Scaling Group (ASG) with support for:

- Launch Templates or Launch Configurations
- Mixed Instance Policies
- Lifecycle hooks
- Scaling policies and scheduled actions
- Metrics collection
- Target tracking and step-based policies
- Load Balancer (Classic or ALB/NLB) integration
- Instance refresh strategies
- Predictive scaling (for advanced use cases)
## Features

- Highly customizable Auto Scaling Group (ASG)
- Support for mixed instance types and multiple purchase options (spot/on-demand)
- Flexible Launch Template configuration with EBS, user_data, IAM roles, etc.
- Instance Refresh with Rolling Updates
- Scheduled scaling and dynamic scaling policies
- Target Tracking, Step Scaling, and Scheduled Scaling Policies
- Integration with ALB/NLB or Classic ELB
- CloudWatch metrics and alarms for Auto Scaling Group health
- Output-rich for inter-module referencing
- Optional instance protection and lifecycle hooks
- Predictive scaling (optional)
- Lifecycle Hooks support (e.g. for pre-termination logic)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.6 |
| aws | >= 5.22 |

## Usage

```hcl
module "asg" {
  source = "../../../tf-aws-module-asg"

  #AutoScalingGroup
  name                      = var.autoscaling_group_name
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  default_instance_warmup   = 300
  health_check_type         = "EC2"
  health_check_grace_period = 300
  vpc_zone_identifier       = data.aws_subnets.private.ids
  launch_template_name        = var.launch_template_name
  launch_template_description = var.launch_template_description
  image_id                    = data.aws_ami.ubuntu_base_image.image_id
  instance_type               = var.instance_type
  instance_name               = var.instance_name
  key_name                    = var.key_name
  security_groups             = [var.security_group_id]
  iam_instance_profile_name   = var.iam_instance_profile_name
  update_default_version      = true
  ebs_optimized     = true
  enable_monitoring = true
  instance_maintenance_policy = {
    min_healthy_percentage = 50
    max_healthy_percentage = 100
  }
  schedules = {
    scale_in_night = {
      scheduled_action_name = "scale-in-night"
      recurrence            = "0 18 * * *"
      min_size              = 1
      desired_capacity      = 1
      max_size              = 2
    }
  }

  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay             = 60
      checkpoint_percentages       = [20, 40, 100]
      instance_warmup              = 120
      min_healthy_percentage       = 0
      max_healthy_percentage       = 100
      auto_rollback                = false
      scale_in_protected_instances = "Ignore"
      standby_instances            = "Ignore"
      skip_matching                = false
    }
    triggers = ["launch_template"]
  }
  scaling_policies = {
    target-cpu-50 = {
      policy_type = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50
      }
    }
    scale-out = {
      name                      = "scale-out"
      policy_type               = "StepScaling"
      adjustment_type           = "ExactCapacity"
      estimated_instance_warmup = 120
      alarm_name                = "scaleout-cpu-high"
      step_adjustment = [
        {
          scaling_adjustment          = 1
          metric_interval_lower_bound = 0
          metric_interval_upper_bound = 10
        },
        {
          scaling_adjustment          = 2
          metric_interval_lower_bound = 10
        }
      ]
    }
  }
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        volume_size           = 30
        volume_type           = "gp3"
        delete_on_termination = true
        encrypted             = true
      }
    }
  ]
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }
  initial_lifecycle_hooks = [
    {
      name                  = "WaitForAppInitialization"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 120
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    }
  ]
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]
  tags                 = var.tags["common_tags"]
  launch_template_tags = var.tags["launch_template_tags"]
  autoscaling_group_tags = var.tags["asg_tags"]
}
```

## Inputs

| Name                         | Description                                                               | Type             | Default | Required |
|------------------------------|---------------------------------------------------------------------------|------------------|---------|----------|
| `name`                       | Name of the Auto Scaling Group                                            | `string`         | n/a     | yes      |
| `image_id`                   | AMI ID for launch template                                                | `string`         | n/a     | yes      |
| `instance_type`              | Instance type                                                             | `string`         | n/a     | yes      |
| `vpc_zone_identifier`        | List of subnet IDs                                                        | `list(string)`   | n/a     | yes      |
| `vpc_id`                     | VPC ID where the Auto Scaling group will launch instances                   | `string`                  | n/a         | Yes      |
| `subnet_ids`                 | List of subnet IDs for the Auto Scaling group                               | `list(string)`            | n/a         | Yes      |
| `desired_capacity`           | Desired number of EC2 instances                                           | `number`         | n/a     | yes      |
| `min_size`                   | Minimum size of ASG                                                       | `number`         | n/a     | yes      |
| `max_size`                   | Maximum size of ASG                                                       | `number`         | n/a     | yes      |
| `health_check_type`          | Health check type ("EC2" or "ELB")                                        | `string`         | `"EC2"` | no       |
| `health_check_grace_period`  | Time in seconds before checking health                                    | `number`         | `300`   | no       |
| `enable_monitoring`          | Enable detailed monitoring                                                | `bool`           | `true`  | no       |
| `enable_metrics_collection`  | Enable CloudWatch metrics collection                                      | `bool`           | `true`  | no       |
| `metrics_granularity`        | Metrics granularity (only `1Minute` supported)                            | `string`         | `null`  | no       |
| `autoscaling_schedule`       | Map of autoscaling schedules                                              | `map(any)`       | `{}`    | no       |
| `instance_refresh`           | Instance refresh configuration                                            | `any`            | `null`  | no       |
| `launch_template_name`       | Name for the launch template                                                | `string`                  | `null`      | No       |
| `key_name`                   | EC2 Key pair name                                                           | `string`                  | `null`      | No       |
| `security_group_ids`         | List of security group IDs                                                  | `list(string)`            | `[]`        | No       |
| `iam_instance_profile`       | IAM instance profile name                                                   | `string`                  | `null`      | No       |
| `ebs_optimized`              | If true, the launched EC2 instance will be EBS optimized                    | `bool`                    | `false`     | No       |
| `associate_public_ip_address`| Associate a public IP address                                               | `bool`                    | `false`     | No       |
| `block_device_mappings`      | List of block device mappings                                               | `any`                     | `[]`        | No       |
| `metadata_options`           | Metadata options for EC2 instance                                           | `map(string)`             | `{}`        | No       |
| `mixed_instance_policy`      | Enable mixed instances and provide overrides                                | `any`                     | `null`      | No       |
| `termination_policies`       | Policies to decide which instances to terminate                             | `list(string)`            | `[]`        | No       |
| `placement_group`            | Name of the placement group                                                 | `string`                  | `null`      | No       |
| `suspended_processes`        | List of processes to suspend for the ASG                                    | `list(string)`            | `[]`        | No       |
| `enabled_metrics`            | List of metrics to collect                                                  | `list(string)`            | `[]`        | No       |
| `scale_in_policy`            | Configuration for scale in policy                                           | `map(any)`                | `{}`        | No       |
| `scale_out_policy`           | Configuration for scale out policy                                          | `map(any)`                | `{}`        | No       |
| `schedule_actions`           | List of scheduled scaling actions                                           | `list(any)`               | `[]`        | No       |
| `tags`                       | Map of tags to apply                                                        | `map(string)`             | `{}`        | No       |
## Outputs

| Name                                | Description                                           |
|-------------------------------------|-------------------------------------------------------|
| `launch_template_id`                | The ID of the launch template                         |
| `launch_template_name`              | The name of the launch template                       |
| `launch_template_arn`               | The ARN of the launch template                        |
| `launch_template_latest_version`    | The latest version of the launch template             |
| `launch_template_default_version`   | The default version of the launch template            |
| `autoscaling_group_id`              | The ID of the Auto Scaling Group                      |
| `autoscaling_group_name`            | The name of the Auto Scaling Group                    |
| `autoscaling_group_arn`             | The ARN of the Auto Scaling Group                     |
| `autoscaling_group_min_size`        | Minimum size of the Auto Scaling Group                |
| `autoscaling_group_max_size`        | Maximum size of the Auto Scaling Group                |
| `autoscaling_group_desired_capacity`| Desired capacity of the Auto Scaling Group            |
| `autoscaling_group_availability_zones`| Availability zones for the ASG                      |
| `autoscaling_group_vpc_zone_identifier`| Subnets for the ASG                              |
| `autoscaling_group_enabled_metrics` | Enabled CloudWatch metrics                            |
| `autoscaling_group_load_balancers`  | Load balancers attached to the ASG                    |
| `autoscaling_group_target_group_arns`| Target group ARNs attached to the ASG               |
| `autoscaling_schedule_arns`         | Schedule ARNs                                         |
| `autoscaling_policy_arns`           | Autoscaling policy ARNs                               |

## Notes

- Make sure to create the proper IAM policies if your ASG needs access to SSM, CloudWatch, etc.
- If using Target Groups, ensure the health check is configured appropriately.
- Use `instance_refresh` with caution as it will replace instances.
- create Alarm before configuring in scaling policy