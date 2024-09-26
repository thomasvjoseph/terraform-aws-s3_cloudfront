variable "s3_resources" {
  description = "Map of S3 bucket configurations"
  type = map(object({
    s3_bucket_name  = string
    name            = string
    env             = string
  }))
}