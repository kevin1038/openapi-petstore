terraform {
  backend "s3" {
    bucket = "terraform-state-openapi-petstore"
    key = "terraform.tfstate"
    region = "ap-southeast-1"
    dynamodb_table = "terraform-state-locking-openapi-petstore"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34"
    }
  }

  required_version = "~> 1.3.0"
}
