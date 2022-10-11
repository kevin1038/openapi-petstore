terraform {
  backend "remote" {
    organization = "kece"
    workspaces {
      name = "openapi-petstore"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.34"
    }
  }

  required_version = ">= 1.3.2"
}

provider "aws" {
  region = "ap-southeast-1"
}
