# Compute Modülü - Değişkenler

variable "instance_count" {
  description = "Oluşturulacak EC2 instance sayısı"
  type        = number
  default     = 1
}

variable "instance_type" {
  description = "EC2 instance tipi"
  type        = string
  default     = "t2.micro"
}

variable "subnet_ids" {
  description = "EC2 instance'ların oluşturulacağı subnet ID'leri"
  type        = list(string)
}

variable "security_group_id" {
  description = "EC2 instance'lar için security group ID"
  type        = string
}

variable "key_name" {
  description = "EC2 instance'lar için SSH key pair adı"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Ortam adı (dev, prod, staging vb.)"
  type        = string
}

variable "docker_image" {
  description = "Docker image adı (örneğin: your-account.dkr.ecr.eu-central-1.amazonaws.com/web-app:latest)"
  type        = string
  default     = "nginx:latest" # Varsayılan olarak nginx, production'da değiştirilmeli
}

variable "volume_type" {
  description = "Root volume tipi"
  type        = string
  default     = "gp3"
}

variable "volume_size" {
  description = "Root volume boyutu (GB)"
  type        = number
  default     = 20
}

variable "enable_elastic_ip" {
  description = "Elastic IP oluşturulsun mu? (sadece ilk instance için)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tüm kaynaklara eklenecek tag'ler"
  type        = map(string)
  default = {
    ManagedBy = "Terraform"
    Project   = "actions-deneme"
  }
}

