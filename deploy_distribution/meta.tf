terraform {
  required_version = ">= 1.0.0"
  backend "s3" {}

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.6.0"
    }
  }

}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = {
      Project = var.website_domain_main
    }
  }

}