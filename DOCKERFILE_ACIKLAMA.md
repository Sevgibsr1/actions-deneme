# 🐳 Dockerfile Kullanım Kılavuzu

Bu proje **multi-stage** Dockerfile kullanır ve iki farklı uygulama için build yapabilir.

## 📦 Build Seçenekleri

### 1. Hello Uygulaması (Varsayılan)
Basit `hello.py` uygulamasını çalıştırır:

```bash
docker build -t actions-deneme:hello --target hello-runtime .
docker run --rm actions-deneme:hello
```

### 2. Web Uygulaması (Flask)
Flask web uygulamasını çalıştırır:

```bash
docker build -t actions-deneme:web --target web-runtime .
docker run --rm -p 5000:5000 \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  actions-deneme:web
```

## 🏗️ Stage Yapısı

### Stage 1: Builder
- Test araçları kurulumu (pytest, flake8)
- Test çalıştırma
- Cache kullanımı ile optimize edilmiş

### Stage 2: Hello Runtime
- Minimal Python runtime
- Sadece `hello.py` dosyası
- Hafif ve hızlı

### Stage 3: Web Runtime
- Flask ve Redis bağımlılıkları
- Non-root kullanıcı ile çalışır
- Production-ready yapılandırma
- Python 3.12 tabanında hem multi-stage Dockerfile hem de `web/Dockerfile` senkronize çalışır

## 📝 Docker Compose ile Kullanım

`docker-compose.yml` dosyası zaten `web-runtime` stage'ini kullanır:

```yaml
web:
  build:
    context: .
    dockerfile: Dockerfile
    target: web-runtime  # Web uygulaması için
```

## 🔧 Environment Variables

### Web Uygulaması için:
- `REDIS_HOST`: Redis sunucu adresi (varsayılan: redis)
- `REDIS_PORT`: Redis port (varsayılan: 6379)
- `REDIS_DB`: Redis veritabanı numarası (varsayılan: 0)
- `REDIS_PASSWORD`: Redis şifresi (opsiyonel)
- `COUNTER_KEY`: Sayaç anahtarı (varsayılan: visits)
- `FLASK_RUN_HOST`: Flask host (varsayılan: 0.0.0.0)
- `FLASK_RUN_PORT`: Flask port (varsayılan: 5000)

## 🚀 Örnek Kullanımlar

### Development
```bash
# Web uygulamasını build et
docker build -t myapp:web --target web-runtime .

# Redis ile birlikte çalıştır
docker-compose up
```

### Production
```bash
# Production için optimize build
docker build --target web-runtime \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  -t myapp:web .
```

## 📚 İlgili Dosyalar

- `Dockerfile`: Ana multi-stage Dockerfile
- `web/Dockerfile`: Web uygulaması için özel Dockerfile (docker-compose için)
- `docker-compose.yml`: Multi-container yapılandırması
- `hello.py`: Basit Python uygulaması
- `web/app.py`: Flask web uygulaması

