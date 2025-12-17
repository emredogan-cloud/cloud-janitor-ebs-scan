terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    # Used to build the Lambda deployment ZIP from local source files.
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.5"
    }
  }
}

# AWS provider configuration. All resources will be created in this region.
provider "aws" {
  region = var.aws_region
}
