terraform {
  backend "s3" {
    bucket = var.bucket_name
    key    = var.key_file
    region = var.region_bucket
  }
}
