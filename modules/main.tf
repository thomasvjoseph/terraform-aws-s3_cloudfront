module "S3" {
  source                          = "../S3"
  s3_resources                    = {
    "resource-1" = {
      s3_bucket_name              = var.s3_bucket_name1
      name                        = var.s3_tag1
      env                         = var.s3_env1
    }
  }
}

module "cloudfront" {
  source                          = "../Cloudfront"
  cloudfront_resources            = {
    "resource-1" = {
      cloudfront_description      = var.cloudfront_description1
      s3_bucket_domain_name       = module.S3.s3_bucket_domain_name["resource-1"]
      s3_bucket_name              = module.S3.s3_bucket_name["resource-1"]
    }
  }
}