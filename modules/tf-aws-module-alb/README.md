# Terraform Module: AWS Load Balancer

## Table of Contents

- [Overview](#overview)
- [Features](#Features)
- [Requirements](#Requirements)
- [Usage](#usage)
  - [Application Load Balancer](#application-load-balancer)
  - [Network Load Balancer](#network-load-balancer)
- [Inputs](#inputs)
- [Outputs](#outputs)
- [Notes](#notes)

## Overview

This Terraform module creates and manages AWS Load Balancers (Application or Network or Gateway) with support for:

- Multiple listeners and listener rules
- Target group creation (HTTP, HTTPS, TCP, UDP)
- Weighted target group forwarding
- Integration with external target groups via `target_group_arns`
- SSL/TLS certificates (ACM/Manual)
- Cross-zone load balancing for ALB & NLB
- Access logs configuration
- Deletion protection
- Custom health checks
- Optional Security group creation (only for ALB)

## Features

- **Supports multiple LB types**: Application (`application`), Network (`network`), and Gateway (`gateway`).
- Dynamic Listener Creation (HTTP, HTTPS, TCP, UDP)
- Option to create or reuse an existing security group (for ALB).
- **Listener configuration** with multiple actions: forward, redirect, fixed-response, weighted-forward.
- **Advanced conditions** – Path patterns, host headers, HTTP methods, query strings, and source IPs.
- **SSL termination** – HTTPS with ACM-managed certificates and configurable SSL policy.
- Supports multiple **Target group creation** with flexible protocols and health checks.
- **Access logs** configuration (S3 bucket & prefix).
- **Deletion protection** toggle.
- **Cross-zone load balancing** toggle.
- **Support for IPv4 and dual-stack**.
- **Attach existing target groups** via ARNs or create new ones.
- **Weighted forwarding** to multiple target groups.
- Outputs useful LB details like ARN, DNS name, security group IDs, and target group ARNs.
- WAFv2 integration – Associate with existing AWS WAFv2 WebACL.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.6 |
| aws | >= 5.22 |

## Usage

### Application Load Balancer

This is just a sample code. Please refer to example forlder for actual use case.

```hcl


module "alb" {
  # Path to your ALB module
  source = "../../tf-aws-module-alb"
  # Ensures ACM certificates are created before ALB
  depends_on = [module.acm, module.additional_acm]
  # Core ALB settings
  name                       = local.alb_config.lb_name          # Unique ALB name (per environment)
  load_balancer_type         = var.alb_config.load_balancer_type # "application" or "network"
  internal                   = var.alb_config.internal           # true for internal ALB, false for internet-facing
  subnets                    = data.aws_subnets.private.ids      # ALB subnets
  enable_deletion_protection = false                             # Disable deletion protection for testing
  # Security Group rules (for POC; in prod , we will be using SG module)
  security_group_ingress_rules = var.alb_config.security_group_ingress_rules
  security_group_egress_rules  = var.alb_config.security_group_egress_rules
  # Listeners
  listeners = {
    # HTTP listener to redirect all traffic to HTTPS
    http-to-https-redirect = {
      port     = 80
      protocol = "HTTP"
      redirect = {
        port        = "443"
        protocol    = "HTTPS"
        status_code = "HTTP_301"
      }
    }

    # HTTPS listener
    https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.additional_acm.acm_certificate_arn]
      forward = {
        target_group_key = "tg-1" # Default action forwards to TG-1
      }
    }
  }
  # Target Groups
  target_groups = {
    tg-1 = {
      name                              = "${var.environment}-${var.application}-tg-1"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      vpc_id                            = data.aws_vpc.selected.id
      deregistration_delay              = 10
      load_balancing_algorithm_type     = "round_robin"
      load_balancing_anomaly_mitigation = "off" #load_balancing_anomaly_mitigation should be off for round_robin, should be on for weighted_random
      load_balancing_cross_zone_enabled = false
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/healthz"
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "HTTP"
        matcher             = "200-399"
      }
      protocol_version = "HTTP1"
      target_id        = aws_instance.server1.id # this should be pointing to server/autoscalings
      port             = 80
      tags = {
        InstanceTargetGroupTag = "baz"
      }
    }
  }
  # Tags (merged from shared and resource-specific)
  tags = var.tags["alb_tags"]
}
```

### Network Load Balancer


## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `create` | Controls if resources should be created (affects nearly all resources) | `any` | n/a | yes |
| `tags` | A map of tags to add to all resources | `map(string)` | n/a | yes |
| `access_logs` | Map containing access logging configuration for load balancer. | `map(any)` | n/a | yes |
| `connection_logs` | Map containing access logging configuration for load balancer | `map(any)` | n/a | yes |
| `ipam_pools` | The IPAM pools to use with the load balancer | `list(string)` | n/a | yes |
| `client_keep_alive` | Client keep alive value in seconds. The valid range is 60-604800 seconds. The default is 3600 seconds. | `number` | n/a | yes |
| `customer_owned_ipv4_pool` | The ID of the customer owned ipv4 pool to use for this load balancer | `string` | n/a | yes |
| `desync_mitigation_mode` | Determines how the load balancer handles requests that might pose a security risk to an application due to HTTP desync. Valid values are `monitor`, `defensive` (default), `strictest` | `string` | n/a | yes |
| `dns_record_client_routing_policy` | Indicates how traffic is distributed among the load balancer Availability Zones. Only valid for network type load balancers. | `string` | n/a | yes |
| `drop_invalid_header_fields` | Whether invalid HTTP headers are removed or routed to targets. Only valid for `application` type. | `bool` | n/a | yes |
| `enable_cross_zone_load_balancing` | Enables cross-zone load balancing. Always `true` for application load balancers. | `bool` | n/a | yes |
| `enable_deletion_protection` | Disables deletion via API if set to `true`. | `bool` | n/a | yes |
| `enable_http2` | Whether HTTP/2 is enabled in ALB. | `bool` | n/a | yes |
| `enable_tls_version_and_cipher_suite_headers` | Adds TLS version/cipher headers for ALB. | `bool` | n/a | yes |
| `enable_waf_fail_open` | Allows routing when WAF fails. | `bool` | n/a | yes |
| `enable_xff_client_port` | Preserves source port in X-Forwarded-For header (ALB). | `bool` | n/a | yes |
| `enable_zonal_shift` | Whether zonal shift is enabled. | `bool` | n/a | yes |
| `idle_timeout` | Idle timeout in seconds (ALB only). | `number` | n/a | yes |
| `internal` | Whether the LB is internal. | `bool` | n/a | yes |
| `ip_address_type` | `ipv4` or `dualstack`. | `string` | n/a | yes |
| `load_balancer_type` | `application`, `gateway`, or `network`. | `string` | n/a | yes |
| `enforce_security_group_inbound_rules_on_private_link_traffic` | Whether SG inbound rules apply to PrivateLink traffic. (NLB only) | `string` | n/a | yes |
| `minimum_load_balancer_capacity` | Minimum capacity (ALB/NLB only). | `number` | n/a | yes |
| `name` | Unique LB name (max 32 chars). | `string` | n/a | yes |
| `name_prefix` | Prefix for LB name (conflicts with `name`). | `string` | n/a | yes |
| `preserve_host_header` | Preserves Host header (ALB). | `bool` | n/a | yes |
| `security_groups` | List of security group IDs. | `list(string)` | n/a | yes |
| `subnet_mapping` | List of subnet mapping blocks. | `list(map(string))` | n/a | yes |
| `subnets` | List of subnet IDs. | `list(string)` | n/a | yes |
| `xff_header_processing_mode` | How to modify X-Forwarded-For header. | `string` | n/a | yes |
| `timeouts` | Timeout configuration map. | `map(string)` | n/a | yes |
| `default_port` | Default port for listener/target group. | `number` | n/a | yes |
| `default_protocol` | Default protocol for listener/target group. | `string` | n/a | yes |
| `listeners` | Map of listener configurations. | `map(any)` | n/a | yes |
| `target_groups` | Map of target group configurations. | `map(any)` | n/a | yes |
| `additional_target_group_attachments` | Map of extra target group attachments. | `map(any)` | n/a | yes |
| `create_security_group` | Whether to create a security group. | `bool` | n/a | yes |
| `security_group_name` | Name for created security group. | `string` | n/a | yes |
| `security_group_use_name_prefix` | Whether SG name is a prefix. | `bool` | n/a | yes |
| `security_group_description` | Description for created SG. | `string` | n/a | yes |
| `vpc_id` | VPC ID for created SG. | `string` | n/a | yes |
| `security_group_ingress_rules` | Ingress rules for created SG. | `list(map(string))` | n/a | yes |
| `security_group_egress_rules` | Egress rules for created SG. | `list(map(string))` | n/a | yes |
| `security_group_tags` | Additional tags for created SG. | `map(string)` | n/a | yes |
| `route53_records` | Map of Route53 records to create. | `map(any)` | n/a | yes |
| `associate_web_acl` | Whether to associate WAF ACL. | `bool` | n/a | yes |
| `web_acl_arn` | WAF ARN for association. | `string` | n/a | yes |
## Outputs

| Name                     | Description                                                  |
|--------------------------|--------------------------------------------------------------|
| `id`                     | The ID and ARN of the load balancer we created               |
| `arn`                    | The ID and ARN of the load balancer we created               |
| `dns_name`               | The DNS name of the load balancer                             |
| `arn_suffix`             | ARN suffix of our load balancer - can be used with CloudWatch |
| `zone_id`                | The zone_id of the load balancer to assist with creating DNS records |
| `listeners`              | Map of listeners created and their attributes                |
| `listener_arns`          | Map of listener ARNs, keyed by listener name                  |
| `listener_ids`           | Map of listener IDs, keyed by listener name                   |
| `listener_rules`         | Map of listeners rules created and their attributes           |
| `target_groups`          | Map of target groups created and their attributes             |
| `target_group_arns`      | Map of target group ARNs, keyed by target group name           |
| `target_group_ids`       | Map of target group IDs, keyed by target group name            |
| `target_group_attachments` | ARNs of the target group attachment IDs                     |
| `security_group_arn`     | Amazon Resource Name (ARN) of the security group              |
| `security_group_id`      | ID of the security group                                      |
| `route53_records`        | The Route53 records created and attached to the load balancer |

## Notes
-	Weighted Forwarding is only available for Application Load Balancers. Weighted forwarding requires actions with multiple target_groups and weight values.
-	If using HTTPS, ensure an ACM certificate is available in the same region.
-	Target group protocols must match listener protocols in supported combinations.
- WAFv2 is only supported for ALB.
- Ensure the subnets belong to the same VPC.
- For detailed use case, please refer example folder