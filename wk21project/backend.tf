terraform {
  backend "s3" {
    bucket = "remote-backend-jreid"
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}