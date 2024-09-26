output "s3_bucket_arn" {
  value = { for k, v in aws_s3_bucket.example : k => v.arn }
}

output "s3_bucket_name" {
  value = { for k, v in aws_s3_bucket.example : k => v.bucket }
}

output "s3_bucket_domain_name" {
  value = { for k, v in aws_s3_bucket.example : k => v.bucket_domain_name }
}