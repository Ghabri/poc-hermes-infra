terraform {
  backend "s3" {
    region = "eu-west-1"
    bucket = "facturation-tf-backend"
    key    = "develop/facturation-rest-app/terraform.tfstate"
  }
}

