# Redis Modülü - ElastiCache Redis Cluster
# Bu modül AWS ElastiCache Redis cluster'ı oluşturur

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Subnet Group oluştur (Redis için private subnet'ler kullanılır)
resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.environment}-redis-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-redis-subnet-group"
    }
  )
}

# Security Group - Redis için (eğer VPC modülünden alınmıyorsa)
resource "aws_security_group" "redis" {
  count = var.create_security_group ? 1 : 0

  name        = "${var.environment}-redis-elasticache-sg"
  description = "Security group for ElastiCache Redis"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Redis"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-redis-elasticache-sg"
    }
  )
}

# ElastiCache Replication Group (Redis Cluster)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${var.environment}-redis"
  description                = "Redis cluster for ${var.environment} environment"
  
  # Engine ayarları
  engine                     = "redis"
  engine_version             = var.engine_version
  node_type                  = var.node_type
  port                       = 6379
  parameter_group_name       = var.parameter_group_name
  
  # Cluster ayarları
  num_cache_clusters         = var.num_cache_clusters
  automatic_failover_enabled = var.automatic_failover_enabled
  multi_az_enabled          = var.multi_az_enabled
  
  # Network ayarları
  subnet_group_name          = aws_elasticache_subnet_group.redis.name
  security_group_ids         = var.create_security_group ? [aws_security_group.redis[0].id] : var.security_group_ids
  
  # Snapshot ayarları
  snapshot_retention_limit   = var.snapshot_retention_limit
  snapshot_window            = var.snapshot_window
  
  # Maintenance window
  maintenance_window         = var.maintenance_window
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  # At-rest encryption
  at_rest_encryption_enabled = var.at_rest_encryption_enabled
  transit_encryption_enabled = var.transit_encryption_enabled
  
  # Log delivery (opsiyonel - sadece destination belirtilmişse)
  dynamic "log_delivery_configuration" {
    for_each = var.log_delivery_destination != "" ? [1] : []
    content {
      destination      = var.log_delivery_destination
      destination_type = var.log_delivery_destination_type
      log_format       = var.log_delivery_log_format
      log_type         = "slow-log"
    }
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.environment}-redis"
    }
  )
}

