# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "website_url" {
  description = "URL of the deployed static website (S3 website endpoints serve HTTP only)."
  value       = "http://${aws_s3_bucket_website_configuration.bucket.website_endpoint}"
}

output "bucket_name" {
  description = "Name of the unique S3 bucket created for this environment."
  value       = aws_s3_bucket.bucket.id
}

output "deployment_summary" {
  description = "Human-readable summary of what was provisioned."
  value       = "${var.application_name} ${var.environment} environment provisioned in ${var.region}"
}
