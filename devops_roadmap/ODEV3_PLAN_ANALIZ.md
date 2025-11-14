# Ödev 3: Terraform Plan Analizi - Instance Type Değişikliği

## Yapılan Değişiklik

**Değiştirilen Dosya**: `infra/environments/dev/terraform.tfvars`
- **Önceki Değer**: `instance_type = "t3.micro"`
- **Yeni Değer**: `instance_type = "t2.small"`

---

## Plan Çıktısı Analizi

### 1. Hangi Kaynaklar Değişecek?

**Değişen Kaynak**: `module.compute.aws_instance.web[0]`

**Değişiklik Tipi**: `~ update in-place` (Yerinde güncelleme)

**Değişen Özellikler**:
- `instance_type`: `"t3.micro"` → `"t2.small"`
- `public_dns`: Değişecek (apply sonrası belli olacak)
- `public_ip`: Değişecek (apply sonrası belli olacak)

### 2. Plan Özeti

```
Plan: 0 to add, 1 to change, 0 to destroy.
```

**Açıklama**:
- **0 to add**: Yeni kaynak oluşturulmayacak
- **1 to change**: 1 kaynak değişecek (EC2 instance)
- **0 to destroy**: Hiçbir kaynak silinmeyecek

### 3. Terraform İşaret Sistemi

| İşaret | Anlam | Açıklama |
|--------|-------|----------|
| `+` | create | Yeni kaynak oluşturulacak |
| `-` | destroy | Kaynak silinecek |
| `~` | update in-place | Kaynak yerinde güncellenecek |
| `-/+` | replace | Kaynak silinip yeniden oluşturulacak |

**Bizim Durumumuz**: `~` (update in-place)
- Instance yeniden oluşturulmayacak
- Sadece instance_type değişecek
- Ancak AWS'de instance_type değişikliği instance'ı durdurmayı gerektirebilir

---

## Değişen Kaynak Detayları

### EC2 Instance (`module.compute.aws_instance.web[0]`)

**Instance ID**: `i-0e6e35bb9a8ebdde8`

**Değişen Özellikler**:

1. **instance_type**
   - **Önceki**: `t3.micro`
   - **Yeni**: `t2.small`
   - **Etki**: Daha fazla CPU ve RAM

2. **public_dns**
   - **Önceki**: `ec2-51-20-68-76.eu-north-1.compute.amazonaws.com`
   - **Yeni**: `(known after apply)` - Apply sonrası belli olacak
   - **Not**: Instance durdurulup başlatılırsa DNS değişebilir

3. **public_ip**
   - **Önceki**: `51.20.68.76`
   - **Yeni**: `(known after apply)` - Apply sonrası belli olacak
   - **Not**: Instance durdurulup başlatılırsa IP değişebilir

**Değişmeyen Özellikler** (37 unchanged attributes):
- AMI (Amazon Machine Image)
- Subnet
- Security Groups
- Key Name
- User Data
- Tags
- Volume ayarları
- vb.

---

## Hangi Kaynaklar Yeniden Oluşturulacak?

**Cevap**: Hiçbir kaynak yeniden oluşturulmayacak.

**Neden?**
- Plan çıktısında `~` (update in-place) işareti var
- `-/+` (replace) işareti yok
- Terraform, instance_type değişikliğini yerinde güncelleme olarak planlıyor

**Ancak Dikkat:**
- AWS'de instance_type değişikliği genellikle instance'ı durdurmayı gerektirir
- Instance durdurulduğunda public IP değişebilir (Elastic IP kullanılmıyorsa)
- Uygulama kısa bir süre erişilemez olabilir

---

## Maliyet Etkisi

### t3.micro vs t2.small Karşılaştırması

