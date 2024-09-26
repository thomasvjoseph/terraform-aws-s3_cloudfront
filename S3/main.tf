resource "aws_s3_bucket" "example" {
  for_each                = var.s3_resources

  bucket                  = each.value.s3_bucket_name
  force_destroy           = true
  tags = {
    Name                  = each.value.name
    Environment           = each.value.env
    Terraform             = "true"
  }
}

resource "aws_s3_account_public_access_block" "example_block" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
