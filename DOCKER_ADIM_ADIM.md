# 🐳 Docker Image Oluşturma - Adım Adım Rehber

## 📋 Bu Rehberde Neler Öğreneceksiniz?

1. ✅ Local bilgisayarınızda Docker image oluşturma
2. ✅ Docker'da image'ları görüntüleme
3. ✅ Container çalıştırma ve test etme
4. ✅ GitHub Actions'da Docker'ın çalışması

---

## 🚀 ADIM 1: Local'de Docker Image Oluşturma

### Kontrol: Docker Kurulu mu?

Önce Docker'ın kurulu olup olmadığını kontrol edelim:

```bash
# Docker versiyonunu kontrol et
docker --version

# Docker servisinin çalışıp çalışmadığını kontrol et
docker ps
```

**Eğer hata alırsanız:**
- Windows: Docker Desktop'ı kurun ve çalıştırın
- Linux: `sudo apt install docker.io` veya `sudo yum install docker`

### Image Oluşturma (Build)

```bash
# 1. Proje klasörüne gidin
cd /home/sevgi-bsr/actions-deneme

# 2. Docker image oluşturun
docker build -t actions-deneme .

# Açıklama:
# - docker build: Image oluştur komutu
# - -t actions-deneme: Image'a "actions-deneme" adını ver (tag)
# - . : Dockerfile'ın bulunduğu klasör (şu anki klasör)
```

**Beklenen Çıktı:**
```
Step 1/5 : FROM python:3.10-slim
 ---> abc123def456
Step 2/5 : WORKDIR /app
 ---> Running in xyz789
Step 3/5 : COPY . .
 ---> abc123def456
Step 4/5 : RUN pip install --no-cache-dir pytest pytest-cov flake8
 ---> Running in xyz789
...
Step 5/5 : CMD ["pytest", "--maxfail=1", "--disable-warnings", "-q"]
 ---> abc123def456
Successfully built abc123def456
Successfully tagged actions-deneme:latest
```

**✅ Başarılı!** Image'ınız oluşturuldu!

---

## 👀 ADIM 2: Docker'da Image'ları Görüntüleme

### Tüm Image'ları Listeleme

```bash
# Tüm image'ları listele
docker images

# veya
docker image ls
```

**Beklenen Çıktı:**
```
REPOSITORY       TAG       IMAGE ID       CREATED         SIZE
actions-deneme   latest    abc123def456   2 minutes ago   150MB
python           3.10-slim xyz789abc123   2 weeks ago     120MB
```

**Açıklama:**
- **REPOSITORY**: Image'ın adı (`actions-deneme`)
- **TAG**: Versiyon/genellikle `latest`
- **IMAGE ID**: Unique ID
- **CREATED**: Oluşturulma zamanı
- **SIZE**: Image boyutu

### Belirli Bir Image'ı Görüntüleme

```bash
# Sadece actions-deneme image'ını göster
docker images actions-deneme

# Image detaylarını görüntüle
docker image inspect actions-deneme
```

### Image Hakkında Detaylı Bilgi

```bash
# Image hakkında tüm bilgileri JSON formatında göster
docker image inspect actions-deneme

# Sadece boyutu göster
docker images actions-deneme --format "{{.Size}}"

# Sadece ID göster
docker images actions-deneme --format "{{.ID}}"
```

---

## 🏃 ADIM 3: Container Çalıştırma

### Container'ı Çalıştırma (Test)

```bash
# Container'ı çalıştır (CMD komutu otomatik çalışır - pytest)
docker run --rm actions-deneme

# Açıklama:
# - docker run: Container çalıştır
# - --rm: Container bittiğinde otomatik sil
# - actions-deneme: Hangi image'dan container oluştur
```

**Beklenen Çıktı:**
```
========================= test session starts =========================
test_bol.py::test_bol PASSED
test_carp.py::test_carp PASSED
...
========================= 2 passed in 0.05s =========================
```

### Container İçine Girme (İnceleme)

```bash
# Container içine bash shell ile gir
docker run -it --rm actions-deneme bash

# Container içinde:
#   ls -la          # Dosyaları listele
#   pwd             # Mevcut dizini göster
#   python hello.py # Python scriptini çalıştır
#   pytest          # Testleri manuel çalıştır
#   exit            # Çık
```

### Farklı Komut Çalıştırma

```bash
# Container'da pytest yerine farklı bir komut çalıştır
docker run --rm actions-deneme python hello.py

# Container'da bash aç ve komut çalıştır
docker run --rm actions-deneme sh -c "ls -la && pytest"
```

---

## 📊 ADIM 4: Container'ları Yönetme

### Çalışan Container'ları Görüntüleme

```bash
# Çalışan container'ları listele
docker ps

# Tüm container'ları listele (durdurulmuş olanlar dahil)
docker ps -a
```

### Container Loglarını Görme

```bash
# Container ID'sini öğren (docker ps ile)
docker ps

# Logları görüntüle
docker logs <container_id>

# Canlı logları takip et
docker logs -f <container_id>
```

**Örnek:**
```bash
# Container'ı arka planda çalıştır
docker run -d --name test-container actions-deneme

# Logları gör
docker logs test-container
```

---

## 🔍 ADIM 5: Image Detaylarını İnceleme

### Image Katmanlarını Görme

