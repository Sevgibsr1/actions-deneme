# 📋 ÖDEV 2: Container Debug ve Log İnceleme

## 🎯 Öğrenme Hedefleri

Bu ödevi tamamladığınızda:
- ✅ Container içine girme (`docker exec`)
- ✅ Container loglarını görme (`docker logs`)
- ✅ Container'ı interaktif modda çalıştırma
- ✅ Container içinde komut çalıştırma
- ✅ Debug tekniklerini kullanma

---

## 📝 ADIM 1: Container İçine Girme

### 1.1 Container'ı Arka Planda Çalıştırma

```bash
# Container'ı arka planda çalıştır (1 saat uyusun)
docker run -d --name debug-container actions-deneme sleep 3600
```

**Görev:**
- Container arka planda çalışacak
- "debug-container" isimli olacak

**Kontrol edin:**
```bash
docker ps
```

### 1.2 Çalışan Container İçine Girme

```bash
# Container içine bash ile gir
docker exec -it debug-container bash
```

**Görev:**
- Container içine gireceksiniz
- Artık container'ın içindesiniz!

**Container içinde şunları deneyin:**
```bash
# Mevcut dizini göster
pwd

# Dosyaları listele
ls -la

# Python versiyonunu kontrol et
python --version

# Yüklü paketleri gör
pip list

# Test dosyalarını gör
ls -la /app

# Python scriptini çalıştır
python hello.py

# Testleri çalıştır
pytest

# Çıkış yap
exit
```

**Görev:**
- Bu komutları container içinde çalıştırın
- Her birinin ne yaptığını anlayın

---

## 📝 ADIM 2: Container Loglarını Görme

### 2.1 Container'ı Çalıştırıp Logları Görme

```bash
# Container'ı çalıştır (loglar otomatik görünecek)
docker run --rm --name log-test actions-deneme
```

**Görev:**
- Container çalışırken loglar ekranda görünecek
- Test sonuçlarını göreceksiniz

### 2.2 Arka Planda Çalışan Container'ın Loglarını Görme

```bash
# Önce container'ı arka planda çalıştır
docker run -d --name log-container actions-deneme

# Logları görüntüle
docker logs log-container
```

**Görev:**
- Container arka planda çalıştığı için loglar ekranda görünmez
- `docker logs` ile logları görebilirsiniz

### 2.3 Canlı Log Takibi (Follow)

```bash
# Container'ı arka planda çalıştır (sürekli log üreten)
docker run -d --name follow-test actions-deneme sh -c "while true; do echo 'Test log $(date)'; sleep 2; done"

# Logları canlı takip et
docker logs -f follow-test
```

**Görev:**
- `-f` (follow) flag'i ile logları canlı takip edersiniz
- Ctrl+C ile çıkabilirsiniz

**Container'ı durdurun:**
```bash
docker stop follow-test
docker rm follow-test
```

---

## 📝 ADIM 3: Container İçinde Komut Çalıştırma

### 3.1 Tek Komut Çalıştırma

```bash
# Container içinde tek komut çalıştır (container içine girmeden)
docker exec debug-container ls -la /app
```

**Görev:**
- Container içine girmeden komut çalıştırabilirsiniz
- Sonuçları göreceksiniz

### 3.2 Farklı Komutlar Deneyin

```bash
# Python versiyonunu göster
docker exec debug-container python --version

# Yüklü paketleri listele
docker exec debug-container pip list

# Test dosyalarını göster
docker exec debug-container ls -la /app

# Python scriptini çalıştır
docker exec debug-container python hello.py

# Testleri çalıştır
docker exec debug-container pytest
```

**Görev:**
- Bu komutları tek tek çalıştırın
- Her birinin ne yaptığını anlayın

---

## 📝 ADIM 4: Interaktif Container Çalıştırma

### 4.1 Container'ı Interaktif Modda Çalıştırma

```bash
# Container'ı interaktif modda çalıştır (CMD komutunu override et)
docker run -it --rm actions-deneme bash
```

**Görev:**
- Container başladığında direkt bash açılacak
- CMD komutu (pytest) çalışmayacak

**Container içinde:**
```bash
# Dosyaları listele
ls -la

# Python scriptini çalıştır
python hello.py

# Testleri manuel çalıştır
pytest

# Çıkış yap
exit
```

### 4.2 Container'ı Farklı Komutla Çalıştırma

```bash
# Container'ı python komutuyla çalıştır
docker run --rm actions-deneme python hello.py

# Container'ı sh komutuyla çalıştır
docker run --rm actions-deneme sh -c "ls -la && pytest"
```

**Görev:**
- Container'ı farklı komutlarla çalıştırabilirsiniz
- CMD komutunu override edersiniz

---

