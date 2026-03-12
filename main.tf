locals {
  enabled                           = var.create_resources
  bucket_domain_name = "${var.s3_bucket_name}.s3.${data.aws_region.current.name}.amazonaws.com"
  use_oac = local.enabled && var.origin_access_control
  use_oai = local.enabled && !var.origin_access_control
}

data "aws_region" "current" {}
data "aws_partition" "current" {}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = var.s3_bucket_name
  force_destroy = true
  tags          = var.tags
}

resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  count = local.use_oai
  comment = "Origin Access Identity for ${aws_s3_bucket.s3_bucket.bucket_domain_name}"
}

resource "aws_cloudfront_origin_access_control" "cf_oac" {
  count = local.use_oac
  name  = "OAC-${aws_s3_bucket.s3_bucket.bucket}"
  description = "Origin Access Control for ${aws_s3_bucket.s3_bucket.bucket}"
  origin_access_control_origin_type = "s3"
  signing_behavior = "always"
  signing_protocol = "sigv4"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name = aws_s3_bucket.s3_bucket.bucket_domain_name
    origin_id   = aws_s3_bucket.s3_bucket.bucket
    origin_access_control_id = local.use_oac ? aws_cloudfront_origin_access_control.cf_oac[0].id : null
    dynamic "s3_origin_config" {
      for_each = local.use_oai ? [1] : []
      content {
        origin_access_identity = local.use_oai ? "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.cf_oai[0].id}" : null
      }
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.s3_bucket.bucket
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400

    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_locations_list
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  dynamic "custom_error_response" {
    for_each = var.error_responses
    content {
      error_caching_min_ttl = lookup(custom_error_response.value, "error_caching_min_ttl", null)
      error_code            = custom_error_response.value.error_code
      response_code         = lookup(custom_error_response.value, "response_code", null)
      response_page_path    = lookup(custom_error_response.value, "response_page_path", null)
    }
  }

  tags          = var.tags
  comment       = var.cloudfront_description
  depends_on    = [aws_s3_bucket.s3_bucket]
}

# S3 - Bucket Policy for CloudFront
data "aws_iam_policy_document" "s3_policy" {
  count = local.use_oai ? 1 : 0
  
  dynamic "statement" {
    for_each = local.use_oai ? [1] : []
    content {
      sid     = "S3ReadAccessForCloudFrontOAI"
      effect  = "Allow"
      actions = ["s3:GetObject"]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/*"
      ]
      principals {
        type        = "AWS"
        identifiers = [aws_cloudfront_origin_access_identity.this[0].iam_arn]
      }
    }
  }

  dynamic "statement" {
    for_each = local.use_oac ? [1] : []
    content {
      sid    = "S3ReadAccessForCloudFrontOAC"
      effect = "Allow"
      actions = [
        "s3:GetObject"
      ]
      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/*"
      ]
      principals {
        type        = "Service"
        identifiers = ["cloudfront.amazonaws.com"]
      }
      condition {
        test     = "StringEquals"
        variable = "AWS:SourceArn"
        values   = [aws_cloudfront_distribution.this[0].arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = data.aws_iam_policy_document.s3_policy.json

  depends_on = [aws_cloudfront_distribution.cloudfront_distribution]
}
