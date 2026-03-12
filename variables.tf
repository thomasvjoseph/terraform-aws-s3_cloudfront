variable "create_resources" {
  description = "Set to false to have this module skip creating resources. This weird parameter exists solely because Terraform does not support conditional modules. Therefore, this is a hack to allow you to conditionally decide if the resources in this module should be created or not."
  type        = bool
  default     = true
}

variable "origin_access_control" {
  description = "Set to true to use OAC (Origin Access Control) instead of OAI (Origin Access Identity). OAC is the newer AWS-recommended approach."
  type        = bool
  default     = true
}

variable "s3_bucket_name" {
  description = "S3 bucket name"
  type        = string
}

variable "cloudfront_description" {
  description = "Cloudfront description"
  type        = string
}

variable "geo_restriction_type" {
  description = "The method that you want to use to restrict distribution of your content by country: none, whitelist, or blacklist."
  type        = string
  default     = "none"
}

variable "geo_locations_list" {
  description = "The ISO 3166-1-alpha-2 codes for which you want CloudFront either to distribute your content (if var.geo_restriction_type is whitelist) or not distribute your content (if var.geo_restriction_type is blacklist)."
  type        = list(string)
  default     = []
}


variable "error_responses" {
  description = "The error responses you want CloudFront to return to the viewer."
  type = map(
    object({
      response_code         = number
      response_page_path    = string
      error_caching_min_ttl = number
    })
  )
  default = null
  # Example:
  #
  # default = {
  #   404 = {
  #     response_code         = 404
  #     response_page_path    = "404.html"
  #     error_caching_min_ttl = 0
  #   }
  # }
}


variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}