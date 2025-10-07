# ACM Module – Example Usage (EMAIL Validation with `validation_option`)

This example demonstrates how to use the [ACM module](../../) to issue an ACM certificate using **EMAIL validation**, while explicitly specifying the `validation_domain` using the `validation_option` argument. This is useful when managing SANs or when the domain used for validation differs from the actual certificate domain.

---

## Table of Contents

- [Requirements](#-requirements)
- [Providers](#-providers)
- [Data Sources](#-data-sources)
- [Module Usage](#-module-usage)
- [terraform.auto.tfvars](#-terraformautotfvars)
- [Input Variables](#-input-variables)
- [Outputs](#-outputs)
- [Notes](#-notes)

---

## Requirements

| Name         | Version   |
|--------------|-----------|
| Terraform    | >= 1.5.6  |
| AWS Provider | >= 5.22   |

---

## Providers

```hcl
terraform {
  required_version = ">= 1.5.6"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.22"
    }
  }
}

provider "aws" {
  region = var.region
}
```

---

## Data Sources

```hcl
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {}
```

---

## Module Usage

```hcl
module "acm" {
  source                     = "https://github.com/devopswork-1906/devops-github-actions/tree/main/modules/tf-aws-module-acm"
  domain_name                = var.domain_name
  subject_alternative_names = var.subject_alternative_names
  wait_for_validation        = false
  validate_certificate       = false
  validation_method          = "EMAIL"
  validation_option          = var.validation_option
  tags = merge(
    var.tags["common_tags"],
    var.tags["acm"],
    {
      Name = "${var.env}-${var.app}-${var.res}-email-valid-option"
    }
  )
}
```

---

##  terraform.auto.tfvars

These variables are defined in `terraform.auto.tfvars` for automatic loading during Terraform plan/apply:

```hcl
env    = "dev"
app    = "ims"
res    = "acm"
region = "us-east-2"
domain_name               = "mockdns.devopswork.click"
subject_alternative_names = [
  "mockdns.devopswork.click",
  "www.mockdns.devopswork.click",
  "mockdnsdev.devopswork.click"
]

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
```

---

## Input Variables

These are defined in `variables.tf`:

| Name                        | Type               | Description                                                                 |
|-----------------------------|--------------------|-----------------------------------------------------------------------------|
| `env`                       | `string`           | Environment (e.g., `dev`, `test`, `uat`, `prod`)                            |
| `app`                       | `string`           | Application name                                                            |
| `res`                       | `string`           | Resource type (e.g., `ec2`, `s3`, `iam`)                                    |
| `region`                    | `string`           | AWS region (e.g., `us-east-2`)                                              |
| `domain_name`               | `string`           | Primary domain (common name) for the certificate                            |
| `subject_alternative_names` | `list(string)`     | Additional domains to include as SANs                                       |
| `validation_option`         | `any`              | Map of validation domains for email validation for each domain/SAN          |
| `tags`                      | `map(map(string))` | Nested map of tags applied to different AWS resources                        |

---

## Outputs

These are defined in `outputs.tf`:

| Name                                    | Description                                                                 |
|-----------------------------------------|-----------------------------------------------------------------------------|
| `acm_certificate_arn`                  | The ARN of the issued certificate                                           |
| `acm_certificate_domain_validation_options` | Attributes used for domain validation (DNS only)                       |
| `acm_certificate_status`               | Current status of the ACM certificate                                       |
| `acm_certificate_validation_emails`    | Email addresses used for validation (only set if EMAIL validation is used) |

```hcl
output "acm_certificate_arn" {
  description = "The ARN of the certificate"
  value       = module.acm.acm_certificate_arn
}

output "acm_certificate_domain_validation_options" {
  description = "A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used."
  value       = module.acm.acm_certificate_domain_validation_options
}

output "acm_certificate_status" {
  description = "Status of the certificate."
  value       = module.acm.acm_certificate_status
}

output "acm_certificate_validation_emails" {
  description = "A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used."
  value       = module.acm.acm_certificate_validation_emails
}
```

---

## Notes

- `validation_option` lets you control which domain ACM uses to send validation emails.
- Required for scenarios where your certificate includes subdomains or SANs from a parent domain.
- This setup disables auto-validation (`wait_for_validation` and `validate_certificate`) so that manual email confirmation can be handled externally.

