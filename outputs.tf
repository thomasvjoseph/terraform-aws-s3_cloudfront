output "s3_primary_bucket_name" {
  value = try(aws_s3_bucket.primary[0].bucket, null)
}

output "s3_failover_bucket_name" {
  value = try(aws_s3_bucket.failover[0].bucket, null)
}

output "cloudfront_distribution_id" {
  value = try(aws_cloudfront_distribution.this[0].id, null)
}

output "cloudfront_domain_name" {
  value = try(aws_cloudfront_distribution.this[0].domain_name, null)
}

output "oai_path" {
  value = try(aws_cloudfront_origin_access_identity.oai[0].cloudfront_access_identity_path, null)
}