```bash
# Image'ın nasıl oluşturulduğunu göster (her adım)
docker history actions-deneme

# Daha okunabilir format
docker history actions-deneme --human --format "{{.CreatedBy}}"
```

### Image İçeriğini İnceleme

```bash
# Image içindeki dosyaları görüntüle (geçici container)
docker run --rm actions-deneme ls -la /app

# Image içindeki Python versiyonunu kontrol et
docker run --rm actions-deneme python --version

# Image içinde hangi paketler yüklü?
docker run --rm actions-deneme pip list
```

---

## 🎯 ADIM 6: Pratik Test Senaryoları

### Senaryo 1: Image Oluştur ve Test Et

```bash
# 1. Image oluştur
docker build -t actions-deneme .

# 2. Image'ları listele
docker images | grep actions-deneme

# 3. Container çalıştır
docker run --rm actions-deneme

# 4. Container içine gir ve incele
docker run -it --rm actions-deneme bash
```

### Senaryo 2: Image'ı Farklı Tag ile Oluştur

```bash
# Farklı versiyon/tag ile oluştur
docker build -t actions-deneme:v1.0 .
docker build -t actions-deneme:latest .

# Tüm tag'leri görüntüle
docker images actions-deneme
```

### Senaryo 3: Build Cache Temizleme

```bash
# Cache olmadan build (her şeyi yeniden yapar)
docker build --no-cache -t actions-deneme .

# Build sırasında progress göster
docker build --progress=plain -t actions-deneme .
```

---

## 🚀 ADIM 7: GitHub Actions'da Docker

GitHub Actions workflow'unuzda Docker adımları zaten var! İşte nasıl çalıştığını görelim:

### Mevcut Workflow Docker Adımları

```yaml
- name: Docker kurulumu
  uses: docker/setup-buildx-action@v3

- name: Docker image oluştur
  run: docker build -t actions-deneme .

- name: Docker container'ı test et
  run: docker run actions-deneme
```

### İyileştirilmiş Workflow (Daha Fazla Bilgi)

Şimdi workflow'unuza image görüntüleme adımlarını ekleyelim:

```yaml
- name: Docker kurulumu
  uses: docker/setup-buildx-action@v3

- name: Docker image oluştur
  run: docker build -t actions-deneme .

- name: Docker image'ları listele
  run: docker images

- name: Docker image detaylarını göster
  run: |
    echo "📦 Oluşturulan image:"
    docker images actions-deneme
    echo ""
    echo "📊 Image boyutu:"
    docker images actions-deneme --format "{{.Size}}"
    echo ""
    echo "🆔 Image ID:"
    docker images actions-deneme --format "{{.ID}}"

- name: Docker container'ı test et
  run: docker run --rm actions-deneme

- name: Container içine gir ve dosyaları listele
  run: docker run --rm actions-deneme ls -la /app
```

---

## 📝 Hızlı Komut Referansı

### Image İşlemleri

```bash
# Image oluştur
docker build -t actions-deneme .

# Image'ları listele
docker images

# Image detaylarını gör
docker image inspect actions-deneme

# Image'ı sil
docker rmi actions-deneme

# Kullanılmayan image'ları sil
docker image prune
```

### Container İşlemleri

```bash
# Container çalıştır
docker run --rm actions-deneme

# Container içine gir
docker run -it --rm actions-deneme bash

# Container'ları listele
docker ps -a

# Container loglarını gör
docker logs <container_id>

# Container sil
docker rm <container_id>
```

### Debug ve İnceleme

```bash
# Image katmanlarını gör
docker history actions-deneme

# Image içeriğini gör
docker run --rm actions-deneme ls -la

# Build sırasında detaylı log
docker build --progress=plain -t actions-deneme .
```

---

## 🎓 Öğrenme Kontrol Listesi

- [ ] Docker image oluşturmayı öğrendim
- [ ] `docker images` ile image'ları görebiliyorum
- [ ] `docker run` ile container çalıştırabiliyorum
- [ ] Container içine girebiliyorum
- [ ] GitHub Actions'da Docker'ın çalıştığını anladım
- [ ] Image detaylarını inceleyebiliyorum

---

## 💡 İpuçları

1. **Her zaman `--rm` kullanın**: Container bittiğinde otomatik silinir
2. **`-it` flag'i**: Container içine girmek için gerekli
3. **Image'ları düzenli temizleyin**: `docker image prune` ile
4. **Build cache'i kullanın**: İlk build yavaş, sonrakiler hızlı
5. **Tag'leri kullanın**: Versiyonlama için önemli

---

## 🐛 Sorun Giderme

### Problem: "docker: command not found"

**Çözüm:**
```bash
# Docker kurulu mu kontrol et
which docker

# Docker Desktop'ı başlat (Windows/Mac)
# veya
sudo systemctl start docker  # Linux
```

### Problem: "permission denied"

**Çözüm (Linux):**
```bash
# Docker grubuna ekle
sudo usermod -aG docker $USER
# Sonra oturumu kapatıp aç
```

### Problem: "Cannot connect to Docker daemon"

**Çözüm:**
```bash
# Docker servisini başlat
sudo systemctl start docker  # Linux
# veya Docker Desktop'ı başlat (Windows/Mac)
```

---

**Hazırlayan**: DevOps Stajyeri için pratik rehber
**Tarih**: 2024

