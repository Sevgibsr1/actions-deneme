# 🐳 Docker Öğrenme Rehberi - DevOps Stajyeri İçin

## 📚 Docker Nedir?

**Docker**, uygulamalarınızı container'lar içinde çalıştırmanızı sağlayan bir platformdur.

### Temel Kavramlar:

1. **Image (Görüntü)**: Container'ın şablonu/kalıbı
   - Örnek: `python:3.10-slim` bir image'dır
   - Image'ları kendiniz oluşturabilir veya hazır kullanabilirsiniz

2. **Container**: Image'dan çalışan bir örnek
   - Image'dan bir container oluşturduğunuzda, o container bağımsız çalışır

3. **Dockerfile**: Image'ı nasıl oluşturacağınızı tarif eden dosya

---

## 🛠️ Temel Docker Komutları

### 1️⃣ Image Oluşturma (Build)

```bash
# Dockerfile'dan image oluştur
docker build -t actions-deneme .

# Açıklama:
# - docker build: Image oluştur
# - -t actions-deneme: Image'a "actions-deneme" adını ver (tag)
# - . : Dockerfile'ın bulunduğu klasör (şu anki klasör)
```

**Örnek Çıktı:**
```
Step 1/5 : FROM python:3.10-slim
Step 2/5 : WORKDIR /app
Step 3/5 : COPY . .
Step 4/5 : RUN pip install ...
Step 5/5 : CMD ["pytest", ...]
```

### 2️⃣ Image'ları Listeleme

```bash
# Tüm image'ları listele
docker images

# veya
docker image ls
```

### 3️⃣ Container Çalıştırma

```bash
# Container'ı çalıştır (CMD komutunu otomatik çalıştırır)
docker run actions-deneme

# Container'ı çalıştır ve sonra sil (--rm)
docker run --rm actions-deneme

# Container'ı arka planda çalıştır (-d = detach)
docker run -d actions-deneme

# Container içine girip komut çalıştır
docker run -it actions-deneme bash
# -it: Interactive terminal
# bash: Container içinde bash shell aç
```

### 4️⃣ Container'ları Listeleme

```bash
# Çalışan container'ları listele
docker ps

# Tüm container'ları listele (durdurulmuş olanlar dahil)
docker ps -a

# veya
docker container ls -a
```

### 5️⃣ Container Durdurma ve Silme

```bash
# Container'ı durdur
docker stop <container_id>

# Container'ı sil
docker rm <container_id>

# Çalışan container'ı zorla durdur ve sil
docker rm -f <container_id>

# Tüm durdurulmuş container'ları sil
docker container prune
```

### 6️⃣ Image Silme

```bash
# Image'ı sil
docker rmi actions-deneme

# veya
docker image rm actions-deneme

# Kullanılmayan tüm image'ları sil
docker image prune -a
```

### 7️⃣ Container İçine Girme

```bash
# Çalışan bir container içine gir
docker exec -it <container_id> bash

# Örnek:
# docker exec -it abc123def456 bash
```

---

## 🎯 Bu Projede Pratik Kullanım

### Senaryo 1: İlk Docker Denemesi

```bash
# 1. Image oluştur
docker build -t actions-deneme .

# 2. Container'ı çalıştır (testleri otomatik çalıştırır)
docker run --rm actions-deneme

# 3. Container içine gir ve dosyaları incele
docker run -it --rm actions-deneme bash
# Container içinde:
#   ls -la          # Dosyaları listele
#   python hello.py # Python scriptini çalıştır
#   exit            # Çık
```

### Senaryo 2: Farklı Komut Çalıştırma

```bash
# Container'ı çalıştır ama pytest yerine farklı bir komut çalıştır
docker run --rm actions-deneme python hello.py

# Container içinde bash shell'i aç
docker run -it --rm actions-deneme bash
```

### Senaryo 3: Volume Mount (Dosya Paylaşımı)

```bash
# Host makinenizdeki bir klasörü container ile paylaş
docker run -it --rm -v $(pwd):/app actions-deneme bash
# -v: Volume mount (dosya paylaşımı)
# $(pwd): Şu anki klasör (host)
# /app: Container içindeki klasör
```

---

## 🔍 Debug ve İnceleme

### Container Loglarını Görme

```bash
# Container loglarını gör
docker logs <container_id>

# Canlı logları takip et (-f = follow)
docker logs -f <container_id>
```

### Container Detaylarını İnceleme

```bash
# Container hakkında detaylı bilgi
docker inspect <container_id>

# Sadece çalışma dizinini öğren
docker inspect <container_id> | grep WorkDir
```

---

## 📊 Docker Komutları Özeti

| Komut | Açıklama |
|-------|----------|
| `docker build -t <isim> .` | Image oluştur |
| `docker images` | Image'ları listele |
| `docker run <image>` | Container çalıştır |
| `docker ps` | Çalışan container'ları listele |
| `docker ps -a` | Tüm container'ları listele |
| `docker stop <id>` | Container durdur |
| `docker rm <id>` | Container sil |
| `docker rmi <image>` | Image sil |
| `docker exec -it <id> bash` | Container içine gir |
| `docker logs <id>` | Logları gör |

---

## 🎓 Öğrenme Hedefleri

✅ Docker'ın ne olduğunu anlama
✅ Dockerfile'ı okuma ve anlama
✅ Image oluşturma
✅ Container çalıştırma
✅ Container'ları yönetme (listeleme, durdurma, silme)
✅ Container içine girme ve debug yapma

---

## 💡 İpuçları

1. **--rm flag'i**: Container bittiğinde otomatik silinir
2. **-it flag'i**: Interactive terminal (container içine girmek için)
3. **-d flag'i**: Detached mode (arka planda çalıştır)
4. **-v flag'i**: Volume mount (dosya paylaşımı)
5. Her zaman önce `docker build`, sonra `docker run`

---

## 🚀 Sonraki Adımlar

1. Docker Compose öğren (birden fazla container'ı yönetmek için)
2. Docker Registry kullanımı (Docker Hub)
3. Multi-stage builds (daha küçük image'lar için)
4. Docker network (container'lar arası iletişim)

---

**Hazırlayan**: DevOps Stajyeri için öğrenme rehberi
**Tarih**: 2024

