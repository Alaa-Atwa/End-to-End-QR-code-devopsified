terraform {
  required_version = ">= 1.5"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source = "../../modules/vpc"

  project_name         = var.project_name
  azs                  = var.azs
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
}

module "ecr" {
  source = "../../modules/ecr"

  project_name     = var.project_name
  repository_names = ["qr-code-api", "qr-code-frontend"]
}

module "s3" {
  source = "../../modules/s3"

  project_name = var.project_name
  bucket_name  = var.app_bucket_name
}

module "iam" {
  source = "../../modules/iam"

  project_name = var.project_name
}

module "eks" {
  source = "../../modules/eks"

  project_name        = var.project_name
  cluster_role_arn    = module.iam.cluster_role_arn
  node_role_arn       = module.iam.node_role_arn
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
}