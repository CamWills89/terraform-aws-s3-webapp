# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {
  required_version = ">= 1.1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# No credentials are configured here. In HCP Terraform, AWS authentication is
# supplied externally (project-scoped variable set / dynamic credentials).
provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy   = "Terraform"
      Application = var.application_name
      Environment = var.environment
    }
  }
}
