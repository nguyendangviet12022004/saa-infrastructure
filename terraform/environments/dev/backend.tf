terraform {
  backend "s3" {
    bucket = "ssa-tfstate-069868844002-ap-southeast-1-an"
    key    = "dev/ap-southeast-1/terraform.tfstate"
    region = "ap-southeast-1"
  }
}
