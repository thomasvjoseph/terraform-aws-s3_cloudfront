# Terraform S3 + CloudFront Module

This Terraform module deploys an AWS S3 bucket fronted by a CloudFront distribution with optional **failover origin**, supporting both **OAC** (recommended) and **OAI** (legacy).  

It also supports optional **Origin Request Policy** for controlling headers, cookies, and query strings sent to your origin.

---

## Features

- Create an S3 bucket (Primary and optional Failover)
- CloudFront Distribution
  - Primary + Failover origin group
  - Custom cache behavior
  - HTTPS with default CloudFront certificate
  - Geo-restriction (whitelist/blacklist)
  - Custom error responses
  - Optional logging
- Origin Access Control (OAC) or Origin Access Identity (OAI)
- Optional custom CloudFront **Origin Request Policy** (forward headers, cookies, query strings)
- Fully tagged resources
- Optional `force_destroy` for buckets

---

## Requirements

- Terraform >= 1.0
- AWS Provider >= 6.0

---

## Usage

### Basic (Primary S3 only)

```hcl
module "cdn" {
  source = "./s3-cloudfront"

  s3_bucket_name          = "my-primary-bucket"
  cloudfront_description  = "Primary CDN Distribution"

  tags = {
    Environment = "prod"
    Project     = "cdn"
  }
}
````

### With Failover S3

```hcl
module "cdn_failover" {
  source = "./s3-cloudfront"

  s3_bucket_name          = "my-primary-bucket"
  failover_s3_bucket_name = "my-failover-bucket"
  enable_failover         = true
  cloudfront_description  = "Primary + Failover CDN"

  tags = {
    Environment = "prod"
    Project     = "cdn"
  }
}
```

### With Custom Origin Request Policy

```hcl
module "cdn_api" {
  source = "./s3-cloudfront"

  s3_bucket_name          = "my-api-bucket"
  cloudfront_description  = "API Distribution"

  create_origin_request_policy = true
  forward_headers              = ["Authorization", "CloudFront-Viewer-Country"]
  forward_cookies              = "all"
  forward_query_strings        = "all"

  tags = {
    Environment = "prod"
    Project     = "api"
  }
}
```

### Use Existing Origin Request Policy

```hcl
module "cdn_existing_policy" {
  source = "./s3-cloudfront"

  s3_bucket_name         = "my-bucket"
  cloudfront_description = "Existing policy CDN"

  origin_request_policy_id = "216adef6-5c7f-47e4-b989-5492eafa07d3" # AWS Managed Policy ID
}
```

---

## Variables

| Name                           | Description                                                    | Type           | Default                     |
| ------------------------------ | -------------------------------------------------------------- | -------------- | --------------------------- |
| `create_resources`             | Create resources or skip                                       | `bool`         | `true`                      |
| `s3_bucket_name`               | Primary S3 bucket name                                         | `string`       | -                           |
| `failover_s3_bucket_name`      | Failover S3 bucket name                                        | `string`       | `null`                      |
| `enable_failover`              | Enable CloudFront origin failover                              | `bool`         | `false`                     |
| `cloudfront_description`       | Description for CloudFront                                     | `string`       | -                           |
| `origin_access_control`        | Use OAC instead of OAI                                         | `bool`         | `true`                      |
| `force_destroy`                | Allow S3 deletion even if not empty                            | `bool`         | `false`                     |
| `create_origin_request_policy` | Create custom Origin Request Policy                            | `bool`         | `false`                     |
| `origin_request_policy_id`     | Use existing origin request policy                             | `string`       | `null`                      |
| `forward_headers`              | Headers to forward to origin                                   | `list(string)` | `[]`                        |
| `forward_cookies`              | Cookies forwarding behavior (`none`, `all`, `whitelist`)       | `string`       | `none`                      |
| `forward_cookie_names`         | Cookie names to forward if whitelist                           | `list(string)` | `[]`                        |
| `forward_query_strings`        | Query strings forwarding behavior (`none`, `all`, `whitelist`) | `string`       | `none`                      |
| `forward_query_string_names`   | Query string names if whitelist                                | `list(string)` | `[]`                        |
| `enable_logging`               | Enable CloudFront access logs                                  | `bool`         | `false`                     |
| `logs_bucket`                  | S3 bucket for CloudFront logs                                  | `string`       | `null`                      |
| `geo_restriction_type`         | `none`, `whitelist`, or `blacklist`                            | `string`       | `none`                      |
| `geo_locations_list`           | ISO country codes for geo restriction                          | `list(string)` | `[]`                        |
| `allowed_methods`              | CloudFront allowed methods                                     | `list(string)` | `[GET, HEAD]`               |
| `cache_policy_id`              | Cache policy ID                                                | `string`       | AWS Managed Default         |
| `response_headers_policy_id`   | Response headers policy ID                                     | `string`       | AWS Managed Default         |
| `failover_status_codes`        | HTTP codes to trigger failover                                 | `list(number)` | `[403,404,500,502,503,504]` |
| `error_responses`              | Map of custom error responses                                  | `map(object)`  | `null`                      |
| `tags`                         | Resource tags                                                  | `map(string)`  | `{}`                        |

---

## Outputs

| Name                         | Description                          |
| ---------------------------- | ------------------------------------ |
| `primary_bucket`             | Primary S3 bucket name               |
| `failover_bucket`            | Failover S3 bucket name (if enabled) |
| `cloudfront_distribution_id` | CloudFront distribution ID           |
| `cloudfront_domain_name`     | CloudFront domain name               |

---

## Notes

* Failover works only for **GET/HEAD** requests. POST/PUT requests **cannot failover**.
* Use `force_destroy = true` carefully in production—it will delete all bucket objects.
* OAC is recommended over OAI (newer AWS standard).
* Use `origin_request_policy_id` if you want to attach an existing AWS managed policy.

---



