# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "application_name" {
  type        = string
  description = "Name of your application, for example \"claims-portal\". Use 3-20 characters: lowercase letters, numbers, and hyphens only. It is used in the website name and in resource names and tags."

  validation {
    condition     = can(regex("^[a-z0-9-]{3,20}$", var.application_name))
    error_message = "application_name must be 3-20 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  type        = string
  description = "The non-production environment to create. Allowed values: dev, test, qa."

  validation {
    condition     = contains(["dev", "test", "qa"], var.environment)
    error_message = "environment must be one of: dev, test, qa."
  }
}

variable "region" {
  type        = string
  description = "AWS region where the environment is created. This is defined by the platform team and does not normally need to be changed."
  default     = "us-east-1"
}
