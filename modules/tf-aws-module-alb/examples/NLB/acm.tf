# ACM module to create certificate, to be used in NLB (TLS listener)
module "acm" {
  source                    = "../../../tf-aws-module-acm"
  domain_name               = var.acm_config.cert_1.domain_name
  subject_alternative_names = var.acm_config.cert_1.subject_alternative_names
  wait_for_validation       = true
  validate_certificate      = true
  validation_method         = "DNS"
  zones = {
    "mockdns.devopswork.click"     = data.aws_route53_zone.this.zone_id
    "www.mockdns.devopswork.click" = data.aws_route53_zone.this.zone_id
  }
  tags = merge(local.common_tags, var.tags["acm_tags"], { "Name" = "${var.environment}-${var.application}-dns-valid" })
}
# ACM module to create additional certificate, to be used in NLB (TLS listener)
module "additional_acm" {
  source                    = "../../../tf-aws-module-acm"
  domain_name               = var.acm_config.cert_2.domain_name
  subject_alternative_names = var.acm_config.cert_2.subject_alternative_names
  wait_for_validation       = true
  validate_certificate      = true
  validation_method         = "DNS"
  zones = {
    "additional.devopswork.click"             = data.aws_route53_zone.this.zone_id
    "www.mockdns-additional.devopswork.click" = data.aws_route53_zone.this.zone_id
  }
  tags = merge(local.common_tags, var.tags["acm_tags"], { "Name" = "${var.environment}-${var.application}-add-acm-dns-valid" })
}
