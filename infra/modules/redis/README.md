# Redis Modülü - Kullanım Kılavuzu

Bu modül AWS ElastiCache Redis cluster'ı oluşturur.

## Özellikler

- ✅ ElastiCache Redis Replication Group
- ✅ Subnet Group (private subnet'lerde)
- ✅ Security Group (opsiyonel)
- ✅ Encryption (at-rest ve transit)
- ✅ Snapshot yönetimi
- ✅ Multi-AZ desteği
- ✅ Automatic failover

## Temel Kullanım

### Örnek 1: Dev Ortamı (Minimal Yapılandırma)

```hcl
module "redis" {
  source = "../../modules/redis"

  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.vpc.redis_security_group_id]
  create_security_group = false  # VPC modülünden security group kullan
  
  # Redis ayarları
  node_type           = "cache.t3.micro"
  num_cache_clusters = 1
  
  tags = {
    Environment = "dev"
    Project     = "actions-deneme"
  }
}
```

### Örnek 2: Production Ortamı (Yüksek Kullanılabilirlik)

```hcl
module "redis" {
  source = "../../modules/redis"

  environment         = "prod"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.vpc.redis_security_group_id]
  create_security_group = false
  
  # Redis ayarları - Production
  node_type                  = "cache.t3.medium"
  num_cache_clusters         = 2  # Multi-AZ için en az 2
  automatic_failover_enabled = true
  multi_az_enabled          = true
  
  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true  # Production'da etkin
  
  # Snapshot
  snapshot_retention_limit = 7  # 7 gün sakla
  
  tags = {
    Environment = "prod"
    Project     = "actions-deneme"
  }
}
```

### Örnek 3: Yeni Security Group ile

```hcl
module "redis" {
  source = "../../modules/redis"

  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  create_security_group = true  # Yeni security group oluştur
  allowed_security_group_ids = [
    module.vpc.web_security_group_id,
    module.vpc.app_security_group_id
  ]
  
  node_type           = "cache.t3.micro"
  num_cache_clusters = 1
  
  tags = {
    Environment = "dev"
  }
}
```

## Output'ları Kullanma

```hcl
# Redis endpoint'ini al
output "redis_endpoint" {
  value = module.redis.primary_endpoint_address
}

# Connection string
output "redis_connection" {
  value = "${module.redis.primary_endpoint_address}:${module.redis.primary_endpoint_port}"
}

# Application'da kullanım
# REDIS_HOST = module.redis.primary_endpoint_address
# REDIS_PORT = module.redis.primary_endpoint_port
```

## Uygulama Entegrasyonu

### Flask Uygulamasında Kullanım

```python
import redis
import os

# Terraform output'larından alınan değerler
REDIS_HOST = os.getenv('REDIS_HOST', 'dev-redis.xxxxx.cache.amazonaws.com')
REDIS_PORT = int(os.getenv('REDIS_PORT', 6379))

redis_client = redis.Redis(
    host=REDIS_HOST,
    port=REDIS_PORT,
    decode_responses=True
)
```

### Environment Variable Olarak

```bash
# Terraform output'tan al
export REDIS_HOST=$(terraform output -raw redis_primary_endpoint)
export REDIS_PORT=$(terraform output -raw redis_primary_port)

# Uygulamada kullan
python app.py
```

## Değişken Referansı

### Zorunlu Değişkenler

- `environment`: Ortam adı (dev, prod)
- `vpc_id`: VPC ID
- `subnet_ids`: Private subnet ID'leri listesi
- `security_group_ids`: Security group ID'leri (create_security_group=false ise)

### Önemli Opsiyonel Değişkenler

- `node_type`: Instance tipi (default: `cache.t3.micro`)
- `num_cache_clusters`: Cluster sayısı (default: `1`)
- `automatic_failover_enabled`: Otomatik failover (default: `false`)
- `multi_az_enabled`: Multi-AZ (default: `false`)
- `at_rest_encryption_enabled`: At-rest encryption (default: `true`)
- `transit_encryption_enabled`: Transit encryption (default: `false`)
- `snapshot_retention_limit`: Snapshot saklama (gün, default: `0`)

## Maliyet Notları

- **cache.t3.micro**: ~$15-20/ay
- **cache.t3.small**: ~$30-40/ay
- **cache.t3.medium**: ~$60-80/ay

**Öneri**: Dev ortamında `cache.t3.micro` kullanın.

## Güvenlik

1. **Private Subnet**: Redis her zaman private subnet'lerde çalışmalı
2. **Security Group**: Sadece gerekli security group'lardan erişim
3. **Encryption**: Production'da transit encryption etkin olmalı
4. **VPC Only**: Internet'ten erişilemez (sadece VPC içinden)

## Troubleshooting

### Connection Timeout

```bash
# Security group'u kontrol et
aws ec2 describe-security-groups --group-ids sg-xxxxx

# Subnet group'u kontrol et
aws elasticache describe-cache-subnet-groups --cache-subnet-group-name dev-redis-subnet-group
```

### Endpoint Bulunamıyor

```bash
# Replication group durumunu kontrol et
aws elasticache describe-replication-groups --replication-group-id dev-redis
```

## Örnek: Dev Ortamında Kullanım

`infra/environments/dev/main.tf` dosyasında:

```hcl
module "redis" {
  source = "../../modules/redis"

  environment         = "dev"
  vpc_id              = module.vpc.vpc_id
  subnet_ids          = module.vpc.private_subnet_ids
  security_group_ids  = [module.vpc.redis_security_group_id]
  create_security_group = false
  
  node_type           = "cache.t3.micro"
  num_cache_clusters = 1
  
  tags = {
    Environment = "dev"
    Project     = "actions-deneme"
  }
}
```

Output'ları görmek için:

```bash
terraform output redis_primary_endpoint
terraform output redis_connection_string
```

