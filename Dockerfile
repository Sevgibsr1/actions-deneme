# ============================================
# DOCKERFILE - ADIM ADIM AÇIKLAMA
# ============================================
# Dockerfile, bir Docker image'ını nasıl oluşturacağınızı tarif eden bir dosyadır.
# Image: Container'ın şablonu (kalıbı)
# Container: Image'dan çalışan bir örnek (instance)

# 1️⃣ BASE IMAGE SEÇİMİ
# ------------------------
# FROM: Hangi temel image'ı kullanacağımızı belirtir
# python:3.10-slim: Python 3.10'un resmi, hafif versiyonu
# - python:3.10 (tam versiyon - daha büyük)
# - python:3.10-slim (hafif versiyon - daha küçük, tavsiye edilir)
# - python:3.10-alpine (en küçük, ama bazen sorun çıkarabilir)
FROM python:3.10-slim

# 2️⃣ ÇALIŞMA DİZİNİ (WORKING DIRECTORY)
# ------------------------
# WORKDIR: Container içinde komutların çalışacağı klasörü belirler
# /app klasörü yoksa otomatik oluşturulur
WORKDIR /app

# 3️⃣ DOSYA KOPYALAMA
# ------------------------
# COPY: Host makinemizden (bilgisayarımızdan) container'a dosya kopyalar
# COPY <kaynak> <hedef>
# COPY . .        -> Şu anki klasördeki TÜM dosyaları /app klasörüne kopyala
# COPY hello.py . -> Sadece hello.py dosyasını kopyala
# .dockerignore dosyası oluşturursanız, istenmeyen dosyalar kopyalanmaz
COPY . .

# 4️⃣ BAĞIMLILIKLARI YÜKLEME
# ------------------------
# RUN: Image oluşturulurken çalıştırılacak komutlar
# --no-cache-dir: Cache kullanma, daha temiz build
# pip install: Python paketlerini yükler
RUN pip install --no-cache-dir pytest pytest-cov flake8

# 5️⃣ VARSayıLAN KOMUT (DEFAULT COMMAND)
# ------------------------
# CMD: Container başlatıldığında otomatik çalışacak komut
# ["pytest", "--maxfail=1", "--disable-warnings", "-q"]
# - pytest: Test framework'ü çalıştır
# - --maxfail=1: İlk hatada dur
# - --disable-warnings: Uyarıları gösterme
# - -q: Sessiz mod (quiet)
# NOT: docker run sırasında farklı komut verirseniz, bu komut geçersiz olur
CMD ["pytest", "--maxfail=1", "--disable-warnings", "-q"]
