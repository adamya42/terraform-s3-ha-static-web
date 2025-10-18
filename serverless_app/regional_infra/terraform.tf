terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.7.1"
    }
  }
}

locals {
  instances = {
    "instance-1" = "instance-1"
    "instance-2" = "instance-2"
  }
}