#
# syntax=docker/dockerfile:1.7-labs
#
# ÖDEV 4 için optimize Dockerfile:
# - BuildKit cache kullanımı
# - Multi-stage: builder (test/deps) + runtime (minimal)
# - .dockerignore ile gereksiz dosyaları dışarıda bırakma
#

# =========================
# 1) BUILDER (dev/test)
# =========================
FROM python:3.12-slim AS builder
WORKDIR /app

# Sık değişmeyen: test araçları (cache dostu)
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir pytest pytest-cov flake8

# Uygulama kodu (daha sık değişir)
COPY . .

# (İsteğe bağlı) Hızlı doğrulama: testler varsa çalıştır
# Test dosyanız yoksa bu komut başarısız olmasın diye '|| true' ekliyoruz
RUN pytest --maxfail=1 --disable-warnings -q || true

# =========================
# 2) RUNTIME (production)
# =========================
FROM python:3.12-slim AS runtime
WORKDIR /app

# Sadece gereken uygulama dosyalarını kopyalayın (çakışma riskini azaltın)
COPY hello.py .

# Üretim için varsayılan komut
CMD ["python", "hello.py"]
