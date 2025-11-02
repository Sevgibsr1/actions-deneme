# 1️⃣ Python tabanlı bir image’tan başla
FROM python:3.10-slim

# 2️⃣ Çalışma dizinini oluştur
WORKDIR /app

# 3️⃣ Projedeki tüm dosyaları container içine kopyala
COPY . .

# 4️⃣ Gerekli kütüphaneleri yükle
RUN pip install --no-cache-dir pytest pytest-cov flake8

# 5️⃣ Test komutunu çalıştırıır
CMD ["pytest", "--maxfail=1", "--disable-warnings", "-q"]
