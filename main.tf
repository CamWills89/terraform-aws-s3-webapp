# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

resource "aws_s3_bucket" "bucket" {
  bucket_prefix = "${var.environment}-${var.application_name}-"

  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_account_public_access_block.this]
}


resource "aws_s3_bucket_ownership_controls" "bucket" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_website_configuration" "bucket" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_acl" "bucket" {
  depends_on = [
    aws_s3_account_public_access_block.this,
    aws_s3_bucket_public_access_block.bucket,
    aws_s3_bucket_ownership_controls.bucket
  ]
  bucket = aws_s3_bucket.bucket.id

  acl = "public-read"
}

# DEMO-ONLY: this resource changes ACCOUNT-WIDE S3 settings, not just this
# bucket. It turns off all four account-level Block Public Access protections
# so the public website can be served. This is acceptable only in the isolated,
# temporary Instruqt AWS account. Do NOT use this pattern in a shared or
# production account.
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "policy" {
  bucket = aws_s3_bucket.bucket.id
  depends_on = [
    aws_s3_account_public_access_block.this, # ensure account BPaB is off first
    aws_s3_bucket_public_access_block.bucket # and bucket BPaB is off
  ]
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "PublicReadGetObject",
            "Effect": "Allow",
            "Principal": "*",
            "Action": [
                "s3:GetObject"
            ],
            "Resource": [
                "arn:aws:s3:::${aws_s3_bucket.bucket.id}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_s3_object" "webapp" {
  acl    = "public-read"
  key    = "index.html"
  bucket = aws_s3_bucket.bucket.id
  content = templatefile("${path.module}/assets/index.html.tftpl", {
    application_name = var.application_name
    environment      = var.environment
    region           = var.region
  })
  content_type = "text/html"
  depends_on = [
    aws_s3_account_public_access_block.this,
    aws_s3_bucket_acl.bucket,
    aws_s3_bucket_policy.policy
  ]
}
