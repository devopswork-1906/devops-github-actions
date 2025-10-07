# Module to create launch template & autoscaling
module "asg" {
  source = "../../"
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
  # Traffic source attachment
  # traffic_source_attachments = {
  #   alb = {
  #     traffic_source_identifier = var.target_group_arns # create an alb/NLB & traget group and point corresponding ARN here
  #     traffic_source_type       = "elbv2"
  #   }
  # }
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
      name                      = "high-memory-utilization-scaling"
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