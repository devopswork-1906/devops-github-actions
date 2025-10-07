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

#Tags
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