# Ödev 2: VPC Modülü Analizi

## 1. VPC Modülü Değişkenleri (variables.tf)

### Değişken Listesi:

1. **`vpc_cidr`**
   - **Tip**: `string`
   - **Varsayılan**: `"10.0.0.0/16"`
   - **Açıklama**: VPC CIDR bloğu
   - **Kullanım**: VPC'nin IP adres aralığını belirler

2. **`availability_zones`**
   - **Tip**: `list(string)`
   - **Varsayılan**: `["eu-central-1a", "eu-central-1b"]`
   - **Açıklama**: Kullanılacak availability zone'lar
   - **Kullanım**: Subnet'lerin hangi availability zone'larda oluşturulacağını belirler

3. **`environment`**
   - **Tip**: `string`
   - **Varsayılan**: Yok (zorunlu)
   - **Açıklama**: Ortam adı (dev, prod, staging vb.)
   - **Kullanım**: Kaynak isimlendirmesinde kullanılır

4. **`ssh_allowed_cidrs`**
   - **Tip**: `list(string)`
   - **Varsayılan**: `["0.0.0.0/0"]`
   - **Açıklama**: SSH erişimine izin verilen CIDR blokları
   - **Kullanım**: Security group'ta SSH portuna erişim kontrolü için

5. **`tags`**
   - **Tip**: `map(string)`
   - **Varsayılan**: 
     ```hcl
     {
       ManagedBy = "Terraform"
       Project   = "actions-deneme"
     }
     ```
   - **Açıklama**: Tüm kaynaklara eklenecek tag'ler
   - **Kullanım**: AWS kaynaklarını organize etmek için

---

## 2. VPC Modülü Çıktıları (outputs.tf)

### Çıktı Listesi:

1. **`vpc_id`**
   - **Açıklama**: VPC ID
   - **Değer**: `aws_vpc.main.id`
   - **Kullanım**: Diğer modüllerde VPC'ye referans vermek için

2. **`vpc_cidr`**
   - **Açıklama**: VPC CIDR bloğu
   - **Değer**: `aws_vpc.main.cidr_block`
   - **Kullanım**: VPC'nin IP aralığını görmek için

3. **`public_subnet_ids`**
   - **Açıklama**: Public subnet ID'leri
   - **Değer**: `aws_subnet.public[*].id`
   - **Kullanım**: EC2 instance'ları public subnet'lere yerleştirmek için

4. **`private_subnet_ids`**
   - **Açıklama**: Private subnet ID'leri
   - **Değer**: `aws_subnet.private[*].id`
   - **Kullanım**: Database gibi private kaynakları yerleştirmek için

5. **`internet_gateway_id`**
   - **Açıklama**: Internet Gateway ID
   - **Değer**: `aws_internet_gateway.main.id`
   - **Kullanım**: Internet Gateway'e referans vermek için

6. **`web_security_group_id`**
   - **Açıklama**: Web server security group ID
   - **Değer**: `aws_security_group.web.id`
   - **Kullanım**: EC2 instance'larına security group atamak için

7. **`redis_security_group_id`**
   - **Açıklama**: Redis security group ID
   - **Değer**: `aws_security_group.redis.id`
   - **Kullanım**: Redis instance'larına security group atamak için

8. **`public_route_table_id`**
   - **Açıklama**: Public route table ID
   - **Değer**: `aws_route_table.public.id`
   - **Kullanım**: Route table yönetimi için

9. **`private_route_table_id`**
   - **Açıklama**: Private route table ID
   - **Değer**: `aws_route_table.private.id`
   - **Kullanım**: Route table yönetimi için

---

## 3. Sorular ve Cevaplar

### Soru 1: VPC modülü hangi AWS kaynaklarını oluşturuyor?

**Cevap:**

VPC modülü aşağıdaki AWS kaynaklarını oluşturuyor:

1. **VPC** (`aws_vpc.main`)
   - Ana network yapısı
   - CIDR bloğu: `var.vpc_cidr` (varsayılan: `10.0.0.0/16`)
   - DNS hostname ve DNS support etkin

2. **Internet Gateway** (`aws_internet_gateway.main`)
   - VPC'ye internet erişimi sağlar
   - Public subnet'lerden internet'e çıkış için gerekli

