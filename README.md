# DevOps GitHub Actions Terraform Infrastructure

This repository provides an end-to-end, Terraform infrastructure automation framework powered by **GitHub Actions**.

It enables you to:
- Use OIDC-based authentication with GitHub Actions (no AWS keys)
- Bootstrap AWS accounts with Terraform backend (S3 + DynamoDB)
- Deploy modular, environment-based infrastructure (VPC, ALB, ACM, ASG, EC2 & many more resources). Gradually other modules will be added
- Govern production changes with GitHub environment approvals
- ECS Fargate-based GitHub self-hosted runners (Work in Progress)

## Table of Contents

1. [Overview](#repository-architecture)
2. [Workflow Naming](#workflow-naming)
3. [Workflow Summary](#workflow-summary)
4. [Environment Configuration Pattern](#environment-configuration-pattern)
5. [Design Principles](#design-principles)
6. [Repository Layers](#repository-layers)
    - [Layer Overview](#layer-overview)
    - [How to Use](#how-to-use)
7. [License](#license)
---

# Repository Architecture 
```
devops-github-actions/
├── modules/                               # Reusable Terraform modules (shared across stacks)
│   ├── tf-aws-module-vpc/                 # Base networking (VPC, subnets, routes)
│   ├── tf-aws-module-alb/                 # Application Load Balancer
│   ├── tf-aws-module-acm/                 # SSL Certificates via ACM
│   ├── tf-aws-module-asg/                 # Auto Scaling Group
│   ├── tf-aws-module-ec2/                 # EC2 Instances (Launch Templates)
│   └── tf-aws-module-keypair/             # SSH keypair management
├── infra/
│   └── terraform/
│       ├── bootstrap/                     # Bootstraps AWS account for Terraform usage
│       │   |                              # Creates backend infra: S3 (state) + DynamoDB (lock table)
│       │   |                              # Pre-requisite: OIDC IAM role must exist in the target AWS account
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── backend.tf
│       │   └── provider.tf
│       ├── github_runner/                 # ECS Fargate-based GitHub self-hosted runners (Work in Progress)
│       │   |                              # Will replace GitHub-hosted runners for private infra operations
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── backend.tf
│       │   └── provider.tf
│       └── project_infra/                 # Application infrastructure (modular and environment-based)
│           │                              # Starts with ALB (with ACM) → ASG → EC2 → VPC
│           │                              # Future: IAM, S3, ECS Fargate etc
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── backend.tf
│           ├── provider.tf
│           └── env/                       # Environment-specific configuration
│               ├── dev/
│               │   ├── dev.tfbackend
│               │   ├── dev.tfvars
│               ├── test/
│               │   ├── test.tfbackend
│               │   ├── test.tfvars
│               └── prod/
│                   ├── prod.tfbackend
│                   ├── prod.tfvars
└── .github/
    └── workflows/
        ├── aws_account_bootstrap.yaml           # Bootstraps Terraform backend infrastructure (S3 + DynamoDB)
        │                                        # Points to infra/terraform/bootstrap
        │                                        # Executed manually (one-time per AWS account)
        ├── terraform-aws-infra-dispatcher.yml   # Manual trigger for application infra deployment
        │                                        # Accepts env, app, region → calls reusable workflow
        │
        ├── terraform-aws-infra-reusable.yml     # Reusable Terraform workflow (init, validate, plan, apply)
                                                 # Used by dispatcher; separate approval setup for non-prod and prod
```
--- 

# Workflow Naming

**terraform-cloud-function-type.yml**

Where:
-	**cloud** → e.g., aws, azure, gcp
-	**function** → what it’s doing: infrastructure, bootstrap, provision, deployment
-	**type** → whether it’s dispatcher, reusable, apply, etc.

# Workflow Summary

| Workflow | Purpose | Directory | Trigger | Approval |
|-----------|----------|------------|----------|-----------|
| **aws_account_bootstrap.yaml** | Bootstraps AWS for Terraform (S3, DynamoDB). Requires OIDC IAM Role pre-created. | `infra/terraform/bootstrap/` | Manual | Manual |
| **terraform-aws-infra-dispatcher.yaml** | Entry workflow for application infra deployment. | `infra/terraform/project_infra/` | Manual | Approval (non-prod/prod) |
| **terraform-aws-infra-reusable.yaml** | Core reusable logic for init → plan → apply. | Called by dispatcher | Internal | Conditional |

---

# Environment Configuration Pattern

Each environment (dev, test, prod) contains its own:
- Backend file (*.tfbackend) → defines S3 bucket and DynamoDB table.
- Variable file (*.tfvars) → defines resource inputs (VPC CIDR, ALB settings, ASG parameters, etc.).

Example (env/dev/dev.tfbackend):
```
region = "us-east-2"
bucket = "dev-ims-tf-statefiles"
dynamodb_table = "dev-ims-tf-lock"
key = "ims-infra.tfstate"
```
Example (env/dev/dev.tfvars):
```
environment = "dev"
application = "ims"
aws_region  = "eu-west-1"
vpc_cidr_block = "10.0.0.0/16"
availability_zones = ["eu-west-1a", "eu-west-1b"]
acm_config = {
  domain_name               = "mockdns.devopswork.click"
  subject_alternative_names = ["www.mockdns.devopswork.click"]
  hosted_zone_name          = "devopswork.click"
}
```
---
# Design Principles

| Principle | Description |
|------------|--------------|
| **Separation of Concerns** | Each Terraform layer (bootstrap, runner, project) has its own backend and workflow. |
| **Environment Isolation** | Each environment has its own state, backend, and variables. |
| **Secure OIDC Auth** | GitHub Actions assume AWS IAM roles via OIDC — no long-term credentials. |
| **Governed Deployment** | separate approval group for non-prod/prod manual approval (`prod-deployment-approval` ,`non-prod-deployment-approval` ). |
| **Modular Growth** | Modules are reusable; new infra types (RDS, EFS, WAF, CloudFront) can be added easily. |

---

# Repository Layers

This explains the core layers in the `devops-github-actions` repository and how they map to folders.

## Layer Overview

| Layer              | Folder / File                         | Description                                                                                                                          |
|--------------------|---------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------|
| Modules            | `/modules/`                           | Collection of reusable Terraform modules used by all environments and stacks. New modules (RDS, EFS, CloudFront) will be added gradually. |
| Bootstrap          | `/infra/terraform/bootstrap/`         | Creates foundational AWS resources for Terraform (S3 + DynamoDB). Must be run first per AWS account. Requires OIDC IAM role already set up. |
| GitHub Runner      | `/infra/terraform/github_runner/`     | Defines GitHub self-hosted runners on ECS Fargate. Work in progress; will enable private GitHub Actions execution.                   |
| Project Infra      | `/infra/terraform/project_infra/`     | Main application infrastructure. Begins with ALB (ACM) → ASG → EC2 → VPC. Designed for modular expansion (DB, storage, CDN, etc.).  |
| Environment Config | `/infra/terraform/project_infra/env/` | Contains backend and variable configurations for each environment (dev, test, prod). Isolates Terraform state and variables.         |
| Workflows          | `/.github/workflows/`                 | GitHub Actions automation workflows. Handles bootstrap, infra provisioning, and PR-based validation.                                 |

## How to Use

### 1. Bootstrap AWS Account
Run manually:
```bash
aws_account_bootstrap.yaml
```

### 2. Deploy Infra (Dev/Test/Sandobx/UAT/Prod)
Run manually:
```bash
terraform-aws-infra-dispatcher.yaml
```

Select inputs:
- Environment: dev/test/sandbox/uat/prod
- Application: ims (or other app)
- Region: eu-west-1 (or any region)

### 3. Separate Github Environment at repository level for environment specific variable
### 4. Approvals
- **Non-prod:** Manual approval via GitHub Environment `prod-deployment-approval` 
- **Prod:** Manual approval via GitHub Environment `prod-deployment-approval`

---

## License
Internal DevOps Infrastructure Repository — managed by `DevOpsWork1906`.
