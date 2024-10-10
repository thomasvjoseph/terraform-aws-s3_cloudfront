# Terraform AWS S3 & CloudFront Infrastructure Module

This Terraform module provisions an AWS infrastructure for deploying a static website using Amazon S3 as the origin and CloudFront as the content delivery network (CDN). It includes automatic creation of an S3 bucket, a CloudFront distribution, and associated policies for secure access.

## Features

- Creates an S3 bucket for storing static website content.
- Provisions a CloudFront distribution with an Origin Access Identity (OAI) to serve content securely from S3.
- Automatically generates an S3 bucket policy to allow CloudFront to access the bucket.
- Tags resources with customizable tags.
- Automatically invalidates the CloudFront cache after deployment.
  
If after deployment, you encounter an error such as:
```xml
  <Error>
    <Code>AccessDenied</Code>
    <Message>Access Denied</Message>
    <RequestId>123456qwerty</RequestId>
    <HostId>qbjlTQsuqWDwLDFiU8388JgbYQZmLIZghlL3nhN0gWZRXW4wbB0V1MtRpfA4WP/DzrjrTxdgRc3DznoKuGsNww==</HostId>
  </Error>
```

It may be necessary to manually create an Origin Access Identity (OAI) in the AWS console, update the S3 bucket policy with the correct OAI, and remove any old S3 bucket policy created by Terraform.

## Usage

Example Configuration
```hcl
  module "s3_cloudfront" {
    source = "github.com/thomasvjoseph/terraform-aws-s3-cloudfront"

    s3_bucket_name           = "your-website-bucket"
    cloudfront_description   = "My CloudFront Distribution"
    name                     = "my-static-website"
    env                      = "production"
  }
```
## Steps:

	1.	Deploy your static website files to the S3 bucket that is created by this module.
	2.	Ensure that the CloudFront distribution is configured correctly to point to the S3 bucket.
	3.	If necessary, invalidate the CloudFront cache to reflect the latest changes to your website.
	4.	If you get an access error, manually update the Origin Access Identity in the AWS console and update the bucket policy accordingly.

## Inputs

| Name                       | Description                                 | Type     | Default | Required |
|----------------------------|---------------------------------------------|----------|---------|----------|
| `s3_bucket_name`           | The name of the S3 bucket to create         | `string` | n/a     | yes      |
| `cloudfront_description`   | Description for the CloudFront distribution | `string` | n/a     | yes      |
| `name`                     | Tag name to be applied to AWS resources.    | `string` | n/a     | yes      |
| `env`                      | nvironment tag for the AWS resources        | `string` | n/a     | yes      |


## Outputs

| Name                                      | Description                                             |
|-------------------------------------------|---------------------------------------------------------|
| `s3_bucket_arn`                           | ARN of the created S3 bucket.                           |
| `s3_bucket_domain_name`                   | Domain name of the S3 bucket.                           |
| `s3_bucket_name`                          | Name of the created S3 bucket.                          |
| `cloudfront_distribution_domain_name`     |   Domain name of the CloudFront distribution.           |
| `cloudfront_distribution_id`              | ID of the CloudFront distribution.                      |
| `origin_access_identity`                  |  Origin Access Identity for the CloudFront distribution.|   


	

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