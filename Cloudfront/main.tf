resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  for_each                    = var.cloudfront_resources
  comment                     = each.value.s3_bucket_domain_name
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  for_each                    = var.cloudfront_resources

  origin {
    domain_name               = each.value.s3_bucket_domain_name
    origin_id                 = each.value.s3_bucket_name

    s3_origin_config { 
      origin_access_identity  = aws_cloudfront_origin_access_identity.cf_oai[each.key].cloudfront_access_identity_path
    }
  }
  
  enabled                     = true
  is_ipv6_enabled             = true
  default_root_object         = "index.html"

  default_cache_behavior {
    allowed_methods           = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods            = ["GET", "HEAD"]
    target_origin_id          = each.value.s3_bucket_name

    viewer_protocol_policy    = "redirect-to-https"
    min_ttl                   = 0
    default_ttl               = 3600
    max_ttl                   = 86400

    cache_policy_id           = "658327ea-f89d-4fab-a63d-7e88639e58f6"
  }

  restrictions {
    geo_restriction {
      restriction_type        = "none"
    }
  }

  custom_error_response {
    error_code                = 403
    response_code             = 200
    response_page_path        = "/index.html"
    error_caching_min_ttl     = 10
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Environment               = "production"
    Terraform                 = "true"
  }

  comment                     = each.value.cloudfront_description
}
