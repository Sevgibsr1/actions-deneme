# 📋 ÖDEV 1: Container Yönetimi

## 🎯 Öğrenme Hedefleri

Bu ödevi tamamladığınızda:
- ✅ Container'ları listeleme
- ✅ Container durdurma ve silme
- ✅ Container isimlendirme
- ✅ Container'ları temizleme
- ✅ Container yaşam döngüsünü anlama

---

## 📝 ADIM 1: Container'ları Listeleme

### 1.1 Çalışan Container'ları Görme

```bash
# Çalışan container'ları listele
docker ps
```

**Görev:**
- Bu komutu çalıştırın
- Eğer hiç container çalışmıyorsa, bu normaldir
- Çıktıyı inceleyin

**Beklenen Çıktı:**
```
CONTAINER ID   IMAGE             COMMAND   CREATED   STATUS   PORTS   NAMES
```

### 1.2 Tüm Container'ları Görme (Durdurulmuş Olanlar Dahil)

```bash
# Tüm container'ları listele
docker ps -a
```

**Görev:**
- Bu komutu çalıştırın
- Daha önce çalıştırdığınız container'lar varsa burada görünecek
- Her container'ın bir ID'si ve STATUS'u olduğunu not edin

---

## 📝 ADIM 2: Container Oluşturma ve İsimlendirme

### 2.1 İsimsiz Container Çalıştırma

```bash
# Container'ı çalıştır (isim vermeden)
docker run --rm actions-deneme
```

**Görev:**
- Bu komutu çalıştırın
- Container çalışır, testler geçer, sonra silinir (--rm sayesinde)

### 2.2 İsimli Container Çalıştırma

```bash
# Container'a isim vererek çalıştır
docker run --name test-container-1 actions-deneme
```

**Görev:**
- Bu komutu çalıştırın
- Container'ın adı "test-container-1" olacak
- Container bittiğinde hala duruyor olacak (--rm kullanmadık)

**Sonra kontrol edin:**
```bash
docker ps -a
```

**Görev:**
- "test-container-1" isimli container'ı görmelisiniz
- STATUS'u "Exited" olmalı

---

## 📝 ADIM 3: Container Durdurma

### 3.1 Arka Planda Çalışan Container'ı Durdurma

**Önce bir container'ı arka planda çalıştırın:**
```bash
# Container'ı arka planda çalıştır (sonsuz döngü için sleep kullanıyoruz)
docker run -d --name test-running-container actions-deneme sleep 3600
```

**Görev:**
- Bu komutu çalıştırın
- Container arka planda çalışacak

**Şimdi çalışan container'ları kontrol edin:**
```bash
docker ps
```

**Görev:**
- "test-running-container" isimli container'ı görmelisiniz
- STATUS'u "Up" olmalı

**Container'ı durdurun:**
```bash
docker stop test-running-container
```

**Görev:**
- Bu komutu çalıştırın
- Container durdurulacak

**Kontrol edin:**
```bash
docker ps -a
```

**Görev:**
- Container'ın STATUS'u "Exited" olmalı

---

## 📝 ADIM 4: Container Silme

### 4.1 Tek Container Silme

```bash
# Container'ı sil
docker rm test-container-1
```

**Görev:**
- Bu komutu çalıştırın
- Container silinecek

**Kontrol edin:**
```bash
docker ps -a | grep test-container-1
```

**Görev:**
- Container listede görünmemeli

### 4.2 Çalışan Container'ı Zorla Silme

```bash
# Önce bir container çalıştırın
docker run -d --name test-force-container actions-deneme sleep 3600

# Çalışan container'ı zorla durdur ve sil
docker rm -f test-force-container
```

**Görev:**
- `docker rm -f` komutu container'ı durdurur ve siler
- Hem `stop` hem de `rm` yapar

---

## 📝 ADIM 5: Toplu Temizleme

### 5.1 Tüm Durdurulmuş Container'ları Silme

