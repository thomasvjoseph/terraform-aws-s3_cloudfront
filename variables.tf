variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "cloudfront_description" {
  description = "Cloudfront description"
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}