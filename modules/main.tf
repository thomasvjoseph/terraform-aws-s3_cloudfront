module "S3" {
  source                          = "../S3"
  s3_resources                    = {
    "resource-1" = {
      s3_bucket_name              = var.s3-bucket_name1
      s3_tag                      = var.s3-tag1
      s3_env                      = var.s3-env1
    }
  }
}
 
module "cloudfront" {
  source                          = "../Cloudfront"
  cloudfront_resources            = {
    "resource-1" = {
      cloudfront_description      = var.cloudfront_description1
      s3_bucket_domain_name       = module.S3.s3_bucket_domain_name["resource-1"]
      s3_bucket_name              = module.S3.bucket_name["resource-1"]
    }
  }
}