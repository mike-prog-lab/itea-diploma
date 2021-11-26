terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.66.0"
    }
  }

  backend "s3" {
    bucket = "s3-student7-course-infra"
    key    = "terraform/state/main-global"
    region = "us-east-2"
  }
}

provider "aws" {
  region = "us-east-2"
}
