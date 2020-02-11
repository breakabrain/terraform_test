terraform {
  backend "s3" {
    bucket = "terraform.test.123"
    key    = "terraform.tfstate"
    region = "eu-central-1"
  }
}
