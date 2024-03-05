terraform {
  backend "s3" {
    bucket = "terraform-backend-traefik"
    key    = "statefile/terraform.tfstate"
    region = "us-west-2"
  }
}
