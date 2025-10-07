# For Elastic IP
resource "aws_eip" "this" {
  count  = length(data.aws_subnets.private.ids)
  domain = "vpc"
  tags   = merge(var.tags["nlb_tags"], local.common_tags, { "Name" = "${local.env}-${local.app}-eip-nlb" })
}

# Network Load Balancer Module Usage - Full Example
module "nlb" {
  # Path to your NLB module
  source = "../../../tf-aws-module-alb"
  # Ensures ACM certificates are created before NLB (For TLS listener only)
  depends_on = [module.acm, module.additional_acm]
  # Core NLB settings
  name               = local.nlb_config.lb_name          # Unique NLB name (per environment)
  load_balancer_type = var.nlb_config.load_balancer_type # "application" or "network"
  internal           = var.nlb_config.internal           # true for internal NLB, false for internet-facing
  #  subnets                                                      = data.aws_subnets.private.ids      # NLB subnets (use subnmet mapping block, if mapping needs to be configured)
  subnet_mapping = [for i, eip in aws_eip.this :
    {
      allocation_id = eip.id
      subnet_id     = data.aws_subnets.private.ids[i]
    }
  ]
  enable_deletion_protection                                   = false # Disable deletion protection for testing
  enforce_security_group_inbound_rules_on_private_link_traffic = "on"
  # Security Group rules (for POC; in prod , we will be using SG module)
  security_group_ingress_rules = var.nlb_config.security_group_ingress_rules
  security_group_egress_rules  = var.nlb_config.security_group_egress_rules
  # Connection tuning
  client_keep_alive = 3600 # Seconds to keep connections alive
  idle_timeout      = 3600 # Idle timeout in seconds
  # Listeners
  listeners = {
    listener_1 = {
      port     = 80
      protocol = "TCP"
      forward = {
        target_group_key = "tg-1"
      }
    }
    listener_2 = {
      port     = 81
      protocol = "TCP_UDP"
      forward = {
        target_group_key = "tg-2"
      }
    }
    listener_3 = {
      port     = 82
      protocol = "UDP"
      forward = {
        target_group_key = "tg-3"
      }
    }
    listener_4 = {
      port                        = 83
      protocol                    = "TLS"
      certificate_arn             = module.acm.acm_certificate_arn
      additional_certificate_arns = [module.additional_acm.acm_certificate_arn]
      forward = {
        target_group_key = "tg-4"
      }
    }
  }
  # Target Groups
  target_groups = {
    tg-1 = {
      name                              = "${var.environment}-${var.application}-tg-1"
      protocol                          = "TCP"
      port                              = 80
      target_type                       = "instance"
      vpc_id                            = data.aws_vpc.selected.id
      deregistration_delay              = 10
      load_balancing_cross_zone_enabled = false
      health_check = {
        enabled             = true
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 10
        protocol            = "TCP"
      }
      target_id = aws_instance.server1.id
    }
    tg-2 = {
      name                   = "${var.environment}-${var.application}-tg-2"
      protocol               = "TCP_UDP"
      port                   = 81
      target_type            = "instance"
      vpc_id                 = data.aws_vpc.selected.id
      deregistration_delay   = 10
      connection_termination = true
      preserve_client_ip     = true
      health_check = {
        enabled             = true
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
        protocol            = "TCP"
      }
      target_id = aws_instance.server2.id
    }
    tg-3 = {
      name                   = "${var.environment}-${var.application}-tg-3"
      protocol               = "UDP"
      port                   = 82
      target_type            = "ip"
      vpc_id                 = data.aws_vpc.selected.id
      deregistration_delay   = 10
      connection_termination = true
      preserve_client_ip     = true
      health_check = {
        enabled             = true
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
      target_id = aws_instance.server2.private_ip
    }
    tg-4 = {
      name                   = "${var.environment}-${var.application}-tg-4"
      protocol               = "TLS"
      port                   = 83
      target_type            = "instance"
      vpc_id                 = data.aws_vpc.selected.id
      deregistration_delay   = 10
      connection_termination = true
      preserve_client_ip     = true
      health_check = {
        enabled             = true
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
      # target_id        = aws_instance.server1.id  # Will be using this target group for auoscaling group
      tags = {
        InstanceTargetGroupTag = "used in autoscaling"
      }
    }
  }

  # Additional targets for existing target groups
  additional_target_group_attachments = [
    { target_group_key = "tg-1", target_id = aws_instance.server2.id, port = 87 },
    { target_group_key = "tg-1", target_id = aws_instance.server2.id, port = 85 },
    { target_group_key = "tg-2", target_id = aws_instance.server1.id, port = 85 }
  ]
  tags = merge(var.tags["nlb_tags"], local.common_tags)
}

# Demo EC2 Instances for Target Groups
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