```bash
# Önce birkaç durdurulmuş container oluşturun
docker run --name temp1 actions-deneme
docker run --name temp2 actions-deneme
docker run --name temp3 actions-deneme

# Tüm durdurulmuş container'ları sil
docker container prune
```

**Görev:**
- Bu komutu çalıştırın
- Onay isteyecek, "y" yazın
- Tüm durdurulmuş container'lar silinecek

### 5.2 Tüm Container'ları Silme (Dikkatli!)

```bash
# Tüm container'ları durdur
docker stop $(docker ps -aq)

# Tüm container'ları sil
docker rm $(docker ps -aq)
```

**⚠️ DİKKAT:** Bu komutlar TÜM container'larınızı siler!

**Görev:**
- Bu komutları çalıştırmadan önce düşünün
- Sadece test container'larınız varsa kullanın

---

## 📝 ADIM 6: Container Bilgilerini Görme

### 6.1 Container Detaylarını İnceleme

```bash
# Bir container oluşturun
docker run --name inspect-test actions-deneme

# Container detaylarını görüntüle
docker inspect inspect-test
```

**Görev:**
- `docker inspect` komutu JSON formatında detaylı bilgi verir
- Container ID, image, mount point, network gibi bilgileri gösterir

### 6.2 Belirli Bilgileri Çıkarma

```bash
# Sadece container ID'sini göster
docker inspect inspect-test --format='{{.Id}}'

# Sadece container durumunu göster
docker inspect inspect-test --format='{{.State.Status}}'

# Sadece image adını göster
docker inspect inspect-test --format='{{.Config.Image}}'
```

**Görev:**
- Bu formatları kullanarak istediğiniz bilgiyi çıkarabilirsiniz

---

## ✅ ÖDEV KONTROL LİSTESİ

Ödevi tamamladınız mı? Aşağıdakileri kontrol edin:

- [ ] `docker ps` ile çalışan container'ları görebiliyorum
- [ ] `docker ps -a` ile tüm container'ları görebiliyorum
- [ ] `docker run --name` ile isimli container oluşturabiliyorum
- [ ] `docker stop` ile container durdurabiliyorum
- [ ] `docker rm` ile container silebiliyorum
- [ ] `docker rm -f` ile çalışan container'ı zorla silebiliyorum
- [ ] `docker container prune` ile toplu temizlik yapabiliyorum
- [ ] `docker inspect` ile container detaylarını görebiliyorum

---

## 🎯 PRATİK SENARYO

**Senaryo:** Bir test ortamında 3 farklı container çalıştırıp, sonra bunları temizleyin.

**Adımlar:**
1. 3 farklı isimle container oluşturun:
   ```bash
   docker run --name test-1 actions-deneme
   docker run --name test-2 actions-deneme
   docker run --name test-3 actions-deneme
   ```

2. Container'ları listeleyin:
   ```bash
   docker ps -a
   ```

3. Container'ları tek tek silin:
   ```bash
   docker rm test-1
   docker rm test-2
   docker rm test-3
   ```

4. Veya toplu olarak silin:
   ```bash
   docker container prune
   ```

---

## 📚 ÖĞRENDİĞİNİZ KOMUTLAR

| Komut | Açıklama |
|-------|----------|
| `docker ps` | Çalışan container'ları listele |
| `docker ps -a` | Tüm container'ları listele |
| `docker run --name <isim>` | İsimli container oluştur |
| `docker stop <container>` | Container durdur |
| `docker rm <container>` | Container sil |
| `docker rm -f <container>` | Container'ı zorla durdur ve sil |
| `docker container prune` | Tüm durdurulmuş container'ları sil |
| `docker inspect <container>` | Container detaylarını göster |

---

## 🎓 SONRAKI ADIM

Ödev 1'i tamamladıysanız, **ÖDEV 2: Container Debug** (`ODEV2_CONTAINER_DEBUG.md`) dosyasına geçin!

Başarılar! 🎉

