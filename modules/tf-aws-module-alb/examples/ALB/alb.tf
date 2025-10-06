# Application Load Balancer Module Usage - Full Example

module "alb" {
  source = "../../../tf-aws-module-alb/"
  # Ensures ACM certificates are created before ALB
  #depends_on = [module.asg, module.acm, module.additional_acm]
  # Core ALB settings
  name                       = local.alb_config.lb_name          # Unique ALB name (per environment)
  load_balancer_type         = var.alb_config.load_balancer_type # "application" or "network"
  internal                   = var.alb_config.internal           # true for internal ALB, false for internet-facing
  subnets                    = data.aws_subnets.private.ids      # ALB subnets
  enable_deletion_protection = false                             # Disable deletion protection for testing
  # Security Group rules (for POC; in prod , we will be using SG module)
  security_group_name          = local.alb_config.security_group_name
  security_group_ingress_rules = var.alb_config.security_group_ingress_rules
  security_group_egress_rules  = var.alb_config.security_group_egress_rules
  # Connection tuning
  client_keep_alive = 3600 # Seconds to keep connections alive
  idle_timeout      = 3600 # Idle timeout in seconds

  # Optional: Access and Connection logs
  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  #   prefix = "access-logs"
  # }
  # connection_logs = {
  #   bucket  = module.log_bucket.s3_bucket_id
  #   enabled = true
  #   prefix  = "connection-logs"
  # }

  # Optional: IPAM pool allocation
  # ipam_pools = {
  #   ipv4_ipam_pool_id = aws_vpc_ipam_pool.this.id
  # }

  # Optional: Minimum load balancer capacity units
  # minimum_load_balancer_capacity = {
  #   capacity_units = 2
  # }
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

    # HTTPS listener with multiple rules (configure rule as per requirement, I have added all the option here for quick reference)
    https = {
      port                        = 443
      protocol                    = "HTTPS"
      ssl_policy                  = "ELBSecurityPolicy-TLS13-1-2-Res-2021-06"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.additional_acm.acm_certificate_arn]
      forward = {
        target_group_key = "tg-1" # Default action forwards to TG-1
      }

      # HTTPS listener rules
      rules = {
        # Fixed response rule triggered by HTTP header
        fixed-response = {
          priority = 1
          actions = [{
            type         = "fixed-response"
            content_type = "text/plain"
            status_code  = 200
            message_body = "Hi IMS Team"
          }]
          conditions = [{
            http_header = {
              http_header_name = "x-Gimme-Fixed-Response"
              values           = ["yes", "please", "right now"]
            }
          }]
        }

        # Redirect rule based on query string parameters
        redirect = {
          priority = 2
          actions = [{
            type        = "redirect"
            status_code = "HTTP_302"
            host        = "www.youtube.com"
            path        = "/watch"
            query       = "v=Xrgk023l4lI"
            protocol    = "HTTPS"
          }]
          conditions = [{
            query_string = [
              { key = "video", value = "random1" },
              { key = "image", value = "next" }
            ]
          }]
        }
        # Forward rule for ASG targets (This rule will route traffic to TG-3, which has autoscaling group as targets)
        forward-asg = {
          priority = 3
          actions = [{
            type             = "forward"
            target_group_key = "tg-2"
          }]
          conditions = [{
            path_pattern = {
              values = ["/app*", "/web*"]
            }
          }]
        }
        forward-host_header = {
          priority = 4
          actions = [{
            type             = "forward"
            target_group_key = "tg-2"
          }]
          conditions = [{
            host_header = {
              values = ["www.google.com"]
            }
          }]
        }
        forward-source_ip = {
          priority = 5
          actions = [{
            type             = "forward"
            target_group_key = "tg-3"
          }]
          conditions = [{
            source_ip = {
              values = ["10.0.0.0/8", "11.11.11.0/24"]
            }
          }]
        }
        forward-http_request_method = {
          priority = 6
          actions = [{
            type             = "forward"
            target_group_key = "tg-2"
          }]
          conditions = [{
            http_request_method = {
              values = ["GET", "POST"]
            }
          }]
        }
        weighted-forward = {
          priority = 7
          actions = [{
            type = "weighted-forward"
            target_groups = [
              { target_group_key = "tg-1", weight = 60 },
              { target_group_key = "tg-2", weight = 40 }
            ]
            stickiness = {
              enabled  = true
              duration = 300
            }
          }]
          conditions = [{
            path_pattern = {
              values = ["/xyz*"]
            }
          }]
        }
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
      target_id        = aws_instance.server1.id
      port             = 80
      tags = {
        InstanceTargetGroupTag = "tg-1"
      }
    }
    tg-2 = {
      name                              = "${var.environment}-${var.application}-tg-2"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      vpc_id                            = data.aws_vpc.selected.id
      deregistration_delay              = 10
      load_balancing_algorithm_type     = "round_robin"
      load_balancing_anomaly_mitigation = "off"
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
      target_id        = aws_instance.server2.id
      port             = 80
      tags = {
        InstanceTargetGroupTag = "tg-2"
      }
    }
    # Here I have commented line 197, As I am not adding a any server as targets
    # will be configuring arn of this target group ARN in autoscaling group configuration
    tg-3 = {
      name                              = "${var.environment}-${var.application}-tg-3"
      protocol                          = "HTTP"
      port                              = 80
      target_type                       = "instance"
      vpc_id                            = data.aws_vpc.selected.id
      deregistration_delay              = 10
      load_balancing_algorithm_type     = "round_robin"
      load_balancing_anomaly_mitigation = "off"
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
      # target_id        = aws_instance.server1.id  # Optional: can be attached via ASG      
      # port = 80
      tags = {
        InstanceTargetGroupTag = "autoscaling"
      }
    }
  }

  # Additional targets for existing target groups
  additional_target_group_attachments = [
    { target_group_key = "tg-1", target_id = aws_instance.server2.id, port = 81 },
    { target_group_key = "tg-1", target_id = aws_instance.server2.id, port = 85 },
    { target_group_key = "tg-2", target_id = aws_instance.server1.id, port = 85 }
  ]
  # Route53 Records (optional)
  route53_records = {
    A = {
      name    = local.alb_config.lb_name
      type    = "A"
      zone_id = data.aws_route53_zone.this.id
    }
    AAAA = {
      name    = local.alb_config.lb_name
      type    = "AAAA"
      zone_id = data.aws_route53_zone.this.id
    }
  }
  # Tags (merged from shared and resource-specific)
  tags = merge(var.tags["alb_tags"], local.common_tags)
}

# Demo EC2 Instances for Target Groups
# Added these code for testing module. Should be removed in actual usage.
resource "aws_instance" "server1" {
  ami           = data.aws_ami.ubuntu_base_image.id
  instance_type = "t3.nano"
  subnet_id     = element(data.aws_subnets.private.ids, 0)
}

resource "aws_instance" "server2" {
  ami           = data.aws_ami.ubuntu_base_image.id
  instance_type = "t3.nano"
  subnet_id     = element(data.aws_subnets.private.ids, 1)
}
