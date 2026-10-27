# terraform-aws-s3-webapp

Approved non-production web application environment for demonstrating
**HCP Terraform self-service / No-Code Provisioning**.

Derived from HashiCorp's education example
[`learn-private-module-aws-s3-webapp`](https://github.com/hashicorp-education/learn-private-module-aws-s3-webapp)
(MPL-2.0, see [LICENSE](LICENSE)).

## Purpose

A central platform engineering team owns the Terraform implementation and
standards. Application developers consume this module through HCP Terraform
No-Code Provisioning to get a standardized `dev`, `test`, or `qa` web
environment, without writing Terraform and without direct AWS credentials.

> **Disclaimer:** this is an intentionally simplified demo module. It is **not**
> a production reference architecture for a real insurance application.

## Inputs

| Name               | Who sets it | Required | Default     | Description                                                                 |
| ------------------ | ----------- | -------- | ----------- | --------------------------------------------------------------------------- |
| `application_name` | Consumer    | Yes      | none        | 3-20 characters; lowercase letters, numbers, hyphens. Example: `claims-portal` |
| `environment`      | Consumer    | Yes      | none        | One of `dev`, `test`, `qa` (validated in Terraform)                          |
| `region`           | Platform    | No       | `us-east-1` | AWS region. Platform-defined; consumers should not need to change it.        |

## Outputs

| Name                 | Description                                                    |
| -------------------- | -------------------------------------------------------------- |
| `website_url`        | URL of the deployed website (HTTP; S3 website endpoints have no HTTPS) |
| `bucket_name`        | Name of the unique S3 bucket that was created                  |
| `deployment_summary` | e.g. `claims-portal dev environment provisioned in us-east-1`  |

## What it provisions

All resources are in the root module (required for no-code). The AWS provider is
declared in [`versions.tf`](versions.tf) (`hashicorp/aws`, `~> 4.0`) and
configured with `region = var.region` plus default tags (`ManagedBy`,
`Application`, `Environment`). No credentials are configured in the code and no
backend is declared.

- `aws_s3_bucket.bucket` - bucket named `<environment>-<application_name>-<unique suffix>` (via `bucket_prefix`)
- `aws_s3_bucket_ownership_controls.bucket` - `BucketOwnerPreferred` so ACLs can be used
- `aws_s3_bucket_public_access_block.bucket` - bucket-level public access block turned off
- `aws_s3_bucket_acl.bucket` - `public-read`
- `aws_s3_bucket_policy.policy` - public `s3:GetObject` on the bucket's objects
- `aws_s3_bucket_website_configuration.bucket` - static website hosting (`index.html`)
- `aws_s3_object.webapp` - `index.html` rendered with `templatefile()` from
  [`assets/index.html.tftpl`](assets/index.html.tftpl), showing the application
  name, environment and region
- `aws_s3_account_public_access_block.this` - **account-wide**, see below

### Demo-only: account-level S3 public access setting

`aws_s3_account_public_access_block.this` (inherited unchanged from the
HashiCorp example) sets all four **account-level** S3 Block Public Access
settings to `false`. It affects **every bucket in the AWS account**, not just
the one this module creates.

- It is **demo-only behavior** intended for the isolated, temporary Instruqt AWS
  account. Do not use this pattern in a shared or production account.
- The resource is a per-account singleton: running this module more than once in
  the same account (e.g. `dev` and `qa`) means multiple workspaces manage the
  same setting, and destroying one workspace will change it for the others.
- A production design would keep account-level blocking enabled and serve
  content privately (e.g. CloudFront with Origin Access Control).

## HCP Terraform demo workflow

1. Push this repository into the temporary GitLab instance provided by Instruqt.
2. Create a semantic version tag, e.g. `1.0.0`.
3. Publish the module to the HCP Terraform **Private Registry** (VCS-backed;
   the repository name `terraform-aws-s3-webapp` follows the required
   `terraform-<PROVIDER>-<NAME>` convention).
4. Mark/version it as **No-Code Ready**.
5. In the module's no-code settings, configure `environment` with the allowed
   options `dev`, `test`, `qa` (dropdown).
6. Use the Instruqt-provided project-scoped AWS authentication / dynamic
   credentials variable set, so the workspace gets AWS access without the
   developer handling credentials.
7. As the application developer, click **Provision Workspace**, for example:
   - `application_name` = `claims-portal`
   - `environment` = `dev`

   Prefer **Manual Apply** for the interview so the plan can be discussed before
   applying.
8. After the apply, review the outputs and open `website_url`.

Do not commit credentials, account IDs, organization/workspace IDs, or GitLab
URLs to this repository.
