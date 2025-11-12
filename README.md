## Çok Servisli Compose Yapısı

Bu repo, `web` (Flask) + `redis` + (opsiyonel) `nginx` servislerinden oluşur.

### Dizin Yapısı

```
.
├── web/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
├── nginx/               (opsiyonel)
│   ├── nginx.conf
│   └── Dockerfile
├── docker-compose.yml
└── README.md
```

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


