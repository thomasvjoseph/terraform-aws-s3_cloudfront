variable "create_resources" {
  type    = bool
  default = true
}

variable "origin_access_control" {
  type    = bool
  default = true
}

variable "force_destroy" {
  description = "Allow bucket deletion even if not empty"
  type        = bool
  default     = false
}

variable "s3_bucket_name" {
  type = string
}

variable "failover_s3_bucket_name" {
  type    = string
  default = null
}

variable "enable_failover" {
  type    = bool
  default = false
}

variable "cloudfront_description" {
  type = string
}

variable "allowed_methods" {
  type    = list(string)
  default = ["GET", "HEAD"]
}

variable "cache_policy_id" {
  type    = string
  default = "658327ea-f89d-4fab-a63d-7e88639e58f6"
}

variable "response_headers_policy_id" {
  type    = string
  default = "67f7725c-6f97-4210-82d7-5512b31e9d03"
}

variable "failover_status_codes" {
  type    = list(number)
  default = [403, 404, 500, 502, 503, 504]
}

variable "enable_logging" {
  type    = bool
  default = false
}

variable "logs_bucket" {
  type    = string
  default = null
}

variable "error_responses" {
  type = map(object({
    error_code            = number
    response_code         = number
    response_page_path    = string
    error_caching_min_ttl = number
  }))
  default = null
}

variable "geo_restriction_type" {
  type    = string
  default = "none"
}

variable "geo_locations_list" {
  type    = list(string)
  default = []
}

variable "tags" {
  type    = map(string)
  default = {}
}