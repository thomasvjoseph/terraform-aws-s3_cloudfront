locals {
  enabled = var.create_resources
  use_oac = local.enabled && var.origin_access_control
  use_oai = local.enabled && !var.origin_access_control
}

data "aws_partition" "current" {}

# ---------------------------
# S3 Buckets
# ---------------------------
resource "aws_s3_bucket" "primary" {
  count         = local.enabled ? 1 : 0
  bucket        = var.s3_bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

resource "aws_s3_bucket" "failover" {
  count         = local.enabled && var.enable_failover ? 1 : 0
  bucket        = var.failover_s3_bucket_name
  force_destroy = var.force_destroy
  tags          = var.tags
}

# ---------------------------
# OAI
# ---------------------------
resource "aws_cloudfront_origin_access_identity" "oai" {
  count   = local.use_oai ? 1 : 0
  comment = "OAI for ${var.s3_bucket_name}"
}

# ---------------------------
# OAC
# ---------------------------
resource "aws_cloudfront_origin_access_control" "oac" {
  count                             = local.use_oac ? 1 : 0
  name                              = "OAC-${var.s3_bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# ---------------------------
# Origin Request Policy
# ---------------------------
resource "aws_cloudfront_origin_request_policy" "this" {
  count = var.create_origin_request_policy ? 1 : 0

  name    = var.origin_request_policy_name
  comment = "Custom origin request policy"

  cookies_config {
    cookie_behavior = var.forward_cookies

    dynamic "cookies" {
      for_each = var.forward_cookies == "whitelist" ? [1] : []
      content {
        items = var.forward_cookie_names
      }
    }
  }

  headers_config {
    header_behavior = length(var.forward_headers) > 0 ? "whitelist" : "none"

    dynamic "headers" {
      for_each = length(var.forward_headers) > 0 ? [1] : []
      content {
        items = var.forward_headers
      }
    }
  }

  query_strings_config {
    query_string_behavior = var.forward_query_strings

    dynamic "query_strings" {
      for_each = var.forward_query_strings == "whitelist" ? [1] : []
      content {
        items = var.forward_query_string_names
      }
    }
  }
}
# ---------------------------
# CloudFront
# ---------------------------
resource "aws_cloudfront_distribution" "this" {
  count = local.enabled ? 1 : 0

  enabled             = true
  is_ipv6_enabled     = true
  comment             = var.cloudfront_description
  default_root_object = "index.html"

  # PRIMARY
  origin {
    domain_name = aws_s3_bucket.primary[0].bucket_regional_domain_name
    origin_id   = "primary-origin"

    origin_access_control_id = local.use_oac ? aws_cloudfront_origin_access_control.oac[0].id : null

    dynamic "s3_origin_config" {
      for_each = local.use_oai ? [1] : []
      content {
        origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai[0].id}"
      }
    }
  }

  # FAILOVER
  dynamic "origin" {
    for_each = var.enable_failover ? [1] : []
    content {
      domain_name = aws_s3_bucket.failover[0].bucket_regional_domain_name
      origin_id   = "failover-origin"

      origin_access_control_id = local.use_oac ? aws_cloudfront_origin_access_control.oac[0].id : null

      dynamic "s3_origin_config" {
        for_each = local.use_oai ? [1] : []
        content {
          origin_access_identity = "origin-access-identity/cloudfront/${aws_cloudfront_origin_access_identity.oai[0].id}"
        }
      }
    }
  }

  # ORIGIN GROUP (FAILOVER)
  dynamic "origin_group" {
    for_each = var.enable_failover ? [1] : []
    content {
      origin_id = "origin-group"

      failover_criteria {
        status_codes = var.failover_status_codes
      }

      member {
        origin_id = "primary-origin"
      }

      member {
        origin_id = "failover-origin"
      }
    }
  }

  # CACHE BEHAVIOR
  default_cache_behavior {
    target_origin_id = var.enable_failover ? "origin-group" : "primary-origin"

    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = var.allowed_methods
    cached_methods  = ["GET", "HEAD"]

    cache_policy_id            = var.cache_policy_id
    response_headers_policy_id = var.response_headers_policy_id

    origin_request_policy_id = var.origin_request_policy_id != null ? var.origin_request_policy_id : (
      var.create_origin_request_policy ? aws_cloudfront_origin_request_policy.this[0].id : null
    )

    min_ttl     = 0
    default_ttl = 3600
    max_ttl     = 86400
  }

  # GEO
  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_locations_list
    }
  }

  # SSL
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # ERRORS
  dynamic "custom_error_response" {
    for_each = var.error_responses != null ? var.error_responses : {}
    content {
      error_code            = custom_error_response.value.error_code
      response_code         = custom_error_response.value.response_code
      response_page_path    = custom_error_response.value.response_page_path
      error_caching_min_ttl = custom_error_response.value.error_caching_min_ttl
    }
  }

  # LOGGING
  dynamic "logging_config" {
    for_each = var.enable_logging ? [1] : []
    content {
      include_cookies = false
      bucket          = var.logs_bucket
      prefix          = "cloudfront/"
    }
  }

  tags = var.tags
}

# ---------------------------
# S3 POLICY (PRIMARY ONLY)
# ---------------------------
data "aws_iam_policy_document" "s3_policy" {
  count = local.enabled ? 1 : 0

  dynamic "statement" {
    for_each = local.use_oac ? [1] : []
    content {
      effect  = "Allow"
      actions = ["s3:GetObject"]

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

  dynamic "statement" {
    for_each = local.use_oai ? [1] : []
    content {
      effect  = "Allow"
      actions = ["s3:GetObject"]

      resources = [
        "arn:${data.aws_partition.current.partition}:s3:::${var.s3_bucket_name}/*"
      ]

      principals {
        type        = "AWS"
        identifiers = [aws_cloudfront_origin_access_identity.oai[0].iam_arn]
      }
    }
  }
}

resource "aws_s3_bucket_policy" "primary" {
  count  = local.enabled ? 1 : 0
  bucket = aws_s3_bucket.primary[0].id
  policy = data.aws_iam_policy_document.s3_policy[0].json
}