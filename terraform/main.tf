# Terraform Configuration for E-Commerce DevOps Platform
# Author: Yagiz Kastamonu
# Date: 2025-12-15

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "ecommerce-devops-platform"
      ManagedBy   = "Terraform"
      Environment = var.environment
      Owner       = "Yagiz Kastamonu"
    }
  }
}