3. **Public Subnet'ler** (`aws_subnet.public`)
   - Her availability zone için bir public subnet
   - `map_public_ip_on_launch = true` (otomatik public IP)
   - CIDR: `cidrsubnet(var.vpc_cidr, 8, count.index)` (örn: `10.0.0.0/24`, `10.0.1.0/24`)

4. **Private Subnet'ler** (`aws_subnet.private`)
   - Her availability zone için bir private subnet
   - `map_public_ip_on_launch = false` (public IP yok)
   - CIDR: `cidrsubnet(var.vpc_cidr, 8, count.index + 10)` (örn: `10.0.10.0/24`, `10.0.11.0/24`)

5. **Public Route Table** (`aws_route_table.public`)
   - Tüm trafiği (`0.0.0.0/0`) Internet Gateway'e yönlendirir
   - Public subnet'lere bağlı

6. **Private Route Table** (`aws_route_table.private`)
   - Sadece local trafik (NAT Gateway yok)
   - Private subnet'lere bağlı

7. **Route Table Associations** (`aws_route_table_association`)
   - Public subnet'leri public route table'a bağlar
   - Private subnet'leri private route table'a bağlar

8. **Security Group - Web** (`aws_security_group.web`)
   - HTTP (80), HTTPS (443), Flask App (5000) portları açık
   - SSH (22) sadece `var.ssh_allowed_cidrs`'dan gelen trafiğe açık
   - Tüm outbound trafik açık

9. **Security Group - Redis** (`aws_security_group.redis`)
   - Port 6379 sadece web security group'tan gelen trafiğe açık
   - Tüm outbound trafik açık

---

### Soru 2: Public subnet ve private subnet arasındaki fark nedir?

**Cevap:**

| Özellik | Public Subnet | Private Subnet |
|---------|---------------|----------------|
| **Internet Erişimi** | ✅ Var (Internet Gateway üzerinden) | ❌ Yok (direkt) |
| **Public IP** | ✅ Otomatik atanır (`map_public_ip_on_launch = true`) | ❌ Atanmaz |
| **Route Table** | Public Route Table (0.0.0.0/0 → IGW) | Private Route Table (sadece local) |
| **Kullanım Amacı** | Web server'lar, load balancer'lar | Database'ler, backend servisler |
| **Güvenlik** | Daha az güvenli (internet'ten erişilebilir) | Daha güvenli (internet'ten erişilemez) |
| **CIDR Örneği** | `10.0.0.0/24`, `10.0.1.0/24` | `10.0.10.0/24`, `10.0.11.0/24` |

**Kod Farkları:**

**Public Subnet:**
```hcl
map_public_ip_on_launch = true  # Public IP otomatik atanır
cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index)  # 10.0.0.0/24, 10.0.1.0/24
```

**Private Subnet:**
```hcl
map_public_ip_on_launch = false  # Public IP yok
cidr_block = cidrsubnet(var.vpc_cidr, 8, count.index + 10)  # 10.0.10.0/24, 10.0.11.0/24
```

**Pratik Örnek:**
- **Public Subnet**: Web server (nginx, Flask app) - kullanıcılar internet'ten erişir
- **Private Subnet**: Database (RDS, Redis) - sadece VPC içinden erişilebilir

---

### Soru 3: Internet Gateway neden gereklidir?

**Cevap:**

Internet Gateway (IGW) aşağıdaki nedenlerle gereklidir:

