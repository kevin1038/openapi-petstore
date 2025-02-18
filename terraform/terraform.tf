terraform {
  required_version = "~>1.3.0"

  required_providers {
    archive = {
      version = "~>2.2.0"
    }

    aws = {
      version = "~>4.38.0"
    }

    helm = {
      version = "~>2.7.0"
    }

    kubernetes = {
      version = "~>2.15.0"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-openapi-petstore"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking-openapi-petstore"
    encrypt        = true
  }
}
