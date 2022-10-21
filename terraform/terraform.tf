terraform {
  required_version = "1.3.2"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.36.1"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.4.3"
    }
  }

  backend "s3" {
    bucket         = "terraform-state-openapi-petstore"
    key            = "terraform.tfstate"
    region         = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking-openapi-petstore"
    encrypt = true
  }
}
