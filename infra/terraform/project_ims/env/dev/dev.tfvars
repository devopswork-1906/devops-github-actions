# environment = "dev"
# application = "ims"
# region      = "us-east-2"
# VPC related details (VPC Cidr & Subnet Cidr). Based on number of subnet cidr entries, it will create subnets
vpc_config = {
  vpc_cidr              = "10.0.0.0/16"
  public_subnets_cidr   = ["10.0.0.0/20", "10.0.16.0/20", "10.0.32.0/20"]
  private_subnets_cidr  = ["10.0.64.0/20", "10.0.80.0/20", "10.0.96.0/20"]
  database_subnets_cidr = ["10.0.128.0/20", "10.0.144.0/20", "10.0.160.0/20"]
}
# ACM Config (Certificate to be used in ALB HTTPS listener). 
# For this use case, 2 certs (main, additional certs) are getting created.
acm_config = {
  hosted_zone_name = "devopswork.click"
  certs = {
    mockdns = {
      domain_name               = "mockdns.devopswork.click"
      subject_alternative_names = ["www.mockdns.devopswork.click"]
      wait_for_validation       = true
      validate_certificate      = true
      validation_method         = "DNS"
    }
    additional = {
      domain_name               = "additional.devopswork.click"
      subject_alternative_names = ["www.mockdns-additional.devopswork.click"]
      wait_for_validation       = true
      validate_certificate      = true
      validation_method         = "DNS"
    }
  }
}
#Autoscaling group config
asg_config = {
  min_size                  = 1
  max_size                  = 3
  desired_capacity          = 1
  key_name                  = "devops"
  instance_type             = "t3.medium"
  iam_instance_profile_name = "poc-admin"
  health_check_type         = "EC2"
  default_instance_warmup   = 300
  health_check_grace_period = 300
  launch_template_version   = "$Latest"
  instance_maintenance_policy = {
    min_healthy_percentage = 50
    max_healthy_percentage = 100
  }
}

alb_config = {
  load_balancer_type = "application"
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

#Tags
tags = {
  launch_template_tags = {
    Purpose = "autoscaling"
  }
  asg_tags = {
    Purpose = "Autoscaling setup"
  }
  acm_tags = {
    Purpose = "ALB"
  }
  alb_tags = {
    Purpose = "ALB"
    Type    = "Internet"
  }
  common_tags = {
    Application       = "ims"
    Environment       = "dev"
    Owner             = "Naveen K"
    Owner_Email       = "devopswork1906@gmail.com"
    snassignmentgroup = "am_gi_technical"
    SNResolver        = "AM GI Technical"
    region            = "us-east-2"
    ManagedBy         = "terraform"
    GithubRepo        = "terraform-aws-autoscaling"
    GithubOrg         = "terraform-aws-modules"
  }
}