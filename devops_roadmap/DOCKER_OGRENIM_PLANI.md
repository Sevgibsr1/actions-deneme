# 🐳 Docker Öğrenim Planı - DevOps Stajyeri İçin

## 📊 Proje Analizi

### ✅ Şu An Bildikleriniz:
1. ✅ Docker image oluşturma (`docker build`)
2. ✅ Container çalıştırma (`docker run`)
3. ✅ Dockerfile okuma ve anlama
4. ✅ GitHub Actions'da Docker kullanımı
5. ✅ Image'ları görüntüleme (`docker images`)

### 🎯 Öğrenmeniz Gerekenler:

#### **SEVIYE 1: Temel Kavramlar ve Yönetim** (ŞİMDİ YAPILACAK)
- [ ] Container'ları yönetme (durma, silme, listeleme)
- [ ] Container içine girme ve debug
- [ ] Container loglarını görme
- [ ] Image silme ve temizleme
- [ ] Volume mount (dosya paylaşımı)
- [ ] Environment variable kullanımı

#### **SEVIYE 2: Dockerfile Gelişmiş Özellikler** (İKİNCİ AŞAMA)
- [ ] Multi-stage builds
- [ ] .dockerignore kullanımı
- [ ] ARG ve ENV kullanımı
- [ ] Layer caching optimizasyonu
- [ ] Health check ekleme

#### **SEVIYE 3: Docker Compose** (ÜÇÜNCÜ AŞAMA)
- [ ] docker-compose.yml oluşturma
- [ ] Birden fazla container'ı birlikte çalıştırma
- [ ] Network oluşturma
- [ ] Service dependency yönetimi

#### **SEVIYE 4: Registry ve CI/CD** (DÖRDÜNCÜ AŞAMA)
- [ ] Docker Hub'a push/pull
- [ ] GitHub Container Registry kullanımı
- [ ] Image tagging stratejileri
- [ ] Production-ready image optimizasyonu

---

## 📚 ÖĞRENİM AŞAMALARI

### 🔵 AŞAMA 1: Container Yönetimi (ÖNCE BUNU ÖĞREN)

#### 1.1 Container Yaşam Döngüsü
```
Oluştur → Çalıştır → Durdur → Sil
```

**Öğrenme Hedefleri:**
- Container'ları listeleme (`docker ps`, `docker ps -a`)
- Container durdurma (`docker stop`)
- Container silme (`docker rm`)
- Container loglarını görme (`docker logs`)
- Container içine girme (`docker exec`)

#### 1.2 Pratik Ödevler
- [ ] ÖDEV 1: Container'ları yönetme (bakınız: `ODEV1_CONTAINER_YONETIMI.md`)
- [ ] ÖDEV 2: Container debug ve log inceleme (bakınız: `ODEV2_CONTAINER_DEBUG.md`)
- [ ] ÖDEV 3: Volume mount ile dosya paylaşımı (bakınız: `ODEV3_VOLUME_MOUNT.md`)

---

### 🟢 AŞAMA 2: Dockerfile İyileştirme

#### 2.1 Gelişmiş Dockerfile Teknikleri
- `.dockerignore` dosyası oluşturma
- Multi-stage builds
- Layer caching optimizasyonu
- Environment variables

#### 2.2 Pratik Ödevler
- [ ] ÖDEV 4: .dockerignore oluşturma
- [ ] ÖDEV 5: Multi-stage build yapma
- [ ] ÖDEV 6: Environment variable kullanımı

---

### 🟡 AŞAMA 3: Docker Compose

#### 3.1 Birden Fazla Container Yönetimi
- docker-compose.yml oluşturma
- Service tanımlama
- Network oluşturma

#### 3.2 Pratik Ödevler
- [ ] ÖDEV 7: Docker Compose ile multi-container uygulama

---

### 🔴 AŞAMA 4: Production Ready

#### 4.1 Production Best Practices
- Image güvenlik
- Image boyut optimizasyonu
- Health checks
- Proper tagging

---

## 🎯 ŞİMDİ YAPILACAKLAR (ÖNCELİK SIRASI)

### 1️⃣ ÖDEV 1: Container Yönetimi
**Süre:** 30 dakika  
**Dosya:** `ODEV1_CONTAINER_YONETIMI.md`

**Öğrenecekleriniz:**
- Container'ları listeleme
- Container durdurma ve silme
- Container isimlendirme
- Container'ları temizleme

### 2️⃣ ÖDEV 2: Container Debug
**Süre:** 30 dakika  
**Dosya:** `ODEV2_CONTAINER_DEBUG.md`

**Öğrenecekleriniz:**
- Container içine girme
- Log görüntüleme
- Container inceleme
- Debug teknikleri

### 3️⃣ ÖDEV 3: Volume Mount
**Süre:** 45 dakika  
**Dosya:** `ODEV3_VOLUME_MOUNT.md`

**Öğrenecekleriniz:**
- Host-Container dosya paylaşımı
- Volume mount kullanımı
- Live reload geliştirme

---

## 📝 Öğrenim Takibi

Her ödev için:
- [ ] Ödevi oku ve anla
- [ ] Komutları çalıştır
- [ ] Sonuçları kontrol et
- [ ] Öğrendiklerini not al
- [ ] Sonraki ödeve geç

---

## 🎓 Başarı Kriterleri

**Aşama 1'i tamamladığınızda:**
- ✅ Container'ları yönetebiliyorsunuz
- ✅ Debug yapabiliyorsunuz
- ✅ Volume mount kullanabiliyorsunuz
- ✅ Logları inceleyebiliyorsunuz

**Aşama 2'yi tamamladığınızda:**
- ✅ Optimize Dockerfile yazabiliyorsunuz
- ✅ .dockerignore kullanabiliyorsunuz
- ✅ Multi-stage build yapabiliyorsunuz

**Aşama 3'ü tamamladığınızda:**
- ✅ Docker Compose ile uygulama çalıştırabiliyorsunuz
- ✅ Multiple container'ları yönetebiliyorsunuz

---

## 💡 İpuçları

1. **Her ödevi sırayla yapın** - Önceki ödevler sonrakiler için temel oluşturur
2. **Hata yapmaktan korkmayın** - Hatalardan öğrenirsiniz
3. **Komutları tekrar tekrar çalıştırın** - Pratik yapmak önemli
4. **Not alın** - Kendi cheatsheet'inizi oluşturun
5. **Her ödevi tamamladıktan sonra kendinizi test edin**

---

## 🚀 Başlayalım!

**İlk adım:** `ODEV1_CONTAINER_YONETIMI.md` dosyasını açın ve başlayın!

Başarılar! 🎉

