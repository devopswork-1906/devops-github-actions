environment = "dev"
application = "ims"
region      = "us-east-2"
vpc_name    = "demo"
acm_config = {
  hosted_zone_name = "devopswork.click"
  cert_1 = {
    domain_name               = "mockdns.devopswork.click"
    subject_alternative_names = ["www.mockdns.devopswork.click"]
  }
  cert_2 = {
    domain_name               = "additional.devopswork.click"
    subject_alternative_names = ["www.mockdns-additional.devopswork.click"]
  }
}
nlb_config = {
  load_balancer_type = "network"
  internal           = false
  security_group_ingress_rules = {
    all_http = {
      from_port   = 80
      to_port     = 82
      ip_protocol = "tcp"
      description = "HTTP web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
    all_https = {
      from_port   = 443
      to_port     = 445
      ip_protocol = "tcp"
      description = "HTTPS web traffic"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  security_group_egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
}
asg_config = {
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 2
  key_name                  = "devops"
  instance_type             = "t3.medium"
  iam_instance_profile_name = "poc-admin"
  health_check_type         = "EC2"
  security_group_id         = "sg-045d2f31adbf97b42"
  default_instance_warmup   = 300
  health_check_grace_period = 300
  launch_template_version   = "$Latest"
  instance_maintenance_policy = {
    min_healthy_percentage = 50
    max_healthy_percentage = 100
  }
}
#Resource Specific Tags
tags = {
  acm_tags = {
    Purpose = "Load Balancer"
  }
  nlb_tags = {
    LB_Type = "Application"
    kind    = "public"
  }
  launch_template_tags = {
    Purpose = "autoscaling"
  }
  asg_tags = {
    purpose = "asg"
  }
}
