## 🧩 ÖDEV 6: Docker Compose ile Çok Servisli Yapı

Bu ödevde, birden fazla servisten oluşan bir uygulamayı Docker Compose kullanarak ayağa kaldıracak, servisler arası iletişimi yönetecek, verileri kalıcılaştıracak ve ölçekleme/sağlık kontrolü gibi yetenekleri uygulayacaksınız.

---

### 🎯 Hedefler
- Docker Compose kavramlarını uygulamak: services, networks, volumes, depends_on, env_file
- Servisler arası iletişim ve bağımlılık yönetimi
- Kalıcı veri yönetimi (volumes)
- Sağlık kontrolleri ve başlatma sırası
- Ölçekleme ve log/metric takibi

---

### 📦 Proje Senaryosu
Basit bir web API’si (`web`) Redis’i önbellek olarak (`redis`) kullanacak. İsteğe bağlı olarak bir ters proxy (`nginx`) ekleyebilirsiniz. Web servisi, ziyaret sayısını Redis’te tutacak ve bir endpoint üzerinden gösterecek.

Mimari:

```
[client] → [nginx:80] → [web:5000] ↔ [redis:6379]
```

`nginx` zorunlu değildir; ek puan için ekleyebilirsiniz.

---

### 🧱 Dizin Yapısı (Önerilen)

```
.
├── web/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── nginx/               (opsiyonel)
│   ├── nginx.conf
│   └── Dockerfile
├── .env
├── docker-compose.yml
└── README.md
```

---

### 🛠️ Yapılacaklar

1) Web servisini hazırlayın
- `web/app.py`: Flask (veya FastAPI) ile basit API
  - GET `/` → “OK”
  - GET `/counter` → Redis’te sayaç artır ve değeri döndür
- `web/requirements.txt`: ör. `flask`, `redis`
- `web/Dockerfile`:
  - Küçük taban imaj (ör. `python:3.11-slim`)
  - Non-root kullanıcı ile çalıştırma
  - `pip install -r requirements.txt`
  - `FLASK_APP=app.py` ve `FLASK_RUN_HOST=0.0.0.0`
  - `EXPOSE 5000`

2) Redis servisini ekleyin
- `redis` imajını resmi Docker Hub’dan kullanın (`redis:7-alpine` gibi)
- Persist etmek için named volume bağlayın (ör. `redis_data:/data`)
- Sağlık kontrolü ekleyin (örn. `redis-cli ping`)

3) (Opsiyonel) Nginx reverse proxy
- `nginx/nginx.conf`: `web` servisine proxy geçecek şekilde ayarlayın
- `nginx/Dockerfile`: resmi `nginx:alpine` taban alın; conf dosyasını kopyalayın
- `nginx` 80 portunu host’a yayın

4) docker-compose.yml oluşturun
- En az şu özellikler olmalı:
  - `services: web, redis` (opsiyonel `nginx`)
  - Ortak bir `bridge` network
  - `depends_on` ile başlatma sırası
  - `healthcheck` (en az redis için; ek puan için web/nginx için de)
  - `env_file: .env` ve/veya `environment:` blokları
  - `volumes:` tanımı (ör. `redis_data:`)
  - `restart` politikası (`unless-stopped` veya `on-failure`)
  - `logging` sürücüsü ve seçenekleri (örn. `json-file` max-size)

5) .env dosyası
- Örnek değişkenler:
  - `WEB_PORT=5000`
  - `REDIS_HOST=redis`
  - `REDIS_PORT=6379`
  - `APP_ENV=production` (veya `development`)

6) Ölçekleme
- `web` servisini 2 veya 3 replika ile çalıştırın
- Nginx kullanıyorsanız `upstream` ile yük dengeleme yapın
- Nginx yoksa host port mapping yerine Compose iç ağı üzerinden test edebilirsiniz

7) Sağlık kontrolleri
- Redis: `CMD ["redis-cli","ping"]` → `PONG` beklenmeli
- Web: basit bir `curl http://localhost:5000/health` benzeri endpoint ile `200` döndürün
- `depends_on` ile `condition: service_healthy` kullanın (Compose v3.9+ davranışlarına dikkat edin)

8) Log ve gözlemleme
- `docker compose logs -f` ile log akışını inceleyin
- Ek puan: Basit bir metrik endpoint’i (`/metrics`) veya istek sayısı log’u

---

### 🧪 Kabul Kriterleri
- `docker-compose.yml` valid ve `docker compose up -d` ile sorunsuz ayağa kalkıyor
- `web` servisi Redis’e bağlanabiliyor, `/counter` endpoint’i artan sayı döndürüyor
- Kalıcı veri: Container yeniden başlatıldığında sayaç kaldığı yerden devam ediyor
- Sağlık kontrolleri ve `depends_on` doğru çalışıyor
- Ölçekleme: `web` en az 2 replika ile çalıştırılabiliyor
- (Opsiyonel) Nginx üzerinden istekler `web` replikalarına dağıtılıyor

---

### ▶️ Çalıştırma Komutları

Görüntüleri oluşturup başlatma:

```bash
docker compose up -d --build
```

Logları izleme:

```bash
docker compose logs -f
```

Servisleri listeleme:

```bash
docker compose ps
```

Ölçeklendirme (ör. web’i 3 replika yap):

```bash
docker compose up -d --scale web=3
```

Servisleri durdurma ve kaldırma (volumes korunur):

```bash
docker compose down
```

Tüm kaynakları (volumes dahil) temizleme:

```bash
docker compose down -v
```

---

### 🧭 Test Adımları
1) `docker compose up -d --build`
2) `docker compose ps` ile health durumlarını kontrol et
3) Web’e istek at:
   - Nginx varsa: `curl http://localhost/`
   - Yoksa: `curl http://localhost:5000/`
4) Sayaç testi: Aynı endpoint’e birden çok kez istek at
   - `curl http://localhost/counter` veya `curl http://localhost:5000/counter`
5) Container’ı yeniden başlat:
   - `docker compose restart redis`
   - Sayaç kaldığı yerden devam etmeli
6) Ölçekleme testi:
   - `docker compose up -d --scale web=3`
   - Nginx ile birden fazla istekte farklı backend’lere yönlenmeyi gözlemleyin

---

### 📝 Teslimat
- Commit’lerde aşağıdaki dosyalar bulunmalı:
  - `docker-compose.yml`
  - `web/app.py`, `web/requirements.txt`, `web/Dockerfile`
  - `.env` (sensitive olmayan örnek değerlerle)
  - (Opsiyonel) `nginx/nginx.conf`, `nginx/Dockerfile`
  - `README.md` (çalıştırma talimatları ve açıklamalar)

---

### 💡 İpuçları
- Compose’ta servis isimleri DNS olarak çözümlenir: `redis:6379`
- Healthcheck süreleri için `interval`, `timeout`, `retries`, `start_period` ayarlarını kullanın
- Web uygulamasında bağlantı hataları için yeniden deneme (retry/backoff) eklemek stabiliteyi artırır
- Geliştirme ortamında kaynak kullanımını düşük tutmak için `alpine` veya `-slim` imajları tercih edin

---

### 🎓 Sonraki Adım
Bu ödevi tamamladıysanız, log yönetimi ve gözlemleme ekosistemi içeren bir sonraki ödeve geçebilirsiniz (ör. Prometheus + Grafana ile temel metrikler).

Başarılar! 🚀


