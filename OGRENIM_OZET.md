# 📚 Docker Öğrenim Özeti - Hızlı Başvuru

## 🎯 Proje Analizi

### Mevcut Durumunuz:
- ✅ Python test projesi (`test_bol.py`, `test_carp.py`, `test_script.py`)
- ✅ Dockerfile hazır ve çalışıyor
- ✅ GitHub Actions workflow'ları var
- ✅ Docker image oluşturup çalıştırmışsınız

### Öğrenmeniz Gerekenler:
1. **Container Yönetimi** - Container'ları yönetme, durdurma, silme
2. **Container Debug** - Log görme, içine girme, debug teknikleri
3. **Volume Mount** - Dosya paylaşımı, live reload
4. **Dockerfile İyileştirme** - .dockerignore, multi-stage builds
5. **Docker Compose** - Multi-container uygulamalar

---

## 🚀 HIZLI BAŞLANGIÇ

### 1. Başlangıç Rehberini Okuyun
```bash
cat BASLA_BURADAN.md
```

### 2. Öğrenim Planını İnceleyin
```bash
cat DOCKER_OGRENIM_PLANI.md
```

### 3. İlk Ödevi Yapın
```bash
cat ODEV1_CONTAINER_YONETIMI.md
```

---

## 📋 ÖDEV LİSTESİ

### 🔵 Seviye 1: Temel Yönetim (ÖNCE BUNLAR)

1. **ÖDEV 1: Container Yönetimi** (`ODEV1_CONTAINER_YONETIMI.md`)
   - Container listeleme
   - Container durdurma ve silme
   - Container isimlendirme
   - ⏱️ Süre: 30 dakika

2. **ÖDEV 2: Container Debug** (`ODEV2_CONTAINER_DEBUG.md`)
   - Container içine girme
   - Log görüntüleme
   - Debug teknikleri
   - ⏱️ Süre: 30 dakika

3. **ÖDEV 3: Volume Mount** (`ODEV3_VOLUME_MOUNT.md`)
   - Dosya paylaşımı
   - Live reload geliştirme
   - Named volume kullanımı
   - ⏱️ Süre: 45 dakika

### 🟢 Seviye 2: Dockerfile İyileştirme (SONRA)

4. **ÖDEV 4: .dockerignore ve Optimizasyon** (Yakında)
5. **ÖDEV 5: Multi-stage Builds** (Yakında)
6. **ÖDEV 6: Environment Variables** (Yakında)

### 🟡 Seviye 3: Docker Compose (SONRA)

7. **ÖDEV 7: Docker Compose ile Multi-container** (Yakında)

---

## 📚 TEMEL KOMUTLAR

### Image İşlemleri
```bash
docker build -t actions-deneme .    # Image oluştur
docker images                        # Image'ları listele
docker rmi actions-deneme           # Image sil
```

### Container İşlemleri
```bash
docker run --rm actions-deneme      # Container çalıştır
docker ps                           # Çalışan container'ları listele
docker ps -a                        # Tüm container'ları listele
docker stop <container>             # Container durdur
docker rm <container>               # Container sil
docker exec -it <container> bash    # Container içine gir
docker logs <container>             # Logları gör
```

### Volume İşlemleri
```bash
docker run -v $(pwd):/app ...       # Volume mount
docker volume ls                    # Volume'ları listele
docker volume prune                 # Kullanılmayan volume'ları temizle
```

---

## ✅ ÖĞRENİM TAKİBİ

### Seviye 1 Kontrol Listesi:
- [ ] ÖDEV 1: Container Yönetimi tamamlandı
- [ ] ÖDEV 2: Container Debug tamamlandı
- [ ] ÖDEV 3: Volume Mount tamamlandı

### Seviye 2 Kontrol Listesi:
- [ ] .dockerignore öğrenildi
- [ ] Multi-stage builds öğrenildi
- [ ] Environment variables öğrenildi

### Seviye 3 Kontrol Listesi:
- [ ] Docker Compose öğrenildi
- [ ] Multi-container uygulama yapıldı

---

## 💡 İPUÇLARI

1. **Her ödevi sırayla yapın** - Önceki ödevler sonrakiler için temel
2. **Komutları kendiniz yazın** - Pratik yapmak önemli
3. **Hata yapmaktan korkmayın** - Hatalardan öğrenirsiniz
4. **Not alın** - Kendi cheatsheet'inizi oluşturun
5. **Tekrar edin** - Öğrendiklerinizi pekiştirin

---

## 🎓 BAŞARI KRİTERLERİ

**Seviye 1'i tamamladığınızda:**
- ✅ Container'ları yönetebiliyorsunuz
- ✅ Debug yapabiliyorsunuz
- ✅ Volume mount kullanabiliyorsunuz
- ✅ Logları inceleyebiliyorsunuz

**Seviye 2'yi tamamladığınızda:**
- ✅ Optimize Dockerfile yazabiliyorsunuz
- ✅ .dockerignore kullanabiliyorsunuz
- ✅ Multi-stage build yapabiliyorsunuz

**Seviye 3'ü tamamladığınızda:**
- ✅ Docker Compose ile uygulama çalıştırabiliyorsunuz
- ✅ Multiple container'ları yönetebiliyorsunuz

---

## 🚀 ŞİMDİ NE YAPMALISINIZ?

1. **`BASLA_BURADAN.md`** dosyasını okuyun
2. **`DOCKER_OGRENIM_PLANI.md`** dosyasını inceleyin
3. **`ODEV1_CONTAINER_YONETIMI.md`** ile başlayın
4. Her ödevi adım adım tamamlayın
5. Öğrendiklerinizi pratik edin

---

## 📞 YARDIM

- Her ödev dosyasında detaylı açıklamalar var
- Komutlar adım adım gösterilmiş
- Beklenen çıktılar belirtilmiş
- Sorun giderme ipuçları var

---

**Başarılar! Docker öğrenmek heyecan verici bir yolculuk. Her ödevi tamamladığınızda bir adım daha ilerliyorsunuz.** 🎉

