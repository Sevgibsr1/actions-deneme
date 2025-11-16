# Redis Modülü - Çıktılar

output "replication_group_id" {
  description = "ElastiCache Replication Group ID"
  value       = aws_elasticache_replication_group.redis.replication_group_id
}

output "replication_group_arn" {
  description = "ElastiCache Replication Group ARN"
  value       = aws_elasticache_replication_group.redis.arn
}

output "primary_endpoint_address" {
  description = "Redis primary endpoint address (hostname)"
  value       = aws_elasticache_replication_group.redis.primary_endpoint_address
}

output "primary_endpoint_port" {
  description = "Redis primary endpoint port"
  value       = aws_elasticache_replication_group.redis.port
}

output "reader_endpoint_address" {
  description = "Redis reader endpoint address (read replicas için)"
  value       = aws_elasticache_replication_group.redis.reader_endpoint_address
}

output "reader_endpoint_port" {
  description = "Redis reader endpoint port"
  value       = aws_elasticache_replication_group.redis.port
}

output "configuration_endpoint_address" {
  description = "Redis configuration endpoint address (cluster mode için)"
  value       = aws_elasticache_replication_group.redis.configuration_endpoint_address
}

output "subnet_group_id" {
  description = "ElastiCache Subnet Group ID"
  value       = aws_elasticache_subnet_group.redis.id
}

output "subnet_group_name" {
  description = "ElastiCache Subnet Group Name"
  value       = aws_elasticache_subnet_group.redis.name
}

output "security_group_id" {
  description = "Redis Security Group ID (eğer oluşturulduysa)"
  value       = var.create_security_group ? aws_security_group.redis[0].id : null
}