## 📝 ADIM 5: Container Detaylarını İnceleme

### 5.1 Container Bilgilerini Görme

```bash
# Container detaylarını JSON formatında gör
docker inspect debug-container
```

**Görev:**
- Container hakkında tüm bilgileri göreceksiniz
- Çok fazla bilgi var, aşağıdaki komutlarla filtreleyin

### 5.2 Belirli Bilgileri Çıkarma

```bash
# Container ID
docker inspect debug-container --format='{{.Id}}'

# Container durumu
docker inspect debug-container --format='{{.State.Status}}'

# Container çalışma dizini
docker inspect debug-container --format='{{.Config.WorkingDir}}'

# Container'ın çalıştığı image
docker inspect debug-container --format='{{.Config.Image}}'

# Container'ın çalıştırdığı komut
docker inspect debug-container --format='{{.Config.Cmd}}'

# Container'ın environment variable'ları
docker inspect debug-container --format='{{.Config.Env}}'
```

**Görev:**
- Bu formatları kullanarak istediğiniz bilgiyi çıkarın

---

## 📝 ADIM 6: Container İçinde Dosya Oluşturma ve İnceleme

### 6.1 Container İçinde Dosya Oluşturma

```bash
# Container içine gir
docker exec -it debug-container bash

# Container içinde dosya oluştur
echo "Test dosyası" > /app/test-file.txt

# Dosyayı kontrol et
cat /app/test-file.txt

# Çıkış yap
exit
```

**Görev:**
- Container içinde dosya oluşturabilirsiniz
- Ancak container silindiğinde bu dosya da silinir (volume mount kullanmadıysanız)

### 6.2 Container İçindeki Dosyaları Kontrol Etme

```bash
# Container içindeki dosyaları listele
docker exec debug-container ls -la /app

# Container içindeki bir dosyanın içeriğini gör
docker exec debug-container cat /app/hello.py

# Container içindeki dosya boyutlarını gör
docker exec debug-container du -sh /app/*
```

**Görev:**
- Container içindeki dosyaları inceleyebilirsiniz

---

## 📝 ADIM 7: Debug Senaryosu

### Senaryo: Container'da bir sorun var, debug yapmanız gerekiyor

**Adımlar:**

1. **Container'ı çalıştırın:**
```bash
docker run -d --name problem-container actions-deneme
```

2. **Logları kontrol edin:**
```bash
docker logs problem-container
```

3. **Container durumunu kontrol edin:**
```bash
docker ps -a | grep problem-container
```

4. **Container içine girip inceleyin:**
```bash
docker exec -it problem-container bash
```

5. **Container içinde:**
```bash
# Dosyaları listele
ls -la

# Testleri çalıştır
pytest

# Python'u kontrol et
python --version

# Çıkış yap
exit
```

6. **Container'ı temizleyin:**
```bash
docker rm problem-container
```

**Görev:**
- Bu adımları takip ederek debug sürecini öğrenin

---

## ✅ ÖDEV KONTROL LİSTESİ

Ödevi tamamladınız mı? Aşağıdakileri kontrol edin:

- [+ ] `docker exec -it` ile container içine girebiliyorum
- [+ ] Container içinde komut çalıştırabiliyorum
- [+ ] `docker logs` ile logları görebiliyorum
- [+ ] `docker logs -f` ile canlı log takibi yapabiliyorum
- [+ ] `docker run -it` ile interaktif container çalıştırabiliyorum
- [+ ] `docker inspect` ile container detaylarını görebiliyorum
- [ +] Container içinde dosya oluşturup inceleyebiliyorum
- [ +] Debug senaryosunu tamamladım

---

## 🎯 PRATİK SENARYO

**Senaryo:** Bir container'da sorun olduğunu düşünün ve debug yapın.

**Adımlar:**
1. Container'ı arka planda çalıştırın
2. Logları kontrol edin
3. Container içine girin
4. Dosyaları inceleyin
5. Testleri çalıştırın
6. Sorunları tespit edin (eğer varsa)

---

## 📚 ÖĞRENDİĞİNİZ KOMUTLAR

| Komut | Açıklama |
|-------|----------|
| `docker exec -it <container> bash` | Container içine gir |
| `docker exec <container> <komut>` | Container içinde komut çalıştır |
| `docker logs <container>` | Container loglarını gör |
| `docker logs -f <container>` | Logları canlı takip et |
| `docker run -it` | Interaktif modda container çalıştır |
| `docker inspect <container>` | Container detaylarını göster |

---

## 🎓 SONRAKI ADIM

Ödev 2'yi tamamladıysanız, **ÖDEV 3: Volume Mount** (`ODEV3_VOLUME_MOUNT.md`) dosyasına geçin!

Başarılar! 🎉

