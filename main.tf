resource "aws_s3_bucket" "s3_bucket" {
  bucket                    = var.s3_bucket_name
  force_destroy             = true

  tags                      = {
    Name                    = var.name
    Environment             = var.env
    Terraform               = "true"
  }
}

resource "aws_cloudfront_origin_access_identity" "cf_oai" {
  comment                   = "Origin Access Identity for ${aws_s3_bucket.s3_bucket.bucket_domain_name}"
}

resource "aws_cloudfront_distribution" "cloudfront_distribution" {
  origin {
    domain_name             = aws_s3_bucket.s3_bucket.bucket_domain_name
    origin_id               = aws_s3_bucket.s3_bucket.bucket

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path
    }
  }

  enabled                   = true
  is_ipv6_enabled           = true
  default_root_object       = "index.html"

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
      restriction_type    = "none"
    }
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    response_page_path    = "/index.html"
    error_caching_min_ttl = 10
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name                = var.name
    Environment         = var.env
    Terraform           = "true"
  }
  comment               = var.cloudfront_description
  depends_on            = [aws_s3_bucket.s3_bucket]
}
# S3 - Bucket Policy for CloudFront
data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions           = ["s3:GetObject"]
    resources         = ["${aws_s3_bucket.s3_bucket.arn}/*"]

    principals {
      type            = "AWS"
      identifiers     = [aws_cloudfront_origin_access_identity.cf_oai.iam_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket              = aws_s3_bucket.s3_bucket.id
  policy              = data.aws_iam_policy_document.s3_policy.json

  # This ensures that if the policy changes, the old one will be deleted
  lifecycle {
    replace_triggered_by = [aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path]
  }
}