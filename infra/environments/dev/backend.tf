# Development Ortamı - Backend Yapılandırması
# State dosyası S3'te saklanır ve DynamoDB ile lock edilir

terraform {
  backend "s3" {}
}

# Kullanım:
# terraform init \
#   -backend-config=backend.hcl