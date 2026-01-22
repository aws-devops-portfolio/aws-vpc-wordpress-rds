terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.92"
    }

  }

  required_version = ">= 1.2"

  backend "s3" {
    bucket       = "devhub164-state-demo"
    key          = "s3-github-actions/wordpress.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}

provider "aws" {
  region = var.region
}
