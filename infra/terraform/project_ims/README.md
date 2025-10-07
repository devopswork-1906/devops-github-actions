# AWS Auto Scaling Group (ASG) module - tf-aws-module-asg

## Table of Contents
---

1. [Overview](#overview)
2. [Features](#features)
3. [Requirements](#requirements)
4. [Use Cases](#use-cases)
    - [Scheduled Scaling](#scheduled-scaling)
    - [Step Scaling Policies](#step-scaling-policies)
    - [Target Tracking Scaling](#target-tracking-scaling)
    - [Predictive Scaling](#predictive-scaling)
    - [Instance Refresh](#instance-refresh)
    - [Lifecycle Hooks](#lifecycle-hooks)
    - [Load Balancer Integration](#load-balancer-integration)
5. [Input Variables](#input-variables)
6. [Sample Auto tf vars](#sample-auto-tf-vars)
7. [Usage](#usage)
8. [Outputs](#outputs)
9. [Notes](#notes)

## Overview
--- 

This Terraform module creates and manages an **AWS Auto Scaling Group (ASG)** with flexible configuration options including:

- EC2 Launch Templates
- Scheduled scaling
- Step scaling based on CPU and memory
- Step scaling, target tracking, and predictive scaling policies
- Lifecycle hooks
- Instance refresh strategies
- Full tagging and metric support
- Dynamic AMI, VPC, and subnet discovery

## Features
---

- Custom launch template:
  - Instance type, profile, and block device mappings
  - IAM role and SSH key
- Auto Scaling Group:
  - Min/max/desired capacity
  - Warm-up and health check settings
  - ASG metrics collection and monitoring
- Scaling Policies:
  - Step scaling (CPU & memory)
  - Target tracking (CPU)
  - Predictive scaling (based on forecast)
- Scheduled actions (scale in/out based on time)
- Lifecycle hooks for graceful launch and termination
- Instance refresh for zero-downtime deployments
- Auto discovery of:
  - AMI based on tags
  - VPC based on name
  - Private subnets in VPC
- Tagging support for ASG, launch template, and shared resources

## Requirements 

| Name         | Version   |
|--------------|-----------|
| Terraform    | >= 1.5.6  |
| AWS Provider | >= 5.22   |

## Use Cases
---
### Scheduled Scaling

Scale capacity based on time-of-day or week:

| Name             | Recurrence         | Min | Desired | Max |
|------------------|--------------------|-----|---------|-----|
| `scale_in_night` | Daily 6 PM         | 1   | 1       | 2   |
| `scale_out_morning` | Daily 6 AM     | 2   | 3       | 3   |
| `weekend_low`    | Saturday midnight  | 1   | 1       | 2   |
| `weekday_peak`   | Weekdays 9 AM      | 2   | 3       | 4   |

Use below code snippet in main.tf to configure Schedules.
```
 #Use Schedule block to configure scheduled scaling actions
  schedules = {
    scale_in_night = {
      scheduled_action_name = "scale-in-night"
      recurrence            = "0 18 * * *" # Every day at 6 PM
      min_size              = 1
      desired_capacity      = 1
      max_size              = 2
    },
    scale_out_morning = {
      scheduled_action_name = "scale-out-morning"
      recurrence            = "0 6 * * *" # Every day at 6 AM
      min_size              = 2
      desired_capacity      = 3
      max_size              = 3
    },
    weekend_low = {
      scheduled_action_name = "weekend-scale-down"
      recurrence            = "0 0 * * 6" # Every Saturday at midnight
      min_size              = 1
      desired_capacity      = 1
      max_size              = 2
    },
    weekday_peak = {
      scheduled_action_name = "weekday-scale-up"
      recurrence            = "0 9 * * 1-5" # Mon-Fri at 9 AM
      min_size              = 2
      desired_capacity      = 3
      max_size              = 4
    }
  }
```

### Step Scaling Policies

- `cpu-based-scale-out`: based on CPU threshold with multiple adjustment levels
- `cpu-based-scale-in`: scales in when CPU drops
- `high-memory-scaling`: scales out when memory exceeds 75% (CloudWatch agent should be configured on Ec2) 

Use below code snippet in main.tf to configure Step scaling policies as per requirement:
```
scaling_policies = {
    cpu-based-scale-out = {
      name                      = "cpu-based-scale-out"
      adjustment_type           = "ExactCapacity"
      policy_type               = "StepScaling"
      estimated_instance_warmup = 120
      alarm_name                = "scaleout-cpu-high" # alarm should be created prior to deploy this module. In this case, it is for high cpu.
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
    cpu-based-scale-in = {
      name                      = "cpu-based-scale-in"
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "StepScaling"
      estimated_instance_warmup = 60
      alarm_name                = "scalein-cpu-low" # alarm should be created prior to deploy this module. In this case, it is for low cpu
      step_adjustment = [
        {
          scaling_adjustment          = -1
          metric_interval_upper_bound = -10
        }
      ]
    }
    high-memory-scaling = {
      name                      = "high-memory-utilization-scaling"
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "StepScaling"
      estimated_instance_warmup = 120
      alarm_name                = "scaleout-memory-high" # alarm should be created prior to deploy this module. In this case, it is for low cpu
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
```

### Target Tracking Scaling
---
Automatically tracks and maintains based on CPU utilization. For below code snippet, it would use built-in `ASGAverageCPUUtilization` metrics. 
- **CPU at ~50%** using built-in `ASGAverageCPUUtilization`

Use below code snippet in main.tf to configure Target Tracking scaling policy as per requirement:
```
 scaling_policies = {
    target-cpu-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    }
  }
```
### Predictive Scaling
---
Uses AWS forecasting models to:
- Anticipate load
- Adjust ASG capacity ahead of demand

Use below code snippet in main.tf to configure Step scaling policies as per requirement(This snippet is based on CPU utilization):
```
predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10
        metric_specification = {
          target_value = 32
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
          }
        }
      }
    }
```

### Instance Refresh

Update instances without downtime using:

- Rolling updates
- Checkpoints and warm-up timers
- Template change triggers
```
 #Use instance_refresh block if needed
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
```

### Lifecycle Hooks

Configure custom scripts/logic during:

- Instance launch (`autoscaling:EC2_INSTANCE_LAUNCHING`)
- Instance termination (`autoscaling:EC2_INSTANCE_TERMINATING`)

```
initial_lifecycle_hooks = [
    {
      name                  = "WaitForAppInitialization"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 120
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "GracefulTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]
```
### Load Balancer Integration

Use below code snippet to integrate load balancer target group with autoscaling group to route external traffic to server configured in autoscaling group:

Note: create an alb/NLB & traget group and point corresponding ARN here

```
 Traffic source attachment
   traffic_source_attachments = {
    alb = {
     traffic_source_identifier = var.target_group_arns # create an alb/NLB & traget group and point corresponding ARN here
     traffic_source_type       = "elbv2"
    }
 }
```

---

## Input Variables

| Name                          | Type         | Description                                  | Example                    |
|-------------------------------|--------------|----------------------------------------------|----------------------------|
| `env`                         | `string`     | Environment name                             | `"dev"`                    |
| `app`                         | `string`     | Application identifier                       | `"ims"`                    |
| `res`                         | `string`     | Resource name prefix                         | `"asg"`                    |
| `region`                      | `string`     | AWS Region                                   | `"us-east-2"`              |
| `vpc_name`                    | `string`     | VPC name for lookup                          | `"demo"`                   |
| `key_name`                    | `string`     | EC2 key pair                                 | `"devops"`                 |
| `instance_type`               | `string`     | EC2 instance type                            | `"t3.medium"`              |
| `iam_instance_profile_name`   | `string`     | IAM instance profile                         | `"poc-admin"`              |
| `security_group_id`           | `string`     | Security group to attach                     | `"sg-045d2f31adbf97b42"`   |
| `instance_name`               | `string`     | Prefix for EC2 instance names                | `"devims"`                 |
| `launch_template_name`        | `string`     | Launch template name                         | `"devims-lt"`              |
| `launch_template_description` | `string`     | Launch template description                  | `"Launch template for ims"`|
| `autoscaling_group_name`      | `string`     | Name of the Auto Scaling Group               | `"dev-ims-asg"`            |
| `health_check_type`           | `string`     | Health check type (`EC2` or `ELB`)           | `"EC2"`                    |
| `tags`                        | `map(any)`   | Common and scoped tags for resources         | See below                  |


## Sample Auto tf vars
---

```hcl
env                         = "dev"
app                         = "ims"
res                         = "asg"
region                      = "us-east-2"
autoscaling_group_name      = "dev-ims-asg"
vpc_name                    = "demo"
key_name                    = "devops"
instance_type               = "t3.medium"
iam_instance_profile_name   = "poc-admin"
security_group_id           = "sg-045d2f31adbf97b42"
instance_name               = "devims"
launch_template_name        = "devims-lt"
launch_template_description = "Launch temple for ims - dev"
health_check_type           = "EC2"

tags = {
  launch_template_tags = {
    Purpose = "autoscaling"
  }
  asg_tags = {
    Application       = "dev"
    Environment       = "ims"
    Owner             = "Naveen K"
    Owner_Email       = "devopswork1906@gmail.com"
    snassignmentgroup = "am_gi_technical"
    SNResolver        = "AM GI Technical"
    region            = "us-east-2"
    ManagedBy         = "terraform"
  }
  common_tags = {
    GithubRepo = "terraform-aws-autoscaling"
    GithubOrg  = "terraform-aws-modules"
  }
}
```

## Usage
---
Please refer below sample code for accomodating all the use cases discussed above.

```hcl
# Providers
terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22"
    }
  }
}
provider "aws" {
  region     = var.region
}
# Data
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}

# AMI Lookup from Account
data "aws_ami" "ubuntu_base_image" {
  most_recent = true
  filter {
    name   = "state"
    values = ["available"]
  }
  filter {
    name   = "tag:type"
    values = ["ubuntu-base"]
  }
  filter {
    name   = "tag:ImageType"
    values = ["base-ami"]
  }
  owners = ["099720109477"]
}

# VPC and Subnet Discovery based on VPC Name
data "aws_vpc" "selected" {
  filter {
    name   = "tag:Name"
    values = ["${var.vpc_name}"] # Replace with your actual VPC name tag
  }
}
data "aws_subnets" "private" {
  filter {
    name   = "tag:Name"
    values = ["private*"] # Adjust this based on your subnet naming convention
  }
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.selected.id]
  }
}

# Module to create launch template & autoscaling
module "asg" {
  source = "https://github.com/devopswork-1906/devops-github-actions/tree/main/modules/tf-aws-module-asg"
  #AutoScalingGroup
  name                      = var.autoscaling_group_name
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  default_instance_warmup   = 300 #in Seconds
  health_check_type         = var.health_check_type
  health_check_grace_period = 300
  vpc_zone_identifier       = data.aws_subnets.private.ids
  launch_template_version   = "$Latest"
  instance_maintenance_policy = {
    min_healthy_percentage = 50
    max_healthy_percentage = 100
  }
  #Use Schedule block to configure scheduled scaling actions
  schedules = {
    scale_in_night = {
      scheduled_action_name = "scale-in-night"
      recurrence            = "0 18 * * *" # Every day at 6 PM
      min_size              = 1
      desired_capacity      = 1
      max_size              = 2
    },
    scale_out_morning = {
      scheduled_action_name = "scale-out-morning"
      recurrence            = "0 6 * * *" # Every day at 6 AM
      min_size              = 2
      desired_capacity      = 3
      max_size              = 3
    },
    weekend_low = {
      scheduled_action_name = "weekend-scale-down"
      recurrence            = "0 0 * * 6" # Every Saturday at midnight
      min_size              = 1
      desired_capacity      = 1
      max_size              = 2
    },
    weekday_peak = {
      scheduled_action_name = "weekday-scale-up"
      recurrence            = "0 9 * * 1-5" # Mon-Fri at 9 AM
      min_size              = 2
      desired_capacity      = 3
      max_size              = 4
    }
  }
  #Use instance_refresh block if needed
  instance_refresh = {
    strategy = "Rolling"
    preferences = {
      checkpoint_delay             = 60 #in Seconds
      checkpoint_percentages       = [20, 40, 100]
      instance_warmup              = 120 #in Seconds
      min_healthy_percentage       = 0
      max_healthy_percentage       = 100
      auto_rollback                = false
      scale_in_protected_instances = "Ignore"
      standby_instances            = "Ignore"
      skip_matching                = false
    }
  }
  autoscaling_group_tags = var.tags["asg_tags"]
  scaling_policies = {
    target-cpu-50 = {
      policy_type               = "TargetTrackingScaling"
      estimated_instance_warmup = 120 #in Seconds
      target_tracking_configuration = {
        predefined_metric_specification = {
          predefined_metric_type = "ASGAverageCPUUtilization"
        }
        target_value = 50.0
      }
    },
    predictive-scaling = {
      policy_type = "PredictiveScaling"
      predictive_scaling_configuration = {
        mode                         = "ForecastAndScale"
        scheduling_buffer_time       = 10 #in Seconds
        max_capacity_breach_behavior = "IncreaseMaxCapacity"
        max_capacity_buffer          = 10 #in Seconds
        metric_specification = {
          target_value = 32
          predefined_scaling_metric_specification = {
            predefined_metric_type = "ASGAverageCPUUtilization"
          }
          predefined_load_metric_specification = {
            predefined_metric_type = "ASGTotalCPUUtilization"
          }
        }
      }
    }
    cpu-based-scale-out = {
      name                      = "cpu-based-scale-out"
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "StepScaling"
      estimated_instance_warmup = 120                 #in Seconds
      alarm_name                = "scaleout-cpu-high" # alarm should be created prior to deploy this module. In this case, it is for high cpu.
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
    cpu-based-scale-in = {
      name                      = "cpu-based-scale-in"
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "StepScaling"
      estimated_instance_warmup = 60
      alarm_name                = "scalein-cpu-low" # alarm should be created prior to deploy this module. In this case, it is for low cpu
      step_adjustment = [
        {
          scaling_adjustment          = -1
          metric_interval_upper_bound = -10
        }
      ]
    }
    high-memory-scaling = {
      name                      = "memory-utilization-high-scaling"
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "StepScaling"
      estimated_instance_warmup = 120
      alarm_name                = "memory-high"
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
  initial_lifecycle_hooks = [
    {
      name                  = "WaitForAppInitialization"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 120
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_LAUNCHING"
      notification_metadata = jsonencode({ "hello" = "world" })
    },
    {
      name                  = "GracefulTerminationLifeCycleHook"
      default_result        = "CONTINUE"
      heartbeat_timeout     = 180
      lifecycle_transition  = "autoscaling:EC2_INSTANCE_TERMINATING"
      notification_metadata = jsonencode({ "goodbye" = "world" })
    }
  ]
  # Traffic source attachment
  # traffic_source_attachments = {
  #   alb = {
  #     traffic_source_identifier = var.target_group_arns # create an alb/NLB & traget group and point corresponding ARN here
  #     traffic_source_type       = "elbv2"
  #   }
  # }
  # Launch Template
  launch_template_name        = var.launch_template_name
  launch_template_description = var.launch_template_description
  update_default_version      = true
  image_id                    = data.aws_ami.ubuntu_base_image.image_id
  instance_name               = var.instance_name
  instance_type               = var.instance_type
  iam_instance_profile_name   = var.iam_instance_profile_name
  key_name                    = var.key_name
  security_groups             = [var.security_group_id]
  ebs_optimized               = true
  enable_monitoring           = true
  enabled_metrics = [
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupInServiceInstances",
    "GroupMaxSize",
    "GroupMinSize",
    "GroupPendingCapacity",
    "GroupPendingInstances",
    "GroupStandbyCapacity",
    "GroupStandbyInstances",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity",
  ]
  #Define block device mapping as per requirement
  block_device_mappings = [
    {
      device_name = "/dev/sda1"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp3"
      }
    },
    {
      device_name = "/dev/xvda"
      ebs = {
        delete_on_termination = true
        encrypted             = true
        volume_size           = 30
        volume_type           = "gp3"
      }
    }
  ]
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 32
  }
  tags                 = var.tags["common_tags"]
  launch_template_tags = var.tags["launch_template_tags"]
}

# Cloud watch Alarm for scale-in and scale-out policy based on CPU utilization
resource "aws_cloudwatch_metric_alarm" "scalein_cpu_low" {
  alarm_name          = "scalein-cpu-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 20
  alarm_description   = "Triggers scale-in when CPU utilization is below 20%"
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
  alarm_actions = [module.asg.autoscaling_policy_arns["cpu-based-scale-in"]]
}
resource "aws_cloudwatch_metric_alarm" "scaleout_cpu_high" {
  alarm_name          = "scaleout-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 70
  alarm_description   = "Triggers scale-out when CPU utilization exceeds 70%"
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
  alarm_actions = [module.asg.autoscaling_policy_arns["cpu-based-scale-out"]]
}
# Cloud watch Alarm for step scaling policy based on memory utilization
resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = 60
  statistic           = "Average"
  threshold           = 75
  alarm_description   = "Triggers when memory usage exceeds 75% for 2 consecutive periods"
  dimensions = {
    AutoScalingGroupName = var.autoscaling_group_name
  }
  alarm_actions = [module.asg.autoscaling_policy_arns["high-memory-scaling"]]
}
```

## Outputs
---

| Output Name                             | Description                                                                 |
|----------------------------------------|-----------------------------------------------------------------------------|
| `launch_template_id`                   | ID of the launch template                                                   |
| `launch_template_arn`                  | ARN of the launch template                                                  |
| `launch_template_name`                 | Name of the launch template                                                 |
| `launch_template_latest_version`       | Latest version of the launch template                                       |
| `launch_template_default_version`      | Default version of the launch template                                      |
| `autoscaling_group_id`                 | ID of the Auto Scaling Group                                                |
| `autoscaling_group_name`               | Name of the Auto Scaling Group                                              |
| `autoscaling_group_arn`                | ARN of the Auto Scaling Group                                               |
| `autoscaling_group_min_size`           | Minimum number of instances                                                 |
| `autoscaling_group_max_size`           | Maximum number of instances                                                 |
| `autoscaling_group_desired_capacity`   | Desired number of instances                                                 |
| `autoscaling_group_default_cooldown`   | Cooldown period between scaling actions                                     |
| `autoscaling_group_health_check_type`  | Type of health check used (`EC2` or `ELB`)                                  |
| `autoscaling_group_health_check_grace_period` | Grace period before health checks begin                             |
| `autoscaling_group_availability_zones` | Availability Zones for the ASG                                              |
| `autoscaling_group_vpc_zone_identifier`| Subnet IDs used by the ASG                                                  |
| `autoscaling_group_load_balancers`     | Classic Load Balancer names associated with the ASG                         |
| `autoscaling_group_target_group_arns`  | Target group ARNs attached to the ASG                                       |
| `autoscaling_schedule_arns`           | ARNs for scheduled scaling actions                                          |
| `autoscaling_policy_arns`             | ARNs for defined scaling policies                                           |
| `autoscaling_group_enabled_metrics`    | List of CloudWatch metrics enabled for the ASG                              |

## Notes

- This Terraform configuration is intended for demonstration purposes only. It is not optimized for production use.
- Simplified for Clarity: Certain configurations (e.g., IAM roles, security groups, logging, monitoring, etc.) may be simplified or omitted to keep the example concise and focused.
- Review and adapt the code to meet your specific requirements and compliance standards before using it in any real environment.