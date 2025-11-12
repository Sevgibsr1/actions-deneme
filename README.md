## Çok Servisli Compose Yapısı

Bu repo, `web` (Flask) + `redis` + (opsiyonel) `nginx` servislerinden oluşur.

### Dizin Yapısı

```
.
├── web/                 # Flask web uygulaması
│   ├── app.py          # Ana uygulama dosyası
│   ├── requirements.txt
│   └── Dockerfile      # Web için özel Dockerfile
├── nginx/               # (opsiyonel) Reverse proxy
│   ├── nginx.conf
│   └── Dockerfile
├── k8s/                 # Kubernetes manifestleri
│   ├── 03-config/      # ConfigMap ve Secret
│   ├── 04-scaling/     # Deployment ve HPA
│   ├── 05-ingress/     # Ingress yapılandırmaları
│   ├── 06-storage/      # PVC ve StatefulSet
│   ├── 08-security/     # RBAC ve NetworkPolicy
│   └── 11-chaos/       # Chaos Engineering
├── docker-compose.yml   # Multi-container yapılandırması
├── Dockerfile           # Multi-stage Dockerfile (hello + web)
└── README.md
```

### Dockerfile Kullanımı

Bu proje **multi-stage** Dockerfile kullanır. İki farklı uygulama için build yapabilirsiniz:

**Hello Uygulaması (Basit):**
```bash
docker build -t actions-deneme:hello --target hello-runtime .
docker run --rm actions-deneme:hello
```

**Web Uygulaması (Flask):**
```bash
docker build -t actions-deneme:web --target web-runtime .
docker run --rm -p 5000:5000 \
  -e REDIS_HOST=redis \
  -e REDIS_PORT=6379 \
  actions-deneme:web
```

Detaylı bilgi için: [DOCKERFILE_ACIKLAMA.md](DOCKERFILE_ACIKLAMA.md)

### Ortam Değişkenleri

Bir `.env` dosyası oluşturun (repo kök dizininde) ve aşağıdaki değişkenleri ekleyin:

```
WEB_PORT=5000
REDIS_HOST=redis
REDIS_PORT=6379
APP_ENV=production
COUNTER_KEY=visits
```

> Not: Bazı ortamlarda gizli dosyalar (.`*`) otomatik ignore edilebilir. Dosyayı elinizle oluşturup içerikleri kopyalayın.

### Çalıştırma

Görüntüleri oluşturup başlatın:

```bash
docker compose up -d --build
```

Logları izleyin:

```bash
docker compose logs -f
```

### Test

- Nginx ile:
  - Health: `curl http://localhost/health`
  - Sayaç: `curl http://localhost/counter`
- Nginx olmadan (web servisi doğrudan container içinde 5000 portunda):
  - Health: `curl http://localhost:5000/health`
  - Sayaç: `curl http://localhost:5000/counter`

Sayaç kalıcılığı için `redis_data` volume kullanılır. `docker compose restart redis` sonrası sayaç kaldığı yerden devam etmelidir.

### Ölçeklendirme

```bash
docker compose up -d --scale web=3
```

Nginx aktifleştirildiğinde istekler replikalara dağıtılır.


