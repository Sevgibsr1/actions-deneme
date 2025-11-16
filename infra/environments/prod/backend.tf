# Production Ortamı - Backend Yapılandırması
# Local backend kullanılıyor (öğrenme için)
# State dosyası yerel olarak terraform.tfstate dosyasında saklanır

# Local backend için backend bloğu gerekmez
# Terraform varsayılan olarak local backend kullanır

# Not: Production'da S3 backend kullanılmalıdır
# S3 backend kullanmak için:
# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-prod"
#     key            = "prod/terraform.tfstate"
#     region         = "eu-north-1"
#     dynamodb_table = "terraform-locks-prod"
#     encrypt        = true
#   }
# }