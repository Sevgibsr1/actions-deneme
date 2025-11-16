# Development Ortamı - Değişkenler

variable "aws_region" {
  description = "AWS bölgesi"
  type        = string
  default     = "eu-north-1" # Mevcut EC2 instance ile aynı region
}

variable "vpc_cidr" {
  description = "VPC CIDR bloğu"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Kullanılacak availability zone'lar"
  type        = list(string)
  default     = ["eu-north-1a", "eu-north-1b"] # eu-north-1 için doğru AZ'ler
}

variable "instance_count" {
  description = "Oluşturulacak EC2 instance sayısı"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance tipi"
  type        = string
  default     = "t3.micro" # Free Tier için uygun
}

variable "key_name" {
  description = "EC2 instance'lar için SSH key pair adı (AWS Console'dan oluşturulmalı)"
  type        = string
  default     = ""
}

variable "docker_image" {
  description = "Docker image adı"
  type        = string
  default     = "nginx:latest" # Production'da ECR image kullanılmalı
}

variable "enable_elastic_ip" {
  description = "Elastic IP oluşturulsun mu?"
  type        = bool
  default     = false
}

variable "volume_type" {
  description = "Root volume tipi"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "Root volume boyutu (GB)"
  type        = number
  default     = 30 # Minimum 30GB (snapshot gereksinimi)
}

variable "ssh_allowed_cidrs" {
  description = "SSH erişimine izin verilen CIDR blokları"
  type        = list(string)
  default     = ["0.0.0.0/0"] # Production'da daha kısıtlayıcı olmalı!
}

