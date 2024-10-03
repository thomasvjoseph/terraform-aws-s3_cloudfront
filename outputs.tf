output "s3_bucket_arn" {
    value = aws_s3_bucket.s3_bucket.arn 
}
output "s3_bucket_domain_name" {
    value = aws_s3_bucket.s3_bucket.bucket_domain_name
}
output "s3_bucket_name" {
    value = aws_s3_bucket.s3_bucket.bucket
}

output "cloudfront_distribution_domain_name" {
    value = aws_cloudfront_distribution.cloudfront_distribution.domain_name
}

output "cloudfront_distribution_id" {
    value = aws_cloudfront_distribution.cloudfront_distribution.id
}

output "origin_access_identity" {
    value = aws_cloudfront_origin_access_identity.cf_oai.cloudfront_access_identity_path  
}