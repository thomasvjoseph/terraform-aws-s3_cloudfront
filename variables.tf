variable "s3_bucket_name" {
    description     = "S3 bucket name"
    type            = string
}

variable "cloudfront_description" {
    description     = "Cloudfront description"
    type            = string
}

variable "name" {
    description     = "tag name"
    type            = string
}

variable "env" {
    description     = "tag env"
    type            = string
}