output "cloudfront_distribution_id" {
  value = { for k, v in aws_cloudfront_distribution.cloudfront_distribution : k => v.id }
}
  
output "cloudfront_distribution_arn" {
  value = { for k, v in aws_cloudfront_distribution.cloudfront_distribution : k => v.arn }
}

output "cloudfront_origin_access_identity_iam_arn" {
  value = { for k, v in aws_cloudfront_origin_access_identity.cf_oai : k => v.iam_arn }
}

output "origin_access_identity" {
  value = { for k, v in aws_cloudfront_origin_access_identity.cf_oai : k => v.iam_arn }
}

output "disribution_domain_name" {
  value = { for k, v in aws_cloudfront_distribution.cloudfront_distribution : k => v.domain_name }
}