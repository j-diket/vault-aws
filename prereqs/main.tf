terraform {
  required_version = ">= 1.2.1"

  required_providers {
    aws = ">= 3.0.0, < 4.0.0"
    tls = ">= 3.0.0, < 4.0.0"
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "./aws-vpc/"

  azs                  = var.azs
  common_tags          = var.tags
  resource_name_prefix = var.resource_name_prefix
}

module "secrets" {
  source = "./secrets/"

  resource_name_prefix = var.resource_name_prefix
}