provider "aws" {
  region = var.aws_region
}

module "landig-page" {
  source = "../../../modules/facturation-rest-app"

  bucket_name = var.bucket_name
  environment = var.environment
}

