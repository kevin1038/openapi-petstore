terraform {
  required_version = "1.3.2"

  required_providers {
    archive = {
      version = "2.2.0"
    }

    aws = {
      version = "4.37.0"
    }

    helm = {
      version = "2.7.1"
    }

    kubernetes = {
      version = "2.14.0"
    }

    random = {
      version = "3.4.3"
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
