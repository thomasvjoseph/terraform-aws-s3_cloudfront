variable "cloudfront_resources" {
  description = "Map of CloudFront configurations"
  type = map(object({
    cloudfront_description  = string
    s3_bucket_domain_name   = string
    s3_bucket_name          = string
  }))
}