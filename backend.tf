terraform {
  backend "s3" {}
}

data "terraform_remote_state" "state" {
  backend = "s3"
  config = {
    bucket = var.bucket_name
    key    = var.key_file
    region = var.region_bucket
  }
}
