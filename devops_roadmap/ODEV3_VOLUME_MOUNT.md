# 📋 ÖDEV 3: Volume Mount - Dosya Paylaşımı

## 🎯 Öğrenme Hedefleri

Bu ödevi tamamladığınızda:
- ✅ Volume mount kavramını anlama
- ✅ Host-Container dosya paylaşımı
- ✅ Bind mount kullanımı
- ✅ Named volume kullanımı
- ✅ Live reload geliştirme

---

## 📝 KAVRAM: Volume Mount Nedir?

**Volume Mount:** Host makinemizdeki (bilgisayarımızdaki) bir klasörü container içindeki bir klasöre bağlamak.

**Neden Kullanılır?**
- ✅ Geliştirme sırasında kod değişikliklerini anında görmek
- ✅ Container içindeki verileri host'ta saklamak
- ✅ Dosya paylaşımı yapmak

---

## 📝 ADIM 1: Bind Mount - Basit Dosya Paylaşımı

### 1.1 Host'tan Container'a Dosya Paylaşımı

**Önce test için bir dosya oluşturun:**
```bash
# Proje klasöründe test dosyası oluştur
echo "Bu dosya host'tan geliyor!" > test-volume.txt
```

**Şimdi container'ı volume mount ile çalıştırın:**
```bash
# Container'ı volume mount ile çalıştır
docker run -it --rm \
  -v $(pwd):/app \
  actions-deneme bash
```

**Açıklama:**
- `-v $(pwd):/app` → Şu anki klasörü (`$(pwd)`) container'ın `/app` klasörüne bağla
- `$(pwd)` → Windows PowerShell'de `pwd` yerine `$PWD` kullanın
- Veya WSL'de: `$(pwd)` çalışır

**⚠️ Windows PowerShell için:**
```powershell
# PowerShell'de
docker run -it --rm -v ${PWD}:/app actions-deneme bash
```

**Container içinde:**
```bash
# Dosyayı kontrol et
ls -la /app/test-volume.txt

# Dosyanın içeriğini gör
cat /app/test-volume.txt

# Container içinde dosya oluştur
echo "Container'dan yazıldı" > /app/test-container.txt

# Çıkış yap
exit
```

**Host'ta kontrol edin:**
```bash
# Host'ta dosyayı kontrol et
cat test-container.txt
```

**Görev:**
- Container içinde oluşturduğunuz dosya host'ta görünmeli
- Host'taki değişiklikler container içinde görünmeli

---

## 📝 ADIM 2: Read-Only Mount

### 2.1 Dosyaları Sadece Okuma Modunda Mount Etme

```bash
# Container'ı read-only mount ile çalıştır
docker run -it --rm \
  -v $(pwd):/app:ro \
  actions-deneme bash
```

**Açıklama:**
- `:ro` → Read-only (sadece okuma)
- Container içinde dosya değiştiremezsiniz

**Container içinde deneyin:**
```bash
# Dosyayı okuyabilirsiniz
cat /app/hello.py

# Ama yazamazsınız (hata verecek)
echo "Test" > /app/test.txt
```

**Görev:**
- Read-only mount ile container dosyaları okuyabilir ama yazamaz

---

## 📝 ADIM 3: Belirli Dosyaları Mount Etme

### 3.1 Tek Dosyayı Mount Etme

```bash
# Sadece hello.py dosyasını mount et
docker run -it --rm \
  -v $(pwd)/hello.py:/app/hello.py \
  actions-deneme bash
```

**Container içinde:**
```bash
# Dosyayı gör
cat /app/hello.py

# Dosyayı değiştir
echo "Yeni içerik" > /app/hello.py

# Çıkış yap
exit
```

**Host'ta kontrol edin:**
```bash
cat hello.py
```

**Görev:**
- Sadece belirli dosyaları mount edebilirsiniz

---

## 📝 ADIM 4: Live Reload Geliştirme

### 4.1 Kod Değişikliklerini Anında Görme

**Önce bir test scripti oluşturun:**
```bash
# test_live.py dosyası oluştur
cat hello.py

```

**Container'ı volume mount ile çalıştırın:**
```bash
# Container'ı volume mount ile çalıştır
docker run -it --rm \
  -v $(pwd):/app \
  actions-deneme bash
```

**Container içinde:**
```bash
# Test dosyasını çalıştır
pytest test_live.py -v
```

**Şimdi host'ta dosyayı değiştirin:**
```bash
# Host'ta test_live.py'yi değiştir
echo 'def test_live():
    print("YENİ İÇERİK!")
    assert True' > test_live.py
```

**Container içinde tekrar çalıştırın:**
```bash
# Container içinde (hala çalışıyorsa)
pytest test_live.py -v
```

**Görev:**
- Host'taki değişiklikler container içinde anında görünmeli

---

## 📝 ADIM 5: Named Volume Kullanımı

### 5.1 Named Volume Oluşturma

```bash
# Named volume oluştur
docker volume create my-data
```

**Volume'u görüntüleyin:**
```bash
# Volume'ları listele
docker volume ls

# Volume detaylarını gör
docker volume inspect my-data
```

