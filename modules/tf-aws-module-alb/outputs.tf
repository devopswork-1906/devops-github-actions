# Load Balancer
output "id" {
  description = "The ID and ARN of the load balancer we created"
  value       = try(aws_lb.this[0].id, null)
}

output "arn" {
  description = "The ID and ARN of the load balancer we created"
  value       = try(aws_lb.this[0].arn, null)
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = try(aws_lb.this[0].dns_name, null)
}

output "arn_suffix" {
  description = "ARN suffix of our load balancer - can be used with CloudWatch"
  value       = try(aws_lb.this[0].arn_suffix, null)
}

output "zone_id" {
  description = "The zone_id of the load balancer to assist with creating DNS records"
  value       = try(aws_lb.this[0].zone_id, null)
}

# Listener(s)

output "listeners" {
  description = "Map of listeners created and their attributes"
  value       = aws_lb_listener.this
}

output "listener_arns" {
  description = "Map of listener ARNs, keyed by listener name"
  value = {
    for name, listener in aws_lb_listener.this :
    name => listener.arn
  }
}

output "listener_ids" {
  description = "Map of listener IDs, keyed by listener name"
  value = {
    for name, listener in aws_lb_listener.this :
    name => listener.id
  }
}

output "listener_rules" {
  description = "Map of listeners rules created and their attributes"
  value       = aws_lb_listener_rule.this
}

# Target Group(s)

output "target_groups" {
  description = "Map of target groups created and their attributes"
  value       = aws_lb_target_group.this
}

output "target_group_arns" {
  description = "Map of target group ARNs, keyed by target group name"
  value = {
    for name, tg in aws_lb_target_group.this :
    name => tg.arn
  }
}

output "target_group_ids" {
  description = "Map of target group IDs, keyed by target group name"
  value = {
    for name, tg in aws_lb_target_group.this :
    name => tg.id
  }
}

output "target_group_attachments" {
  description = "ARNs of the target group attachment IDs"
  value       = { for k, v in aws_lb_target_group_attachment.this : k => v.id }
}

# Security Group

output "security_group_arn" {
  description = "Amazon Resource Name (ARN) of the security group"
  value       = try(aws_security_group.this[0].arn, null)
}

output "security_group_id" {
  description = "ID of the security group"
  value       = try(aws_security_group.this[0].id, null)
}

# Route53 Record(s)
output "route53_records" {
  description = "The Route53 records created and attached to the load balancer"
  value       = aws_route53_record.this
}