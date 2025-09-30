# AWS Account Bootstrap with Terraform and GitHub Actions

This repository provides a **Terraform-based bootstrap** setup for new AWS accounts, including a GitHub Actions workflow for **Plan → Approval → Apply**. It creates the necessary resources for Terraform remote state management (S3 buckets and DynamoDB table) and is ready for multi-environment deployments.

---

## Features

- Creates **S3 buckets** for:
  - Terraform state files (`statefiles bucket`)
  - s3 bucket for statefile bucket access logs (`statefile log bucket`)
- Creates **DynamoDB table** for Terraform state locking
- Configures:
  - Versioning on S3 buckets
  - Server-side encryption (SSE-S3)
  - Public access blocks
- **Environment and Application inputs** are passed directly from the GitHub Actions workflow prompt; no separate TFVars needed.
- **Terraform Plan → Apply workflow** in a single GitHub Actions workflow
- Uses **GitHub OIDC** for secure AWS IAM role assumption (no static credentials)
- Terraform version **>= 1.8.0** for compatibility with latest AWS provider features

---

## Repository Structure

```
.
├── main.tf               # Terraform resources (S3 buckets, DynamoDB)
├── variables.tf          # Input variables (environment, application, region)
├── locals.tf             # Derived resource names and tags
├── outputs.tf            # Outputs for buckets and DynamoDB table
└── .github/
    └── workflows/
        └── aws_account_bootstrap.yaml  # GitHub Actions workflow
```

---

## GitHub Actions Workflow

### Workflow: `aws_account_bootstrap.yaml`

- **Trigger:** Manual via `workflow_dispatch`
- **Inputs:**
  - `environment` → Dropdown: dev, test, uat, prod
  - `application` → String
  - `region` → Default `eu-west-1`
  - `role_arn` → IAM Role ARN for OIDC

### Jobs (Stages)

1. **Terraform Plan**
   - Checkout code, configure AWS via OIDC
   - Setup Terraform (`>= 1.8.0`) and run `terraform init` & `validate`
   - Generate `terraform plan` and display output in logs

2. **Terraform Apply**
   - Depends on Plan job
   - Runs only after **manual approval** in **GitHub Environment**
   - Apply the plan using `terraform apply -auto-approve`

**Note:**
- You must create a **GitHub Environment** named `terraform-approval` with required reviewers. The Apply job will pause until someone approves in the GitHub UI.

---

## How to Use

1. Trigger the workflow manually in GitHub Actions.
2. Select **Environment** (`dev/test/uat/prod`) and provide **Application Name**.
3. Review the Terraform Plan output in the workflow logs.
4. Approve the **GitHub Environment `terraform-approval`**.
5. The Apply job will execute and create:
   - Global log S3 bucket
   - Statefiles S3 bucket
   - DynamoDB table for state locking

---

## Best Practices

- **Use OIDC** for secure AWS authentication; do not store AWS keys in GitHub.
- **Separate Plan and Apply jobs** for safe approval workflow.
- **Use locals** to derive names and tags for consistency.
- **Protect critical resources** with `lifecycle { prevent_destroy = true }`.
- After bootstrap, configure Terraform to **use S3 backend** for remote state if desired.

---

## Terraform Version

- Terraform **>= 1.8.0**
- AWS Provider: `~> 5.74.0`

---

## Notes

- No separate TFVars files are needed; **environment** and **application name** are taken from workflow prompt.
- Manual approval ensures no accidental apply in production environments.
- All bootstrap resources are safe and consistent across environments.
