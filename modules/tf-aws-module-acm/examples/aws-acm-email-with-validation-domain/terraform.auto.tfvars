env                       = "dev"
app                       = "ims"
res                       = "acm"
region                    = "us-east-2"
domain_name               = "mockdns.devopswork.click"
subject_alternative_names = ["mockdns.devopswork.click", "www.mockdns.devopswork.click", "mockdnsdev.devopswork.click"]
validation_option = {
  "mockdns.devopswork.click" = {
    validation_domain = "devopswork.click"
  },
  "www.mockdns.devopswork.click" = {
    validation_domain = "devopswork.click"
  },
  "mockdnsdev.devopswork.click" = {
    validation_domain = "devopswork.click"
  }
}

#Tags
tags = {
  acm = {
    Purpose = "ALB"
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
  }
}

