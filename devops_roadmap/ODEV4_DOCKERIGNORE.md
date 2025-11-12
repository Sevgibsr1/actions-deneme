# ÖDEV 4: .dockerignore ve İmaj Optimizasyonu

Bu ödevde `.dockerignore` dosyasını doğru kullanmayı, imaj boyutunu küçültmeyi, cache (önbellek) katmanlarını etkili kullanmayı ve çok-aşamalı (multi-stage) build ile üretim için optimize edilmiş imajlar üretmeyi öğreneceksiniz.

---

## 1) .dockerignore nedir? Neden önemli?

`.dockerignore`, `docker build` sırasında build context'e dahil edilmesini istemediğiniz dosya ve klasörleri dışarıda bırakır. Böylece:
- **Daha küçük build context**: Daha hızlı upload, daha hızlı build.
- **Daha etkili cache**: Gereksiz değişiklikler cache'i bozmaz.
- **Daha güvenli imaj**: Gizli dosyalar ve gereksiz içerikler imaja taşınmaz.

Temel yazım Git `.gitignore` ile benzerdir. Örnek kalıplar:
- `node_modules/`, `.venv/`, `.pytest_cache/`, `.DS_Store`
- `*.log`, `*.tmp`, `!keep.file` (negation)

> İpucu: Build context'i görmek için `docker buildx build --no-cache --progress=plain .` çıktılarını inceleyebilirsiniz.

---

## 2) Projeniz için örnek `.dockerignore` kalıpları

Aşağıdaki şablonlardan ihtiyacınız olanları seçip uyarlayın.

Genel (dil bağımsız) öneriler:
```
.git
.gitignore
.env
.env.*
*.log
*.tmp
*.swp
.DS_Store
**/__pycache__/
**/*.py[cod]
**/.pytest_cache/
**/.mypy_cache/
**/.ruff_cache/
.idea
.vscode

# Docker artefacts
docker-compose*.yml

# Build outputs
dist
build

# Virtual envs
.venv/
venv/

# Caches
*.cache
```

Python projeleri için ek öneriler:
```
pip-wheel-metadata/
pip-cache/
site-packages/
poetry.lock  # (Tercihe göre dahil/dahil etme; cache davranışını etkiler)
```

Node.js projeleri için ek öneriler:
```
node_modules/
npm-debug.log*
yarn-error.log*
.pnpm-store/
```

---

## 3) Katman (layer) ve cache stratejisi

Docker katmanları değişmeyen adımları cache'den çeker. Bu yüzden:
- **Sık değişmeyen adımları önce** (örn: bağımlılıkların kurulumu).
- **Sık değişen dosyaları en sona** (örn: uygulama kaynak kodu).
- `COPY` ve `RUN` sırasını bu mantığa göre düzenleyin.

Örnek (Python):
```Dockerfile
FROM python:3.12-slim AS base
WORKDIR /app

# 1) Bağımlılık manifest'lerini önce kopyala (cache dostu)
COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip install --no-cache-dir -r requirements.txt

# 2) Uygulama kodunu sonra kopyala
COPY . .

CMD ["python", "hello.py"]
```

> Not: `--mount=type=cache` BuildKit ile çalışır. `DOCKER_BUILDKIT=1` ayarlı olduğundan emin olun.

---

## 4) Çok-aşamalı (multi-stage) build ile üretim imajı

Geliştirme aşamasında derleme araçlarına ihtiyaç duyabilirsiniz; fakat üretimde minimalist bir imaj tercih edilir. Multi-stage build ile bu mümkün.

Python örneği (derleme adımı + ince üretim imajı):
```Dockerfile
# 1) Builder aşaması
FROM python:3.12-slim AS builder
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends build-essential \
 && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN --mount=type=cache,target=/root/.cache/pip \
    pip wheel --no-cache-dir --wheel-dir=/wheels -r requirements.txt

COPY . .

# 2) Runtime (üretim) aşaması
FROM python:3.12-slim AS runtime
WORKDIR /app

# Yalnızca gerekenleri kopyala
COPY --from=builder /wheels /wheels
RUN pip install --no-cache-dir /wheels/*

COPY --from=builder /app .

CMD ["python", "hello.py"]
```

Avantajlar:
- Üretim imajında derleme araçları yok → daha az boyut, daha az yüzey.
- Cache verimli kullanılır → daha hızlı build.

---

## 5) İmaj boyutunu küçültme ipuçları

- **Daha küçük taban imaj**: `-slim`, `-alpine` (uyumluluğu kontrol edin).
- **Gereksiz paketleri kaldırın** ve apt cache temizleyin.
- **Tek RUN satırında** birleştirin (katman sayısını azaltır, ama okunabilirliği bozmayın).
- **.dockerignore** ile build context'i küçük tutun.
- **Multi-stage** ile runtime'da yalnızca gerekenleri taşıyın.
- `pip install --no-cache-dir`, `npm ci --omit=dev` (üretimde dev bağımlılıkları dahil etmeyin).
- Statik dosyaları build aşamasında minimize/kompres edin.

---

## 6) Doğrulama ve ölçüm

- İmajları listeleyin: `docker images`
- Katman geçmişi: `docker history <image:tag>`
- Çalıştırın ve test edin: `docker run --rm -p 8000:8000 <image:tag>`
- Boyut karşılaştırması: Optimize öncesi ve sonrası tag'ler ile kıyaslayın.

---

## 7) Ödev Görevleri

