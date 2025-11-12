# 🐳 Docker Image'ı Docker Desktop'ta Görme ve Çalıştırma Rehberi

## 📋 Adım Adım İşlemler

### 1️⃣ GitHub Container Registry'ye Giriş Yapın

**İlk kez yapıyorsanız:**

GitHub Personal Access Token (PAT) oluşturun:
1. GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. "Generate new token (classic)" tıklayın
3. Token'a bir isim verin (örn: "Docker GHCR")
4. **`read:packages`** iznini seçin
5. "Generate token" tıklayın
6. Token'ı kopyalayın (bir daha gösterilmeyecek!)

**Terminal'de giriş yapın:**

```bash
# Windows PowerShell veya WSL'de
echo "GITHUB_TOKEN_BURAYA" | docker login ghcr.io -u KULLANICI-ADI --password-stdin
```

**Örnek:**
```bash
echo "ghp_xxxxxxxxxxxxxxxxxxxx" | docker login ghcr.io -u sevgi-bsr --password-stdin
```

✅ Başarılı olursa: `Login Succeeded` mesajı görürsünüz.

---

### 2️⃣ Image'ı Çekin (Pull)

**Terminal'de çalıştırın:**

```bash
docker pull ghcr.io/KULLANICI-ADI/REPO-ADI:latest
```

**Gerçek örnek (sizin durumunuz için):**
```bash
docker pull ghcr.io/sevgi-bsr/actions-deneme:latest
```

✅ Başarılı olursa: Image indirilir ve Docker Desktop'ta görünür.

---

### 3️⃣ Docker Desktop'ta Görüntüleme

1. **Docker Desktop'ı açın**
2. Sol menüden **"Images"** sekmesine tıklayın
3. `ghcr.io/sevgi-bsr/actions-deneme:latest` image'ını listede göreceksiniz
4. Image'ın sağında:
   - **"Run"** butonu → Container'ı çalıştırır
   - **"..." (üç nokta)** → Daha fazla seçenek (Delete, Push, etc.)

---

### 4️⃣ Image'ı Çalıştırma

**Yöntem 1: Docker Desktop'tan (Kolay)**
1. Images sekmesinde image'ınızı bulun
2. **"Run"** butonuna tıklayın
3. İsteğe bağlı olarak container ayarlarını yapın
4. **"Run"** tıklayın

**Yöntem 2: Terminal'den (Hızlı)**

```bash
# Basit çalıştırma (test için)
docker run --rm ghcr.io/sevgi-bsr/actions-deneme:latest

# Container içine girme (inceleme için)
docker run -it --rm ghcr.io/sevgi-bsr/actions-deneme:latest bash
```

---

## ✅ Hızlı Kontrol Listesi

```bash
# 1. Giriş yap (sadece ilk kez)
echo "TOKEN" | docker login ghcr.io -u KULLANICI-ADI --password-stdin

# 2. Image'ı çek
docker pull ghcr.io/sevgi-bsr/actions-deneme:latest

# 3. Image'ları listele (kontrol için)
docker images ghcr.io/sevgi-bsr/actions-deneme

# 4. Container çalıştır
docker run --rm ghcr.io/sevgi-bsr/actions-deneme:latest
```

---

## 🔍 Sorun Giderme

### "unauthorized: authentication required" hatası
- GitHub Container Registry'ye giriş yapmadınız
- Token'ı kontrol edin: `read:packages` izni olmalı

### "manifest unknown: repository name not found" hatası
- Image adını kontrol edin (büyük/küçük harf duyarlı)
- GitHub Actions workflow'un başarıyla tamamlandığından emin olun

### Image Docker Desktop'ta görünmüyor
- `docker pull` komutunu çalıştırdınız mı?
- `docker images` komutuyla kontrol edin
- Docker Desktop'ı yeniden başlatın

---

## 📝 Özet

**Sıralama:**
1. ✅ `docker login ghcr.io` (giriş yap)
2. ✅ `docker pull ghcr.io/sevgi-bsr/actions-deneme:latest` (image çek)
3. ✅ Docker Desktop → Images sekmesinde görüntüle
4. ✅ "Run" butonuyla veya `docker run` komutuyla çalıştır

**Önemli:** `docker pull` yapmadan Docker Desktop'ta image görünmez! Pull işlemi image'ı GitHub Container Registry'den lokal bilgisayarınıza indirir.

