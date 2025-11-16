# Production Ortamı - Değişkenler

variable "aws_region" {
  description = "AWS bölgesi"
  type        = string
  default     = "eu-central-1"
}

variable "vpc_cidr" {
  description = "VPC CIDR bloğu"
  type        = string
  default     = "10.1.0.0/16" # Prod için farklı CIDR
}

variable "availability_zones" {
  description = "Kullanılacak availability zone'lar"
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b", "eu-central-1c"] # Prod için 3 AZ
}

variable "instance_count" {
  description = "Oluşturulacak EC2 instance sayısı"
  type        = number
  default     = 2 # Prod için en az 2 instance (high availability)
}

variable "instance_type" {
  description = "EC2 instance tipi"
  type        = string
  default     = "t3.micro" # Free Tier için uygun (öğrenme ortamı)
}

variable "key_name" {
  description = "EC2 instance'lar için SSH key pair adı"
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image adı (ECR'den çekilmeli)"
  type        = string
  default     = "" # Production'da mutlaka belirtilmeli!
}

variable "enable_elastic_ip" {
  description = "Elastic IP oluşturulsun mu?"
  type        = bool
  default     = true # Prod için genellikle true
}

variable "volume_type" {
  description = "Root volume tipi"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "Root volume boyutu (GB)"
  type        = number
  default     = 30 # Prod için daha büyük volume
}

variable "ssh_allowed_cidrs" {
  description = "SSH erişimine izin verilen CIDR blokları (Production'da kısıtlayıcı olmalı!)"
  type        = list(string)
  # ÖRNEK: Sadece office IP'leri
  # default     = ["203.0.113.0/24", "198.51.100.0/24"]
  default = ["0.0.0.0/0"] # ⚠️ Production'da değiştirilmeli!
}

