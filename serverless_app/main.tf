# Terraform Script for High Availability and Disaster Recovery with AWS Serverless Architecture
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

  backend "s3" {
    bucket         = "<backend-bucket-name>" # Replace with your S3 bucket name for remote state set the same in ../remote_backend/s3.tf
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"

  }

}

provider "aws" {
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"
}

provider "aws" {
  alias  = "us-west-2"
  region = "us-west-2"
}

locals {
  regions = {
    "us-east-1" = "us-east-1"
    "us-west-2" = "us-west-2"
  }
  failover_type = {
    "us-east-1" = "PRIMARY"
    "us-west-2" = "SECONDARY"
  }
}

module "s3_bucket_east" {
  source = "./s3_bucket"

  frontend_bucket_name = var.frontend_bucket_name_east

  providers = {
    aws = aws.us-east-1
  }
}

module "s3_bucket_west" {
  source = "./s3_bucket"

  frontend_bucket_name = var.frontend_bucket_name_west

  providers = {
    aws = aws.us-west-2
  }
}


module "global" {
  source = "./global"

  frontend_website_endpoint_east = module.s3_bucket_east.frontend_website_endpoint
  frontend_website_endpoint_west = module.s3_bucket_west.frontend_website_endpoint

  depends_on = [module.s3_bucket_east, module.s3_bucket_west]

  providers = {
    aws = aws.us-east-1
  }
}

module "regional_infra_east" {
  source = "./regional_infra"

  dynamodb_table_name = var.ha_table_name
  domain_name         = var.domain_name
  api_gateway_name    = var.api_gateway_name

  lambda_exec_role_arn    = module.global.lambda_exec_role_arn
  lambda_read_zip_path    = module.s3_bucket_east.lambda_read_zip_path
  lambda_read_object_url  = module.s3_bucket_east.lambda_read_object_url
  lambda_write_zip_path   = module.s3_bucket_east.lambda_write_zip_path
  lambda_write_object_url = module.s3_bucket_east.lambda_write_object_url
  frontend_bucket_name    = module.s3_bucket_east.frontend_bucket_name

  depends_on = [
    # aws_s3_object.lambda_read,
    # aws_s3_object.lambda_write,
    aws_dynamodb_table.ha_table,
    module.global
  ]

  providers = {
    aws = aws.us-east-1
  }
}

module "regional_infra_west" {
  source = "./regional_infra"

  dynamodb_table_name = var.ha_table_name
  domain_name         = var.domain_name
  api_gateway_name    = var.api_gateway_name

  lambda_exec_role_arn    = module.global.lambda_exec_role_arn
  lambda_read_zip_path    = module.s3_bucket_west.lambda_read_zip_path
  lambda_read_object_url  = module.s3_bucket_west.lambda_read_object_url
  lambda_write_zip_path   = module.s3_bucket_west.lambda_write_zip_path
  lambda_write_object_url = module.s3_bucket_west.lambda_write_object_url
  frontend_bucket_name    = module.s3_bucket_west.frontend_bucket_name

  depends_on = [
    # aws_s3_object.lambda_read,
    # aws_s3_object.lambda_write,
    aws_dynamodb_table.ha_table,
    module.global
  ]

  providers = {
    aws = aws.us-west-2
  }
}

