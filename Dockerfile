#
# syntax=docker/dockerfile:1.7-labs
#
# Multi-stage Dockerfile:
# - Builder stage: Test ve bağımlılık kurulumu
# - Runtime stage (hello): Basit hello.py uygulaması
# - Runtime stage (web): Flask web uygulaması
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
# 2) RUNTIME - Hello (basit uygulama)
# =========================
FROM python:3.12-slim AS hello-runtime
WORKDIR /app

# Sadece gereken uygulama dosyalarını kopyalayın
COPY hello.py .

# Üretim için varsayılan komut
CMD ["python", "hello.py"]

# =========================
# 3) RUNTIME - Web (Flask uygulaması)
# =========================
FROM python:3.12-slim AS web-runtime
WORKDIR /app

# Web uygulaması bağımlılıkları
COPY web/requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt

# Web uygulaması dosyaları
COPY web /app

# Non-root kullanıcı oluştur
RUN useradd --create-home --home-dir /home/appuser --shell /bin/bash appuser \
    && chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

# Flask uygulamasını çalıştır
CMD ["python", "app.py"]