| Özellik | t3.micro | t2.small | Fark |
|---------|----------|----------|------|
| **vCPU** | 2 | 1 | -1 vCPU |
| **RAM** | 1 GB | 2 GB | +1 GB |
| **Network Performance** | Up to 5 Gbps | Low to Moderate | - |
| **EBS Bandwidth** | Up to 2,085 Mbps | Moderate | - |
| **Fiyat (eu-north-1)** | ~$0.0104/saat | ~$0.023/saat | **+%121** |

### Maliyet Hesaplama

**Aylık Maliyet (730 saat)**:
- **t3.micro**: ~$7.59/ay
- **t2.small**: ~$16.79/ay
- **Fark**: **+$9.20/ay** (~%121 artış)

**Yıllık Maliyet**:
- **t3.micro**: ~$91.08/yıl
- **t2.small**: ~$201.48/yıl
- **Fark**: **+$110.40/yıl**

### Önemli Notlar

1. **t2.small daha pahalı**: t3.micro'dan yaklaşık 2 kat daha pahalı
2. **RAM artışı**: 1 GB → 2 GB (daha fazla bellek)
3. **vCPU azalması**: 2 vCPU → 1 vCPU (daha az CPU)
4. **Burst Performance**: t2.small burst performans kullanır (CPU kredisi)

---

## Output Değişiklikleri

### Değişen Output'lar:

1. **instance_public_ips**
   - **Önceki**: `["51.20.68.76"]`
   - **Yeni**: `(known after apply)`
   - **Not**: Instance durdurulup başlatılırsa IP değişebilir

2. **web_url**
   - **Önceki**: `"http://51.20.68.76:5000"`
   - **Yeni**: `(known after apply)`
   - **Not**: Yeni IP ile güncellenecek

### Değişmeyen Output'lar:
- `instance_ids` - Aynı instance ID
- `instance_private_ips` - Private IP değişmez
- `vpc_id` - VPC değişmez
- `public_subnet_ids` - Subnet'ler değişmez

---

## Özet ve Sonuçlar

### Değişen Kaynaklar:
1. ✅ **EC2 Instance** (`module.compute.aws_instance.web[0]`)
   - Instance type: `t3.micro` → `t2.small`
   - Update in-place (yeniden oluşturulmayacak)

### Yeniden Oluşturulacak Kaynaklar:
- ❌ **Yok** - Hiçbir kaynak yeniden oluşturulmayacak

### Maliyet Etkisi:
- **Aylık Artış**: +$9.20/ay (~%121)
- **Yıllık Artış**: +$110.40/yıl
- **Sebep**: t2.small, t3.micro'dan daha pahalı

### Dikkat Edilmesi Gerekenler:

1. **Public IP Değişebilir**
   - Instance durdurulup başlatılırsa public IP değişir
   - Elastic IP kullanılmıyorsa (`enable_elastic_ip = false`)
   - Web URL güncellenmeli

2. **Downtime Olabilir**
   - Instance type değişikliği instance'ı durdurmayı gerektirebilir
   - Kısa bir süre uygulama erişilemez olabilir

3. **Maliyet Artışı**
   - t2.small, t3.micro'dan yaklaşık 2 kat daha pahalı
   - Production'da dikkatli kullanılmalı

---

## Öneriler

### 1. Elastic IP Kullanımı
```hcl
enable_elastic_ip = true  # terraform.tfvars'da
```
- Public IP sabit kalır
- Instance durdurulup başlatılsa bile IP değişmez

### 2. Maliyet Optimizasyonu
- **t3.micro**: Daha ucuz, 2 vCPU, 1 GB RAM
- **t2.small**: Daha pahalı, 1 vCPU, 2 GB RAM
- **Öneri**: RAM gereksinimi yoksa t3.micro daha uygun

### 3. Production'da Dikkat
- Instance type değişikliği downtime'a neden olabilir
- Maintenance window'da yapılmalı
- Blue-green deployment düşünülebilir

---

**Tarih**: 2025-11-13
**Ödev**: Ödev 3 - Dev Ortamında Değişiklik Yapma
**Durum**: ✅ Tamamlandı

