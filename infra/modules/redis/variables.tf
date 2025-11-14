# Redis Modülü - Değişkenler

variable "environment" {
  description = "Ortam adı (dev, prod, staging vb.)"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "subnet_ids" {
  description = "Redis için kullanılacak subnet ID'leri (genellikle private subnet'ler)"
  type        = list(string)
}

variable "security_group_ids" {
  description = "Redis için kullanılacak security group ID'leri (VPC modülünden alınabilir)"
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "Redis için yeni security group oluşturulsun mu?"
  type        = bool
  default     = false
}

variable "allowed_security_group_ids" {
  description = "Redis'e erişim izni verilecek security group ID'leri (create_security_group=true ise kullanılır)"
  type        = list(string)
  default     = []
}

variable "engine_version" {
  description = "Redis engine versiyonu"
  type        = string
  default     = "7.0"
}

variable "node_type" {
  description = "Redis node tipi (örneğin: cache.t3.micro, cache.t3.small)"
  type        = string
  default     = "cache.t3.micro"
}

variable "num_cache_clusters" {
  description = "Cache cluster sayısı (1-6 arası)"
  type        = number
  default     = 1
}

variable "automatic_failover_enabled" {
  description = "Otomatik failover etkin mi? (num_cache_clusters >= 2 ise true olmalı)"
  type        = bool
  default     = false
}

variable "multi_az_enabled" {
  description = "Multi-AZ etkin mi?"
  type        = bool
  default     = false
}

variable "parameter_group_name" {
  description = "Redis parameter group adı (varsayılan: default.redis7)"
  type        = string
  default     = "default.redis7"
}

variable "snapshot_retention_limit" {
  description = "Snapshot saklama süresi (gün)"
  type        = number
  default     = 0
}

variable "snapshot_window" {
  description = "Snapshot alma zaman penceresi (UTC, örn: 03:00-05:00)"
  type        = string
  default     = "03:00-05:00"
}

variable "maintenance_window" {
  description = "Bakım zaman penceresi (UTC, örn: sun:05:00-sun:09:00)"
  type        = string
  default     = "sun:05:00-sun:09:00"
}

variable "auto_minor_version_upgrade" {
  description = "Otomatik minor version upgrade etkin mi?"
  type        = bool
  default     = true
}

variable "at_rest_encryption_enabled" {
  description = "At-rest encryption etkin mi?"
  type        = bool
  default     = true
}

variable "transit_encryption_enabled" {
  description = "Transit encryption etkin mi?"
  type        = bool
  default     = false
}

variable "log_delivery_destination" {
  description = "Log delivery destination (CloudWatch Logs group ARN)"
  type        = string
  default     = ""
}

variable "log_delivery_destination_type" {
  description = "Log delivery destination type (cloudwatch-logs)"
  type        = string
  default     = "cloudwatch-logs"
}

variable "log_delivery_log_format" {
  description = "Log format (text veya json)"
  type        = string
  default     = "text"
}

variable "tags" {
  description = "Tüm kaynaklara eklenecek tag'ler"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "actions-deneme"
  }
}

