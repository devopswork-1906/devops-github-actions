# ACM module to create certificate, to be used in ALB (HTTPS listener)
# For this use case, 2 certs (main, additional certs) are getting created.
# Validation option like below is managed via loop (line 22-25)
# zones = {
#   "mockdns.devopswork.click"     = "devopswork.click"
#   "www.mockdns.devopswork.click" = "devopswork.click"
# }
module "acm" {
  for_each                  = var.acm_config.certs
  source                    = "../../../modules/tf-aws-module-acm/"
  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  wait_for_validation       = each.value.wait_for_validation
  validate_certificate      = each.value.validate_certificate
  validation_method         = each.value.validation_method
  zones = {
    for d in concat([each.value.domain_name], each.value.subject_alternative_names) :
    d => data.aws_route53_zone.this.zone_id
  }
  tags = merge(var.tags["common_tags"], var.tags["acm_tags"], { "Name" = "${var.environment}-${var.application}-${each.key}" })
}