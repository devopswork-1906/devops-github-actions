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

#ACM
output "acm_certs" {
  value = {
    for k, m in module.acm : k => m.acm_certificate_arn
  }
}
# # VPC
# ############################################################
output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}
output "private_subnets" {
  description = "List of IDs of private subnets"
  value       = module.vpc.private_subnets
}
output "public_subnets" {
  description = "List of IDs of public subnets"
  value       = module.vpc.public_subnets
}
output "database_subnets" {
  description = "List of IDs of database subnets"
  value       = module.vpc.database_subnets
}
output "vpc_cidr_block" {
  description = "VPC CIDR"
  value       = module.vpc.vpc_cidr_block
}
output "nat_public_ips" {
  description = "List of public Elastic IPs created for AWS NAT Gateway"
  value       = module.vpc.nat_public_ips
}
output "database_route_table_ids" {
  description = "List of IDs of database route tables"
  value       = module.vpc.database_route_table_ids
}
output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}
output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "vpc_default_security_group" {
  value = module.vpc.default_security_group_id
}

########### ALB

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
