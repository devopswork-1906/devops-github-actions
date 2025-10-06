# Load Balancer
################################################################################
output "lb_id" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.id
}

output "lb_arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = module.alb.arn
}

output "lb_arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = module.alb.arn_suffix
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = module.alb.dns_name
}

output "lb_zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = module.alb.zone_id
}

# Listener(s)
output "lb_listener_arns" {
  description = "Map of listener ARNs, keyed by listener name"
  value       = module.alb.listener_arns
}

output "lb_listener_ids" {
  description = "Map of listener IDs, keyed by listener name"
  value       = module.alb.listener_ids
}

# Target Group(s)
output "lb_target_groups_arn" {
  description = "Map of target group ARNs, keyed by target group name"
  value       = module.alb.target_group_arns
}

output "lb_target_groups_ids" {
  description = "Map of target group IDs, keyed by target group name"
  value       = module.alb.target_group_ids
}

# Security Group
output "lb_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = module.alb.security_group_arn
}

output "lb_security_group_id" {
  description = "ID of the security group"
  value       = module.alb.security_group_id
}

# ACM
######################################
output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "acm_certificate_domain_validation_options" {
  description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used."
  value       = module.acm.acm_certificate_domain_validation_options
}

output "acm_certificate_status" {
  description = "Status of the certificate."
  value       = module.acm.acm_certificate_status
}

output "acm_certificate_validation_emails" {
  description = "A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used."
  value       = module.acm.acm_certificate_validation_emails
}

output "additional_acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.additional_acm.acm_certificate_arn
}

output "additional_acm_certificate_domain_validation_options" {
  description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used."
  value       = module.additional_acm.acm_certificate_domain_validation_options
}

output "additional_acm_certificate_status" {
  description = "Status of the certificate."
  value       = module.additional_acm.acm_certificate_status
}

output "additional_acm_certificate_validation_emails" {
  description = "A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used."
  value       = module.additional_acm.acm_certificate_validation_emails
}

# Autoscaling
####################
output "launch_template_id" {
  description = "The ID of the launch template"
  value       = module.asg.launch_template_id
}

output "launch_template_arn" {
  description = "The ARN of the launch template"
  value       = module.asg.launch_template_arn
}

output "launch_template_name" {
  description = "The name of the launch template"
  value       = module.asg.launch_template_name
}

output "launch_template_latest_version" {
  description = "The latest version of the launch template"
  value       = module.asg.launch_template_latest_version
}

output "launch_template_default_version" {
  description = "The default version of the launch template"
  value       = module.asg.launch_template_default_version
}

output "autoscaling_group_id" {
  description = "The autoscaling group id"
  value       = module.asg.autoscaling_group_id
}

output "autoscaling_group_name" {
  description = "The autoscaling group name"
  value       = module.asg.autoscaling_group_name
}

output "autoscaling_group_arn" {
  description = "The ARN for this AutoScaling Group"
  value       = module.asg.autoscaling_group_arn
}

output "autoscaling_group_min_size" {
  description = "The minimum size of the autoscale group"
  value       = module.asg.autoscaling_group_min_size
}

output "autoscaling_group_max_size" {
  description = "The maximum size of the autoscale group"
  value       = module.asg.autoscaling_group_max_size
}

output "autoscaling_group_desired_capacity" {
  description = "The number of Amazon EC2 instances that should be running in the group"
  value       = module.asg.autoscaling_group_desired_capacity
}

output "autoscaling_group_default_cooldown" {
  description = "Time between a scaling activity and the succeeding scaling activity"
  value       = module.asg.autoscaling_group_default_cooldown
}

output "autoscaling_group_health_check_grace_period" {
  description = "Time after instance comes into service before checking health"
  value       = module.asg.autoscaling_group_health_check_grace_period
}

output "autoscaling_group_health_check_type" {
  description = "EC2 or ELB. Controls how health checking is done"
  value       = module.asg.autoscaling_group_health_check_type
}

output "autoscaling_group_availability_zones" {
  description = "The availability zones of the autoscale group"
  value       = module.asg.autoscaling_group_availability_zones
}

output "autoscaling_group_vpc_zone_identifier" {
  description = "The VPC zone identifier"
  value       = module.asg.autoscaling_group_vpc_zone_identifier
}

output "autoscaling_group_load_balancers" {
  description = "The load balancer names associated with the autoscaling group"
  value       = module.asg.autoscaling_group_load_balancers
}

output "autoscaling_group_target_group_arns" {
  description = "List of Target Group ARNs that apply to this AutoScaling Group"
  value       = module.asg.autoscaling_group_target_group_arns
}

output "autoscaling_schedule_arns" {
  description = "ARNs of autoscaling group schedules"
  value       = module.asg.autoscaling_schedule_arns
}

output "autoscaling_policy_arns" {
  description = "ARNs of autoscaling policies"
  value       = module.asg.autoscaling_policy_arns
}

output "autoscaling_group_enabled_metrics" {
  description = "List of metrics enabled for collection"
  value       = module.asg.autoscaling_group_enabled_metrics
}