### 5.2 Named Volume Kullanma

```bash
# Container'ı named volume ile çalıştır
docker run -it --rm \
  -v my-data:/data \
  actions-deneme bash
```

**Container içinde:**
```bash
# /data klasörüne dosya oluştur
echo "Bu dosya named volume'da" > /data/test.txt

# Dosyayı kontrol et
cat /data/test.txt

# Çıkış yap
exit
```

**Container'ı yeniden çalıştırın (aynı volume ile):**
```bash
# Yeni container, aynı volume
docker run -it --rm \
  -v my-data:/data \
  actions-deneme bash
```

**Container içinde:**
```bash
# Dosya hala orada!
cat /data/test.txt
```

**Görev:**
- Named volume'lar container'lar arasında veri paylaşımı sağlar
- Container silinse bile veriler kalır

---

## 📝 ADIM 6: Volume Temizleme

### 6.1 Named Volume Silme

```bash
# Named volume'u sil
docker volume rm my-data
```

**Görev:**
- Artık kullanılmayan volume'ları silebilirsiniz

### 6.2 Kullanılmayan Volume'ları Temizleme

```bash
# Kullanılmayan volume'ları temizle
docker volume prune
```

**Görev:**
- Tüm kullanılmayan volume'lar silinecek

---

## 📝 ADIM 7: Pratik Senaryo - Geliştirme Ortamı

### Senaryo: Python uygulamanızı geliştirirken container kullanın

**Adımlar:**

1. **Container'ı volume mount ile çalıştırın:**
```bash
docker run -it --rm \
  -v $(pwd):/app \
  -w /app \
  actions-deneme bash
```

**Açıklama:**
- `-w /app` → Working directory'yi /app olarak ayarla

2. **Container içinde geliştirme yapın:**
```bash
# Testleri çalıştır
pytest

# Yeni test dosyası oluştur
echo 'def test_new():
    assert 1 + 1 == 2' > test_new.py

# Testleri tekrar çalıştır
pytest
```

3. **Host'ta dosyaları düzenleyin:**
```bash
# Host'ta test_new.py'yi düzenleyin
# Container içinde değişiklikler anında görünecek
```

4. **Container içinde değişiklikleri test edin:**
```bash
# Container içinde (hala çalışıyorsa)
pytest
```

**Görev:**
- Bu senaryoyu tamamlayarak geliştirme workflow'unu öğrenin

---

## 📝 ADIM 8: Environment Variable ile Volume Mount

### 8.1 Environment Variable Kullanımı

```bash
# Environment variable ile volume mount
export MY_PATH=$(pwd)

docker run -it --rm \
  -v $MY_PATH:/app \
  -e PYTHONPATH=/app \
  actions-deneme bash
```

**Açıklama:**
- `-e PYTHONPATH=/app` → Environment variable set et
- Container içinde bu değişken kullanılabilir

**Container içinde:**
```bash
# Environment variable'ı kontrol et
echo $PYTHONPATH

# Çıkış yap
exit
```

---

## ✅ ÖDEV KONTROL LİSTESİ

Ödevi tamamladınız mı? Aşağıdakileri kontrol edin:

- [+ ] `-v` flag'i ile bind mount yapabiliyorum
- [ +] Host-Container dosya paylaşımı yapabiliyorum
- [ +] Read-only mount (`:ro`) kullanabiliyorum
- [ +] Belirli dosyaları mount edebiliyorum
- [ +] Named volume oluşturup kullanabiliyorum
- [ +] Live reload geliştirme yapabiliyorum
- [ +] Volume temizleme yapabiliyorum

---

## 🎯 PRATİK SENARYO

**Senaryo:** Geliştirme ortamınızı container ile kurun.

**Adımlar:**
1. Container'ı volume mount ile çalıştırın
2. Host'ta kod yazın
3. Container içinde testleri çalıştırın
4. Host'taki değişikliklerin container'da göründüğünü doğrulayın

---

## 📚 ÖĞRENDİĞİNİZ KOMUTLAR

| Komut | Açıklama |
|-------|----------|
| `docker run -v $(pwd):/app` | Host klasörünü container'a mount et |
| `docker run -v $(pwd):/app:ro` | Read-only mount |
| `docker volume create <isim>` | Named volume oluştur |
| `docker volume ls` | Volume'ları listele |
| `docker volume rm <isim>` | Volume sil |
| `docker volume prune` | Kullanılmayan volume'ları temizle |

---

## 💡 İPUÇLARI

1. **Windows PowerShell:** `$(pwd)` yerine `${PWD}` kullanın
2. **WSL:** `$(pwd)` çalışır
3. **Path'ler:** Mutlak path kullanmak daha güvenli
4. **Read-only:** Production'da güvenlik için önemli
5. **Named volumes:** Veri kalıcılığı için kullanın

---

## 🎓 SONRAKI ADIM

Ödev 3'ü tamamladıysanız, **ÖDEV 4: .dockerignore ve Optimizasyon** (`ODEV4_DOCKERIGNORE.md`) dosyasına geçin!

Başarılar! 🎉

