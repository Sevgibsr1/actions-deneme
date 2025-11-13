# Production Ortamı - Ana Konfigürasyon

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = "prod"
      Project     = "actions-deneme"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
    }
  }
}

# VPC Modülü
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr          = var.vpc_cidr
  availability_zones = var.availability_zones
  environment       = "prod"
  ssh_allowed_cidrs = var.ssh_allowed_cidrs # Production'da daha kısıtlayıcı!

  tags = {
    Environment = "prod"
    Project     = "actions-deneme"
    ManagedBy   = "Terraform"
  }
}

# Compute Modülü - Production için daha fazla instance ve daha güçlü tip
module "compute" {
  source = "../../modules/compute"

  instance_count      = var.instance_count
  instance_type       = var.instance_type
  subnet_ids          = module.vpc.public_subnet_ids
  security_group_id   = module.vpc.web_security_group_id
  key_name            = var.key_name
  environment         = "prod"
  docker_image        = var.docker_image
  enable_elastic_ip   = var.enable_elastic_ip
  volume_type         = var.volume_type
  volume_size         = var.volume_size

  tags = {
    Environment = "prod"
    Project     = "actions-deneme"
    ManagedBy   = "Terraform"
  }
}

