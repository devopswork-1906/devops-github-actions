# tf-aws-module-acm

Terraform module to provision an **AWS ACM (Certificate Manager)** certificate with optional **DNS or EMAIL validation**, including support for **Route 53-based DNS record automation** or manual EMAIL approval.

---

## Table of Contents

- [Features](#features)
- [Usage](#usage)
  - [DNS Validation Example](#dns-validation-example)
  - [EMAIL Validation Example](#email-validation-example)
  - [Create Only Route53 Records (for external ACM certs)](#create-only-route53-records-for-external-acm-certs)
- [Input Variables](#input-variables)

## Features

- Create public ACM certificates with support for SANs (Subject Alternative Names)
- Support for wildcard domains (e.g., `*.example.com`)
- DNS validation using Route53 (fully automated)
- EMAIL validation (manual approval via domain admin email)
- Optional certificate validation with timeouts
- Can create:
  - Full ACM + DNS + validation (automated)
  - Full ACM + EMAIL validation (manual)
  - Only Route53 records (for external or imported certificates)
- Fully conditional resource creation
- Supports certificate transparency logging toggle

---

## Usage

### DNS Validation Example

```hcl
module "acm" {
  source = "../../"
  domain_name     = "example.com"
  subject_alternative_names = ["www.example.com", "api.example.com"]
  validation_method = "DNS"
  hosted_zone_id  = "Z3P5QSUBK4POTI"
  validate_certificate  = true
  wait_for_validation   = true
  create_route53_records = true
  dns_ttl               = 60
  certificate_transparency_logging_preference = true
  tags = {
    Environment = "dev"
    Project     = "my-app"
  }
}
```
### EMAIL Validation Example
```
module "acm_email" {
  source = "../../"
  domain_name       = "example.com"
  validation_method = "EMAIL"
  create_certificate   = true
  validate_certificate = false  # Not needed for EMAIL
  wait_for_validation  = false  # Not needed for EMAIL
  tags = {
    Purpose = "email-validation"
  }
}
```

When validation_method = "EMAIL", AWS sends verification emails to a set of pre-defined admin addresses for the domain, such as:
- admin@yourdomain.com
- administrator@yourdomain.com
- hostmaster@yourdomain.com
- postmaster@yourdomain.com
- webmaster@yourdomain.com

The recipient must click a verification link in the email to validate the certificate.

### Create Only Route53 Records (for external ACM certs)
```
module "acm_dns" {
  source = "../modules/acm"

  create_certificate            = false
  create_route53_records_only   = true
  create_route53_records        = true
  validation_method             = "DNS"
  acm_certificate_domain_validation_options = var.external_validation_options

  zones = {
    "example.com" = "Z3P5QSUBK4POTI"
  }

  tags = {
    ManagedBy = "Terraform"
  }
}
```


### Input Variables

| Name                                      | Description                                                                 | Type          | Default     | Required |
|-------------------------------------------|-----------------------------------------------------------------------------|---------------|-------------|----------|
| `domain_name`                             | Primary domain for the ACM certificate                                      | `string`      | `null`      | Yes      |
| `subject_alternative_names`               | SANs (additional domain names)                                              | `list(string)`| `[]`        | No       |
| `validation_method`                       | Validation method: "DNS" or "EMAIL"                                         | `string`      | `"DNS"`     | No       |
| `hosted_zone_id`                          | Hosted zone ID (used if zones map not provided)                             | `string`      | `""`        | No       |
| `zones`                                   | Map of domain => hosted_zone_id (for SAN/domain resolution)                 | `map(string)` | `{}`        | No       |
| `validation_option`                       | Map of domain_name => validation_domain (for manual use)                    | `map(object)` | `{}`        | No       |
| `acm_certificate_domain_validation_options` | Used when importing certs and managing only DNS records                    | `any`         | `[]`        | No       |
| `validation_record_fqdns`                 | Pre-created validation FQDNs (for merging with auto records)                | `list(string)`| `[]`        | No       |
| `validate_certificate`                    | Whether to trigger aws_acm_certificate_validation                           | `bool`        | `true`      | No       |
| `wait_for_validation`                     | Add a timeout block while waiting for cert validation                       | `bool`        | `true`      | No       |
| `validation_timeout`                      | Timeout duration for cert validation                                        | `string`      | `"10m"`     | No       |
| `certificate_transparency_logging_preference` | Enable CT logs (true or false)                                           | `bool`        | `true`      | No       |
| `create_certificate`                      | Whether to create the ACM certificate                                       | `bool`        | `true`      | No       |
| `create_route53_records_only`             | Create only Route53 records (for external certs)                            | `bool`        | `false`     | No       |
| `create_route53_records`                  | Whether to create Route53 records for DNS validation                        | `bool`        | `true`      | No       |
| `dns_ttl`                                 | TTL for validation records                                                  | `number`      | `60`        | No       |
| `validation_allow_overwrite_records`      | Allow Terraform to overwrite existing Route53 records                       | `bool`        | `false`     | No       |
| `key_algorithm`                           | Key algorithm for the cert (e.g., RSA_2048, EC_prime256v1)                  | `string`      | `null`      | No       |
| `tags`                                    | Tags to apply to all resources                                              | `map(string)` | `{}`        | No       |
