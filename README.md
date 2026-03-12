# Terraform AWS S3 & CloudFront Infrastructure Module

This Terraform module provisions an AWS infrastructure for deploying a static website using Amazon S3 as the origin and CloudFront as the content delivery network (CDN). It includes automatic creation of an S3 bucket, a CloudFront distribution, and associated policies for secure access.

## Features

- Creates an S3 bucket for storing static website content.
- Provisions a CloudFront distribution with an Origin Access Identity (OAI) to serve content securely from S3.
- Automatically generates an S3 bucket policy to allow CloudFront to access the bucket.
- Tags resources with customizable tags.
- Automatically invalidates the CloudFront cache after deployment.

It may be necessary to manually create an Origin Access Identity (OAI) in the AWS console, update the S3 bucket policy with the correct OAI, and remove any old S3 bucket policy created by Terraform.

## Usage

Example configuration
```hcl
module "s3_cloudfront" {
  source                 = "github.com/thomasvjoseph/terraform-aws-s3-cloudfront"

  # core inputs
  s3_bucket_name         = "your-website-bucket"
  cloudfront_description = "My CloudFront Distribution"

  # optional behavior toggles
  create_resources       = true            # set to false to skip resource creation
  origin_access_control  = true            # enable OAC instead of OAI

  # geo restrictions (if required)
  geo_restriction_type   = "whitelist"
  geo_locations_list     = ["US", "CA"]

  # custom error pages
  # error_responses = {
  #   404 = {
  #     response_code         = 404
  #     response_page_path    = "/404.html"
  #     error_caching_min_ttl = 0
  #   }
  # }

  # tags map
  tags = {
    Name = "my-static-website"
    Env  = "production"
  }
}
```

### Deployment steps

1. Deploy your static website files to the S3 bucket created by this module.
2. Verify the CloudFront distribution is pointing to the bucket and working correctly.
3. If you update content and need to force changes, invalidate the CloudFront cache.
4. In case of access errors, check the OAI/OAC in the AWS Console and adjust the S3 bucket policy accordingly.

## Inputs

| Name                       | Description                                                                                               | Type                | Default | Required |
|----------------------------|-----------------------------------------------------------------------------------------------------------|---------------------|---------|----------|
| `create_resources`         | Set to false to skip creating resources (conditional module hack).                                        | `bool`              | `true`  | no       |
| `origin_access_control`    | Use OAC instead of OAI for CloudFront origin access.                                                      | `bool`              | `true`  | no       |
| `s3_bucket_name`           | Name of the S3 bucket to create.                                                                          | `string`            | n/a     | yes      |
| `cloudfront_description`   | Description for the CloudFront distribution.                                                              | `string`            | n/a     | yes      |
| `geo_restriction_type`     | Method to restrict distribution by country: `none`, `whitelist`, or `blacklist`.                          | `string`            | `"none"` | no    |
| `geo_locations_list`       | List of ISO 3166-1-alpha-2 country codes for geo restrictions.                                            | `list(string)`      | `[]`    | no       |
| `error_responses`          | Map of error response configurations for CloudFront viewers (see variable docs for structure).            | `map(object)`       | `null`  | no       |
| `tags`                     | Map of tags to assign to resources.                                                                       | `map(string)`       | `{}`    | no       |

The module also supports the common tagging inputs such as `name` and `env` which should be provided via `tags` if desired.


## Outputs

| Name                                      | Description                                             |
|-------------------------------------------|---------------------------------------------------------|
| `s3_bucket_arn`                           | ARN of the created S3 bucket.                           |
| `s3_bucket_domain_name`                   | Domain name of the S3 bucket.                           |
| `s3_bucket_name`                          | Name of the created S3 bucket.                          |
| `cloudfront_distribution_domain_name`     | Domain name of the CloudFront distribution.             |
| `cloudfront_distribution_id`              | ID of the CloudFront distribution.                      |
| `origin_access_identity`                  | CloudFront origin access identity path (OAI/OAC).      |


	

## Prerequisites

	•	Terraform 0.12 or later
	•	AWS credentials configured with appropriate permissions to create S3 buckets, CloudFront distributions, and policies.
Manual Steps (if needed)

If your CloudFront distribution encounters issues (e.g., Access Denied errors), follow these steps:

	1.	Navigate to the AWS Console.
	2.	Manually create a CloudFront Origin Access Identity (OAI).
	3.	Update the S3 bucket policy to allow the new OAI to access the S3 bucket.
	4.	Remove the old S3 bucket policy created by Terraform, if applicable.

## License

This module is licensed under the MIT License.

## Author: 

thomas joseph
- [linkedin](https://www.linkedin.com/in/thomas-joseph-88792b132/)
- [medium](https://medium.com/@thomasvjoseph)