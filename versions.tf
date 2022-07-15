terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.74.0"
    }
    awsutils = {
      source  = "cloudposse/awsutils"
      version = ">= 0.11.1"
    }
  }
}