Görev 1 — .dockerignore oluştur/iyileştir
- Projenizin köküne `.dockerignore` ekleyin veya mevcutsa gözden geçirin.
- `node_modules/`, `.venv/`, `__pycache__/`, `*.log`, `.env*` gibi gereksizleri dışarıda bırakın.
- Build context'in küçüldüğünü doğrulayın (build süresi/çıktılarını gözlemleyin).

Görev 2 — Katman sırasını optimize et
- Dockerfile'da bağımlılık kurulumunu uygulama kodu kopyasından önce konumlandırın.
- Cache isabetini gözlemleyin (ikinci build daha hızlı olmalı).

Görev 3 — Multi-stage build uygula
- Bir `builder` ve bir `runtime` aşaması tanımlayın.
- Runtime imajını daha küçük bir taban imajla üretin.
- Optimize öncesi/sonrası imaj boyutlarını ve `docker history` çıktısını karşılaştırın.

Görev 4 — Üretim hazır çalıştırma
- Konteyneri çalıştırın ve uygulamanın beklendiği gibi davrandığını doğrulayın.
- Gerekirse `HEALTHCHECK` ekleyin, temel logları gözlemleyin.

Bonus — BuildKit cache mount kullanımı
- `RUN --mount=type=cache,target=/root/.cache/pip` (veya Node için pnpm/npm cache) kullanarak tekrar build'lerde ek hız kazanın.

---

## 8) Sık hatalar ve kaçınma yolları

- Büyük klasörleri (.venv, node_modules) context'e dahil etmek → build yavaşlar, imaj şişer.
- `COPY . .` öncesi `requirements.txt`/`package.json` kopyalamamak → cache verimsizliği.
- Üretimde development bağımlılıklarını tutmak → gereksiz boyut ve risk.
- Alpine'ı körlemesine seçmek → C-uzantılı paketlerde derleme sorunları; önce doğrulayın.

---

## 9) Kontrol Listesi

- [.dockerignore] Mevcut ve kapsayıcı mı?
- [Katmanlar] Bağımlılık kurulumları uygulama kopyasından önce mi?
- [Multi-stage] Builder ve runtime ayrıldı mı?
- [Boyut] Optimize sonrası imaj daha küçük mü?
- [Cache] İkinci build belirgin şekilde hızlı mı?
- [Güvenlik] .env gibi gizli dosyalar dahil edilmiyor mu?

---

## 🎓 Sonraki Adım

Ödev 4'ü tamamladıysanız, **ÖDEV 5: Container Güvenliği Temelleri** (`ODEV5_GUVENLIK.md`) dosyasına geçin!

Başarılar! 🎉


------------------------------------------------

Ödev 4 – 10 adımda ne yaptık ve ne öğrendik?
1) Proje klasörüne geç
Öğrendik: Tüm komutlar doğru dizinde koşmalı; aksi halde Docker context yanlış olur.
Yaptık: Çalışma dizinini actions-deneme olarak ayarladık.
2) BuildKit’i aç
Öğrendik: BuildKit cache mount ve daha hızlı/şeffaf build çıktılarını sağlar.
Yaptık: DOCKER_BUILDKIT=1 ile BuildKit’i etkinleştirdik.
3) .dockerignore’u doğrula
Öğrendik: Build context’i küçültür, gizlileri/imaja gereksizleri taşımayı engeller, cache’i korur.
Yaptık: __pycache__/, .venv/, .pytest_cache/, *.log, .git gibi girdileri doğruladık.
4) Optimize Dockerfile ile imaj üret
Öğrendik: Multi-stage build (builder+runtime), cache-dostu COPY/RUN sırası, BuildKit cache mount.
Yaptık: docker build -t odev4 . ile optimize edilmiş imajı ürettik.
5) Container’ı çalıştır
Öğrendik: Runtime aşamasında sadece gerekli dosyaları kopyalamak güvenli ve küçük imaj sağlar.
Yaptık: docker run --rm odev4 ile uygulamayı başlatmayı denedik; mimari/şerit kütüphane hatası alınca Dockerfile’ı sadeleştirdik ve platform belirtme yönlendirmesi yaptık.
6) Cache etkisini gör
Öğrendik: Aynı komutlar/değişmeyen katmanlar cache’den gelir; ikinci build daha hızlıdır.
Yaptık: Aynı docker build’i tekrar çalıştırarak hız farkını ve --progress=plain ile katmanları gözledik.
7) İmaj boyutu ve katmanları incele
Öğrendik: docker images imaj boyutlarını, docker history her katmanın komutunu ve boyutunu gösterir.
Yaptık: odev4 imajının katman yapısını ve toplam boyutunu inceledik.
8) Önce/sonra karşılaştırması
Öğrendik: Farklı tag’lerle optimizasyon etkisini kıyaslayabiliriz.
Yaptık: odev4 ve odev4:optimized tag’lerini karşılaştırdık.
9) Sorun giderme
Öğrendik: Hataların büyük kısmı BuildKit kapalı olması, platform uyumsuzluğu (amd64/arm64) veya yanlış context’ten kaynaklanır.
Yaptık: BuildKit’i kontrol ettik; gerekirse --platform linux/amd64 ya da --platform linux/arm64 ile yeniden build/çalıştırma yönlendirmesi verdik; .dockerignore kapsamını gözden geçirdik.
10) Temizlik
Öğrendik: Kullanılmayan container/imajları temizlemek disk alanı ve kafa karışıklığını azaltır.
Yaptık: docker container prune -f ve docker image prune -f ile temizlik yapılabileceğini öğrendik.