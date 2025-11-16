# Development Ortamı - Ana Konfigürasyon

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
      Environment = "dev"
      Project     = "actions-deneme"
      ManagedBy   = "Terraform"
      Owner       = "DevOps Team"
    }
  }
}

# VPC Modülü
module "vpc" {
  source = "../../modules/vpc"

  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  environment        = "dev"
  ssh_allowed_cidrs  = var.ssh_allowed_cidrs

  tags = {
    Environment = "dev"
    Project     = "actions-deneme"
    ManagedBy   = "Terraform"
  }
}

# Compute Modülü
module "compute" {
  source = "../../modules/compute"

  instance_count    = var.instance_count
  instance_type     = var.instance_type
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.vpc.web_security_group_id
  key_name          = var.key_name
  environment       = "dev"
  docker_image      = var.docker_image
  enable_elastic_ip = var.enable_elastic_ip
  volume_type       = var.volume_type
  volume_size       = var.volume_size

  tags = {
    Environment = "dev"
    Project     = "actions-deneme"
    ManagedBy   = "Terraform"
  }
}

# Redis Modülü
module "redis" {
  source = "../../modules/redis"

  environment                = "dev"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.private_subnet_ids
  security_group_ids         = [module.vpc.redis_security_group_id]
  create_security_group      = false # VPC modülünden security group kullanıyoruz
  allowed_security_group_ids = [module.vpc.web_security_group_id]

  # Redis ayarları
  node_type                  = "cache.t3.micro" # Dev için küçük instance
  num_cache_clusters         = 1                # Dev için tek node
  automatic_failover_enabled = false
  multi_az_enabled           = false

  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = false # Dev için opsiyonel

  # Snapshot
  snapshot_retention_limit = 1 # Dev için 1 gün

  tags = {
    Environment = "dev"
    Project     = "actions-deneme"
    ManagedBy   = "Terraform"
    Odev5       = "CI/CD-Pipeline-Test" # Ödev 5: CI/CD test için eklenen tag
  }
}

