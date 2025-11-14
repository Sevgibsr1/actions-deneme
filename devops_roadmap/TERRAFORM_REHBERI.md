# Terraform Öğrenim Rehberi ve Ödevler

## 📚 İçindekiler
1. [Terraform Nedir?](#terraform-nedir)
2. [Temel Kavramlar](#temel-kavramlar)
3. [Proje Yapısı](#proje-yapısı)
4. [Modüler Mimari](#modüler-mimari)
5. [Environment Ayrımı](#environment-ayrımı)
6. [CI/CD Entegrasyonu](#cicd-entegrasyonu)
7. [Ödevler](#ödevler)

---

## Terraform Nedir?

**Terraform**, HashiCorp tarafından geliştirilen bir **Infrastructure as Code (IaC)** aracıdır. Altyapıyı kod olarak tanımlamanıza ve yönetmenize olanak sağlar.

### Temel Avantajları:
- ✅ **Versiyon Kontrolü**: Altyapı değişikliklerini Git ile takip edebilirsiniz
- ✅ **Tekrarlanabilirlik**: Aynı altyapıyı farklı ortamlarda oluşturabilirsiniz
- ✅ **Otomasyon**: CI/CD pipeline'ları ile otomatik deploy edebilirsiniz
- ✅ **Modülerlik**: Kod tekrarını önler, bakımı kolaylaştırır
- ✅ **Multi-Cloud**: AWS, Azure, GCP gibi farklı bulut sağlayıcıları destekler

---

## Temel Kavramlar

### 1. **Provider**
Bulut sağlayıcısını tanımlar (AWS, Azure, GCP vb.)

```hcl
provider "aws" {
  region = "eu-central-1"
}
```

### 2. **Resource**
Oluşturulacak altyapı bileşenini tanımlar

```hcl
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
}
```

### 3. **Variable**
Değerleri parametreleştirmek için kullanılır

```hcl
variable "instance_type" {
  description = "EC2 instance tipi"
  type        = string
  default     = "t2.micro"
}
```

### 4. **Output**
Oluşturulan kaynaklardan bilgi çıkarmak için kullanılır

```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

### 5. **Module**
Tekrar kullanılabilir kod blokları

```hcl
module "vpc" {
  source = "./modules/vpc"
  cidr   = "10.0.0.0/16"
}
```

### 6. **State**
Terraform'un oluşturduğu kaynakların durumunu tutar. Genellikle S3'te saklanır.

---

## Proje Yapısı

Bu projede şu dizin yapısı kullanılmaktadır:

```
.
├── .github/
│   └── workflows/
│       └── terraform.yml        ← Terraform CI/CD workflow'u
├── infra/
│   ├── modules/
│   │   ├── vpc/                 ← VPC modülü
│   │   │   ├── main.tf
│   │   │   ├── variables.tf
│   │   │   └── outputs.tf
│   │   └── compute/             ← Compute modülü (EC2/Docker)
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── environments/
│       ├── dev/                  ← Development ortamı
│       │   ├── main.tf
│       │   ├── variables.tf
│       │   ├── outputs.tf
│       │   ├── backend.tf        ← backend "s3" {} (boş blok)
│       │   ├── backend.hcl.example
│       │   └── terraform.tfvars.example
│       └── prod/                 ← Production ortamı
│           ├── main.tf
│           ├── variables.tf
│           ├── outputs.tf
│           ├── backend.tf        ← backend "s3" {} (boş blok)
│           ├── backend.hcl.example
│           └── terraform.tfvars.example
└── web/                          ← Mevcut Flask uygulaması
    ├── app.py
    ├── Dockerfile
    └── requirements.txt
```

---

## Modüler Mimari

### Neden Modüler Yapı?

1. **Kod Tekrarını Önler**: VPC'yi her ortamda yeniden yazmak yerine modül kullanırız
2. **Bakımı Kolaylaştırır**: Değişiklik tek yerden yapılır
3. **Test Edilebilirlik**: Modüller bağımsız test edilebilir
4. **Paylaşılabilirlik**: Modüller farklı projelerde kullanılabilir

### Modül Yapısı

Her modül şu dosyaları içerir:

- **main.tf**: Ana kaynak tanımları
- **variables.tf**: Modülün kabul ettiği parametreler
- **outputs.tf**: Modülün dışa verdiği bilgiler

### Örnek Modül Kullanımı

```hcl
# environments/dev/main.tf
module "vpc" {
  source = "../../modules/vpc"
  
  vpc_cidr        = "10.0.0.0/16"
  environment     = "dev"
  availability_zones = ["eu-central-1a", "eu-central-1b"]
}

module "compute" {
  source = "../../modules/compute"
  
  vpc_id          = module.vpc.vpc_id
  subnet_ids      = module.vpc.public_subnet_ids
  instance_type   = "t2.micro"
  environment     = "dev"
}
```

---

## Environment Ayrımı

### Neden Ayrı Ortamlar?

- **Güvenlik**: Prod ve dev ortamları birbirinden izole olmalı
- **Maliyet**: Dev ortamında daha küçük kaynaklar kullanılabilir
- **Test**: Değişiklikler önce dev'de test edilir
- **State Yönetimi**: Her ortamın kendi state dosyası olmalı

### Backend Yapılandırması

Her ortamın `backend.tf` dosyasında yalnızca aşağıdaki gibi boş bir backend bloğu bulunur; gerçek değerler kendi makinenizde oluşturacağınız `backend.hcl` dosyasından okunur.

```hcl
terraform {
  backend "s3" {}
}
```

İlk kullanımda şu adımları izleyin:

```bash
cd infra/environments/dev
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars

# backend.hcl dosyasını düzenleyin ve S3 + DynamoDB bilgilerinizi girin
# terraform.tfvars içine ortam değişkenlerini özelleştirin

terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
```

Aynı yaklaşımı `prod` klasörü için de uygulayabilirsiniz. Böylece state dosyaları (S3 bucket/key) ve ortam değişkenleri (tfvars) repoya eklenmeden kişisel kopyalarınızla yönetilmiş olur.

### State Locking

DynamoDB tablosu ile aynı anda iki kişinin aynı state'i değiştirmesini önleriz.

---

## CI/CD Entegrasyonu

### GitHub Actions Workflow

Terraform CI/CD workflow'u şu adımları içerir:

1. **terraform fmt**: Kod formatını kontrol eder
2. **terraform validate**: Syntax kontrolü yapar
3. **terraform plan**: Değişiklikleri gösterir (artefact olarak saklanır)
4. **terraform apply**: Değişiklikleri uygular (prod için manuel onay gerekir)

### Workflow Tetikleyicileri

- **Pull Request**: `terraform plan` çalışır
- **Push to main (dev)**: Otomatik `terraform apply`
- **Push to main (prod)**: Manuel onay sonrası `terraform apply`

---

## Hızlı Başlangıç Akışı

Terraform'a yeni başlıyorsanız aşağıdaki beş adım sizi hızlıca çalışır hâle getirir:

1. **Kurulum**
   ```bash
   terraform -version   # kurulu değilse HashiCorp sitesinden indir
   aws configure        # AWS erişim anahtarlarını gir
   ```
2. **Ortam Dosyalarını Hazırla**
   ```bash
   cd infra/environments/dev
   cp backend.hcl.example backend.hcl
   cp terraform.tfvars.example terraform.tfvars
   ```
   Bu dosyalardaki placeholder değerleri kendi S3 bucket, DynamoDB tablosu ve ağ ayarlarınla değiştir.
3. **Terraform'u Başlat**
   ```bash
   terraform init -backend-config=backend.hcl
   ```
4. **Planı Gör**
   ```bash
   terraform plan -var-file=terraform.tfvars
   ```
   Çıktıyı inceleyerek hangi AWS kaynaklarının oluşturulacağını ve maliyet etkisini not al.
5. **(Opsiyonel) Uygula**
   ```bash
   terraform apply -var-file=terraform.tfvars
   ```
   Sadece dev ortamında doğrulama yaptıktan sonra çalıştır. Prod için PR + onay sürecini kullan.

Bu akış, aynı adımları `prod` klasöründe tekrar ederek production ortamına da uygulanabilir (daha yüksek kaynak değerleriyle).

---

## Terraform Komutları

### Temel Komutlar

```bash
# Terraform'u başlat (ilk kez çalıştırırken)
terraform init

# Değişiklikleri planla
terraform plan

# Değişiklikleri uygula
terraform apply

# Kaynakları sil
terraform destroy

# Kodu formatla
terraform fmt

# Syntax kontrolü
terraform validate

# State'i göster
terraform show

# Output'ları göster
terraform output
```

### Ortam Bazlı Çalıştırma

**Dev Ortamında Çalışma:**
```bash
cd infra/environments/dev
terraform init -backend-config=backend.hcl
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

**Prod Ortamına Geçiş:**

Prod ortamına geçmek için sadece klasör değiştirmen yeterli! Her ortam kendi klasöründe ve kendi state dosyasını kullanır.

```bash
# 1. Prod klasörüne geç
cd infra/environments/prod

# 2. Prod için backend ve tfvars dosyalarını hazırla (ilk kez)
cp backend.hcl.example backend.hcl
cp terraform.tfvars.example terraform.tfvars

# 3. backend.hcl dosyasını düzenle (prod için farklı S3 bucket/key kullan)
# Örnek: bucket = "terraform-state-prod" (dev'de "terraform-state-dev" idi)

# 4. terraform.tfvars dosyasını düzenle (prod için daha yüksek kaynaklar)
# Örnek: instance_type = "t3.medium" (dev'de "t2.micro" idi)

# 5. Terraform'u başlat
terraform init -backend-config=backend.hcl

# 6. Plan yap (mutlaka kontrol et!)
terraform plan -var-file=terraform.tfvars

# 7. Apply yap (dikkatli! Prod'da değişiklikler gerçek kullanıcıları etkiler)
terraform apply -var-file=terraform.tfvars
```

**Önemli Notlar:**
- Dev ve prod ortamları **tamamen ayrı** AWS kaynakları oluşturur
- Her ortamın kendi S3 state dosyası vardır (karışmaz)
- Dev'de yaptığın değişiklikler prod'u etkilemez
- Prod'da değişiklik yapmadan önce mutlaka dev'de test et

---

## Best Practices

### 1. **State Dosyasını Asla Commit Etmeyin**
`.gitignore` dosyasına ekleyin:
```
*.tfstate
*.tfstate.*
.terraform/
```

### 2. **Sensitive Bilgileri Variable Olarak Kullanın**
```hcl
variable "db_password" {
  type        = string
  sensitive   = true
  description = "Database password"
}
```

### 3. **Tag'leri Kullanın**
Tüm kaynaklara environment, project, managed-by gibi tag'ler ekleyin.

### 4. **Modülleri Versiyonlayın**
Git tag'leri ile modül versiyonlarını yönetin:
```hcl
module "vpc" {
  source = "git::https://github.com/org/repo.git//modules/vpc?ref=v1.0.0"
}
```

### 5. **Plan Çıktısını Review Edin**
Her zaman `terraform plan` çıktısını kontrol edin.

---

## Ödevler

### Ödev 1: Terraform Kurulumu ve İlk Adımlar

**Hedef**: Terraform'u kurun ve temel komutları öğrenin.

**Adımlar**:
1. Terraform'u sisteminize kurun
   
   **Ubuntu/WSL için (Önerilen - Resmi Repo):**
   ```bash
   # HashiCorp GPG anahtarını ekle
   wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
   
   # Repo'yu ekle
   echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
   
   # Paket listesini güncelle ve kur
   sudo apt update
   sudo apt install terraform
   ```
   
   **Alternatif: Manuel Kurulum (Linux/Mac):**
   ```bash
   wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
   unzip terraform_1.6.0_linux_amd64.zip
   sudo mv terraform /usr/local/bin/
   rm terraform_1.6.0_linux_amd64.zip
   ```
   
   **Windows için:**
   - Chocolatey ile: `choco install terraform`
   - veya manuel indirin ve PATH'e ekleyin

2. Terraform versiyonunu kontrol edin
   ```bash
   terraform version
   ```

3. AWS CLI'yi yapılandırın (AWS credentials)
   ```bash
   aws configure
   ```

4. `infra/environments/dev` klasörüne gidin ve şu adımları izleyin:
    ```bash
    cd infra/environments/dev
    cp backend.hcl.example backend.hcl
    cp terraform.tfvars.example terraform.tfvars
    terraform init -backend-config=backend.hcl
    terraform validate
    terraform plan -var-file=terraform.tfvars
    ```

**Beklenen Çıktı**: 
- Terraform başarıyla initialize olmalı
- Validate hatasız geçmeli
- Plan çıktısı gösterilmeli (henüz apply etmeyin)

**Teslim**: Terminal çıktısını ekran görüntüsü olarak kaydedin.

---

### Ödev 2: VPC Modülünü İnceleme ve Anlama

**Hedef**: VPC modülünün nasıl çalıştığını anlayın.

**Adımlar**:
1. `infra/modules/vpc/main.tf` dosyasını açın ve okuyun
2. `infra/modules/vpc/variables.tf` dosyasındaki tüm değişkenleri listeleyin
3. `infra/modules/vpc/outputs.tf` dosyasındaki çıktıları listeleyin
4. Aşağıdaki soruları cevaplayın:
   - VPC modülü hangi AWS kaynaklarını oluşturuyor?
   - Public subnet ve private subnet arasındaki fark nedir?
   - Internet Gateway neden gereklidir?
   - Route table ne işe yarar?

**Teslim**: Soruların cevaplarını bir markdown dosyasına yazın (`ODEV2_VPC_ANALIZ.md`).

---

### Ödev 3: Dev Ortamında Değişiklik Yapma

**Hedef**: Dev ortamında bir değişiklik yapın ve Terraform plan çıktısını inceleyin.

**Adımlar**:
1. `infra/environments/dev/variables.tf` dosyasını açın
2. `instance_type` değişkenini `t2.micro`'dan `t2.small`'a değiştirin
3. `terraform plan` komutunu çalıştırın
4. Plan çıktısını inceleyin:
   - Hangi kaynaklar değişecek?
   - Hangi kaynaklar yeniden oluşturulacak?
   - Maliyet etkisi nedir?

**Önemli**: `terraform apply` yapmayın, sadece plan çıktısını inceleyin.

**Teslim**: Plan çıktısının ekran görüntüsünü ve analiz sonuçlarınızı kaydedin.

---

### Ödev 4: Yeni Bir Modül Oluşturma

**Hedef**: Redis için bir modül oluşturun.

**Gereksinimler**:
1. `infra/modules/redis` klasörünü oluşturun
2. ElastiCache Redis için Terraform konfigürasyonu yazın:
   - Redis cluster oluşturun
   - Security group ekleyin
   - Subnet group oluşturun
   - Output'ları tanımlayın

3. Modülü `infra/environments/dev/main.tf` dosyasına ekleyin

**İpucu**: AWS ElastiCache Redis için `aws_elasticache_replication_group` resource'unu kullanın.

**Teslim**: 
- Modül dosyalarını commit edin
- Modülün nasıl kullanıldığını gösteren bir örnek ekleyin

---

### Ödev 5: CI/CD Pipeline'ını Test Etme

**Hedef**: GitHub Actions workflow'unu test edin.

**Adımlar**:
1. `infra/environments/dev` klasöründe küçük bir değişiklik yapın (örneğin bir tag ekleyin)
2. Değişikliği commit edin ve push edin
3. GitHub Actions'da workflow'un çalıştığını kontrol edin
4. Workflow adımlarını inceleyin:
   - `terraform fmt` başarılı mı?
   - `terraform validate` başarılı mı?
   - `terraform plan` çıktısı oluşturuldu mu?
   - Plan artefact'ı indirilebilir mi?

**Önemli**: Prod ortamı için workflow manuel onay gerektirmelidir.

**Teslim**: 
- Workflow çalıştırma ekran görüntüsü
- Plan artefact'ının indirilebildiğini gösteren ekran görüntüsü

---

### Ödev 6: Production Ortamını Yapılandırma

**Hedef**: Production ortamını dev ortamından farklı şekilde yapılandırın.

**Gereksinimler**:
1. `infra/environments/prod` klasöründeki `variables.tf` dosyasını düzenleyin:
   - `instance_type` = `t3.medium` (dev'de t2.micro)
   - `instance_count` = 2 (dev'de 1)
   - `enable_backup` = true (dev'de false)

2. Prod için backend yapılandırmasını kontrol edin
3. Prod ortamında `terraform plan` çalıştırın (apply etmeyin)

**Teslim**: 
- Prod ve dev ortamları arasındaki farkları gösteren bir karşılaştırma tablosu
- Prod plan çıktısının ekran görüntüsü

---

### Ödev 7: Terraform State Yönetimi

**Hedef**: State dosyasını S3'te saklamayı ve state lock'u anlayın.

**Adımlar**:
1. S3 bucket oluşturun (terraform state için)
   ```bash
   aws s3 mb s3://terraform-state-dev --region eu-central-1
   ```

2. DynamoDB tablosu oluşturun (state locking için)
   ```bash
   aws dynamodb create-table \
     --table-name terraform-locks-dev \
     --attribute-definitions AttributeName=LockID,AttributeType=S \
     --key-schema AttributeName=LockID,KeyType=HASH \
     --billing-mode PAY_PER_REQUEST \
     --region eu-central-1
   ```

3. `infra/environments/dev/backend.tf` dosyasını kontrol edin
4. `terraform init -migrate-state` komutunu çalıştırın (eğer local state varsa)

**Teslim**: 
- S3 bucket ve DynamoDB tablosunun oluşturulduğunu gösteren ekran görüntüleri
- State'in S3'te saklandığını gösteren ekran görüntüsü

---

### Ödev 8: Terraform Destroy ve Kaynak Temizleme

**Hedef**: Oluşturulan kaynakları güvenli şekilde silmeyi öğrenin.

**Adımlar**:
1. Dev ortamında `terraform plan -destroy` komutunu çalıştırın
2. Hangi kaynakların silineceğini kontrol edin
3. **DİKKAT**: Sadece dev ortamında destroy yapın, prod'da asla yapmayın!
4. `terraform destroy` komutunu çalıştırın (onay verin)
5. Kaynakların silindiğini AWS Console'dan kontrol edin

**Önemli**: 
- Destroy işlemi geri alınamaz!
- Sadece test/dev ortamlarında yapın
- Production'da destroy yapmadan önce mutlaka backup alın

**Teslim**: 
- Destroy plan çıktısının ekran görüntüsü
- Kaynakların silindiğini gösteren AWS Console ekran görüntüsü

---

## İleri Seviye Konular

### 1. **Workspaces**
Farklı ortamları aynı konfigürasyonla yönetmek için:
```bash
terraform workspace new dev
terraform workspace new prod
terraform workspace select dev
```

### 2. **Data Sources**
Mevcut kaynaklardan bilgi çekmek için:
```hcl
data "aws_ami" "latest" {
  most_recent = true
  owners      = ["amazon"]
}
```

### 3. **Local Values**
Hesaplanmış değerleri saklamak için:
```hcl
locals {
  common_tags = {
    Environment = var.environment
    Project     = "actions-deneme"
    ManagedBy   = "Terraform"
  }
}
```

### 4. **Conditional Resources**
Koşullu kaynak oluşturmak için:
```hcl
resource "aws_instance" "web" {
  count = var.enable_web ? 1 : 0
  # ...
}
```

### 5. **Terraform Cloud**
State yönetimi ve CI/CD için Terraform Cloud kullanımı.

---

## Yararlı Kaynaklar

- [Terraform Resmi Dokümantasyonu](https://www.terraform.io/docs)
- [AWS Provider Dokümantasyonu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Terraform Modules Registry](https://registry.terraform.io/)

---

## Sorular ve Destek

Ödevlerle ilgili sorularınız için:
1. GitHub Issues açabilirsiniz
2. Dokümantasyonu tekrar gözden geçirin
3. Terraform community forumlarını ziyaret edin

**Başarılar! 🚀**

