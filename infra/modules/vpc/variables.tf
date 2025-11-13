# VPC Modülü - Değişkenler

variable "vpc_cidr" {
  description = "VPC CIDR bloğu"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Kullanılacak availability zone'lar"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
}

variable "environment" {
  description = "Ortam adı (dev, prod, staging vb.)"
  type        = string
}

variable "ssh_allowed_cidrs" {
  description = "SSH erişimine izin verilen CIDR blokları"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Production'da daha kısıtlayıcı olmalı!
}

variable "tags" {
  description = "Tüm kaynaklara eklenecek tag'ler"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "actions-deneme"
  }
}

