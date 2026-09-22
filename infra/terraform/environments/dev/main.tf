terraform {
  required_version = ">= 1.7.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.50"
    }
  }

  # In AWS production, this points to S3 backend created via s3_dynamodb module:
  # backend "s3" {
  #   bucket         = "ecommerce-platform-dev-tfstate"
  #   key            = "state/terraform.tfstate"
  #   region         = "us-east-1"
  #   dynamodb_table = "ecommerce-platform-dev-tflocks"
  # }
}

provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source      = "../../modules/vpc"
  environment = "dev"
  vpc_cidr    = "10.0.0.0/16"
}

module "eks" {
  source          = "../../modules/eks"
  cluster_name    = "ecommerce-eks-dev"
  cluster_version = "1.30"
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.private_subnets
}

module "karpenter" {
  source            = "../../modules/karpenter"
  cluster_name      = "ecommerce-eks-dev"
  oidc_provider_arn = module.eks.oidc_provider_arn
}
