# Terraform Infrastructure

Bu klasör, projenin AWS altyapısını Terraform ile yönetmek için kullanılır.

## 📁 Dizin Yapısı

```
infra/
├── modules/              # Yeniden kullanılabilir Terraform modülleri
│   ├── vpc/             # VPC, subnetler, security group'lar
│   └── compute/         # EC2 instance'lar ve Docker deployment
└── environments/        # Ortam bazlı konfigürasyonlar
    ├── dev/             # Development ortamı
    └── prod/            # Production ortamı
```

## 🚀 Hızlı Başlangıç

### Ön Gereksinimler

1. **Terraform Kurulumu**
   ```bash
   # Versiyon kontrolü
   terraform version
   ```

2. **AWS CLI Kurulumu ve Yapılandırma**
   ```bash
   aws configure
   ```

3. **S3 Bucket ve DynamoDB Tablosu Oluşturma**
   
   Dev ortamı için:
   ```bash
   # S3 bucket oluştur
   aws s3 mb s3://terraform-state-dev --region eu-central-1
   
   # DynamoDB tablosu oluştur (state locking için)
   aws dynamodb create-table \
     --table-name terraform-locks-dev \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region eu-central-1
   ```

   Prod ortamı için:
   ```bash
   aws s3 mb s3://terraform-state-prod --region eu-central-1
   
   aws dynamodb create-table \
     --table-name terraform-locks-prod \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region eu-central-1
   ```

### Development Ortamında Çalıştırma

```bash
cd infra/environments/dev

# Backend ayarlarını doldur (ilk seferde)
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars

# Terraform'u backend ayarları ile başlat
terraform init -backend-config=backend.hcl

# Değişiklikleri planla
terraform plan -var-file=terraform.tfvars

# Değişiklikleri uygula
terraform apply -var-file=terraform.tfvars
```

### Production Ortamında Çalıştırma

```bash
cd infra/environments/prod

# Backend ayarlarını doldur (ilk seferde)
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars

# Terraform'u backend ayarları ile başlat
terraform init -backend-config=backend.hcl

# Değişiklikleri planla (mutlaka kontrol edin!)
terraform plan -var-file=terraform.tfvars

# Değişiklikleri uygula (dikkatli!)
terraform apply -var-file=terraform.tfvars
```

## 🔧 Modüller

### VPC Modülü (`modules/vpc`)

VPC, subnetler, internet gateway, route table'lar ve security group'ları oluşturur.

**Kullanım:**
```hcl
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr          = "10.0.0.0/16"
  availability_zones = ["eu-central-1a", "eu-central-1b"]
  environment       = "dev"
}
```

### Compute Modülü (`modules/compute`)

EC2 instance'ları ve Docker deployment'ı yönetir.

**Kullanım:**
```hcl
module "compute" {
  source = "../../modules/compute"
  
  instance_count    = 1
  instance_type     = "t2.micro"
  subnet_ids        = module.vpc.public_subnet_ids
  security_group_id = module.vpc.web_security_group_id
  environment       = "dev"
}
```

## 🔐 Secrets Yönetimi

GitHub Actions için gerekli secrets:

- `AWS_ACCESS_KEY_ID`: AWS access key
- `AWS_SECRET_ACCESS_KEY`: AWS secret key
- `TERRAFORM_STATE_BUCKET_DEV`: Dev ortamı için S3 bucket adı
- `TERRAFORM_STATE_BUCKET_PROD`: Prod ortamı için S3 bucket adı
- `TERRAFORM_LOCK_TABLE_DEV`: Dev ortamı için DynamoDB tablo adı
- `TERRAFORM_LOCK_TABLE_PROD`: Prod ortamı için DynamoDB tablo adı

## 📝 Best Practices

1. **State Dosyasını Asla Commit Etmeyin**
   - `.gitignore` dosyasına `*.tfstate` ve `.terraform/` ekleyin
   - `backend.hcl` ve `terraform.tfvars` dosyalarını kişisel kopyalarınızla yönetin

2. **Plan Çıktısını Her Zaman Review Edin**
   - `terraform apply` yapmadan önce mutlaka `terraform plan` çıktısını kontrol edin

3. **Production'da Dikkatli Olun**
   - Production ortamında değişiklik yapmadan önce mutlaka test edin
   - Destroy işlemlerini çok dikkatli yapın

4. **Modülleri Versiyonlayın**
   - Modül değişikliklerini Git tag'leri ile versiyonlayın

5. **Tag'leri Kullanın**
   - Tüm kaynaklara environment, project, managed-by gibi tag'ler ekleyin

## 🐛 Troubleshooting

### Backend Hatası
Eğer backend yapılandırması ile ilgili hata alırsanız:
```bash
terraform init -reconfigure
```

### State Lock Hatası
Eğer state lock hatası alırsanız:
```bash
# DynamoDB tablosundan lock'u manuel olarak kaldırın (dikkatli!)
# veya lock'u bekleyin (başka bir terraform çalışması bitene kadar)
```

### Module Bulunamadı Hatası
```bash
terraform init -upgrade
```

## 📚 Daha Fazla Bilgi

- [Terraform Rehberi](../TERRAFORM_REHBERI.md)
- [Terraform Dokümantasyonu](https://www.terraform.io/docs)
- [AWS Provider Dokümantasyonu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)

