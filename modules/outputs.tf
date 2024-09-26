output "s3_bucket_names" {
  value = module.S3.s3_bucket_name
}

output "cloudfront_distribution_ids" {
  value = module.cloudfront.cloudfront_distribution_id
}

output "cloudfront_distribution_arns" {
  value = module.cloudfront.cloudfront_distribution_arn
}

output "cloudfront_distribution_domain_names" {
  value = module.cloudfront.distribution_domain_name
}
