terraform {
  required_version = ">= 1.7"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  backend "local" {
    path = "terraform.tfstate"
  }
}

provider "aws" {
  region = var.aws_region

  access_key = "test"
  secret_key = "test"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    ec2        = var.localstack_endpoint
    ecr        = var.localstack_endpoint
    ecs        = var.localstack_endpoint
    route53    = var.localstack_endpoint
    s3         = var.localstack_endpoint
    iam        = var.localstack_endpoint
    cloudwatch = var.localstack_endpoint
  }
}

module "vpc" {
  source = "./modules/vpc"

  app_name           = var.app_name
  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
}

module "ecs" {
  source = "./modules/ecs"

  app_name           = var.app_name
  environment        = var.environment
  container_port     = var.container_port
  container_image    = var.container_image
  vpc_id             = module.vpc.vpc_id
  subnet_ids         = module.vpc.subnet_ids
  security_group_id  = module.vpc.security_group_id
}