1. **Internet Erişimi Sağlar**
   - VPC içindeki kaynakların (EC2 instance'ları) internet'e çıkmasını sağlar
   - Public subnet'lerdeki instance'lar internet'e bağlanabilir

2. **Public IP'ler İçin Gerekli**
   - Public subnet'lerdeki instance'ların public IP alabilmesi için IGW gerekli
   - `map_public_ip_on_launch = true` çalışması için IGW olmalı

3. **Route Table Yapılandırması**
   - Public route table'da `0.0.0.0/0` trafiği IGW'ye yönlendirilir
   - IGW olmadan public subnet'ler internet'e çıkamaz

4. **İki Yönlü İletişim**
   - **Outbound**: VPC'den internet'e (örnek: yum update, docker pull)
   - **Inbound**: Internet'ten VPC'ye (örnek: kullanıcılar web uygulamasına erişir)

**Kod Örneği:**
```hcl
# Internet Gateway oluşturuluyor
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

# Public route table'da IGW'ye yönlendirme
resource "aws_route_table" "public" {
  route {
    cidr_block = "0.0.0.0/0"        # Tüm trafik
    gateway_id = aws_internet_gateway.main.id  # IGW'ye git
  }
}
```

**Örnek Senaryo:**
- EC2 instance public subnet'te
- Kullanıcı `http://51.20.68.76:5000` adresine istek gönderir
- İstek → Internet → IGW → Public Subnet → EC2 instance
- EC2 instance yanıt verir → Public Subnet → IGW → Internet → Kullanıcı

**IGW Olmadan Ne Olur?**
- Public subnet'ler internet'e çıkamaz
- Instance'lar yum update, docker pull yapamaz
- Kullanıcılar web uygulamasına erişemez

---

### Soru 4: Route table ne işe yarar?

**Cevap:**

Route Table (Yönlendirme Tablosu), network trafiğinin nereye gideceğini belirleyen bir tablodur. Her subnet bir route table'a bağlıdır.

**Temel İşlevi:**
- Paketlerin hangi yoldan gideceğini belirler
- "Bu IP'ye giden trafik şuraya git" kurallarını içerir

**VPC Modülündeki Route Table'lar:**

1. **Public Route Table** (`aws_route_table.public`)
   ```hcl
   route {
     cidr_block = "0.0.0.0/0"              # Tüm trafik
     gateway_id = aws_internet_gateway.main.id  # Internet Gateway'e git
   }
   ```
   - **Amaç**: Public subnet'lerden internet'e çıkış
   - **Kural**: Tüm trafik (`0.0.0.0/0`) → Internet Gateway
   - **Sonuç**: Public subnet'teki instance'lar internet'e erişebilir

2. **Private Route Table** (`aws_route_table.private`)
   ```hcl
   # Route yok - sadece local trafik
   ```
   - **Amaç**: Private subnet'lerde sadece VPC içi iletişim
   - **Kural**: Route yok (sadece VPC içi trafik)
   - **Sonuç**: Private subnet'teki instance'lar internet'e çıkamaz (NAT Gateway gerekir)

**Route Table Association (Bağlantı):**
```hcl
# Public subnet'leri public route table'a bağla
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
```

**Pratik Örnek:**

**Senaryo 1: Public Subnet'teki EC2 Instance**
```
EC2 instance → HTTP isteği (google.com) → Route Table kontrolü
→ "0.0.0.0/0" kuralı var → Internet Gateway → Internet → Google
```

**Senaryo 2: Private Subnet'teki Database**
```
EC2 instance (public) → Database'e bağlan (10.0.10.5) → Route Table kontrolü
→ VPC içi IP → Doğrudan VPC içinde iletişim → Database
```

**Senaryo 3: Private Subnet'ten Internet (Çalışmaz)**
```
EC2 instance (private) → HTTP isteği (google.com) → Route Table kontrolü
→ Route yok → Trafik düşer → Internet'e çıkamaz
```

**Özet:**
- Route Table = Trafik yönlendirme kuralları
- Public Route Table = Internet'e çıkış için
- Private Route Table = Sadece VPC içi iletişim için
- Her subnet bir route table'a bağlı olmalı

---

## 4. Özet ve Öğrenilenler

### VPC Modülü Yapısı:

```
VPC (10.0.0.0/16)
├── Internet Gateway
├── Public Subnets (10.0.0.0/24, 10.0.1.0/24)
│   └── Public Route Table (0.0.0.0/0 → IGW)
├── Private Subnets (10.0.10.0/24, 10.0.11.0/24)
│   └── Private Route Table (sadece local)
├── Security Group - Web (HTTP, HTTPS, Flask, SSH)
└── Security Group - Redis (sadece web'den)
```

### Önemli Noktalar:

1. **VPC**: Tüm network yapısının temeli
2. **Subnet'ler**: Availability zone'lara dağıtılmış network segmentleri
3. **Internet Gateway**: Internet erişimi için zorunlu
4. **Route Table**: Trafik yönlendirme kuralları
5. **Security Group**: Firewall kuralları (port kontrolü)

### Güvenlik Katmanları:

1. **Network Seviyesi**: Public/Private subnet ayrımı
2. **Route Table**: Trafik yönlendirme kontrolü
3. **Security Group**: Port ve IP bazlı erişim kontrolü

---

**Tarih**: 2025-11-13
**Ödev**: Ödev 2 - VPC Modülü Analizi
**Durum**: ✅ Tamamlandı

