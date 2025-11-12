# ÖDEV 5: Container Güvenliği Temelleri

Bu ödevde container güvenliğinin temel ilkelerini, Docker imajınızı ve çalıştırma ayarlarınızı nasıl daha güvenli hale getireceğinizi öğreneceksiniz. Hedef: “en az yetki” prensibini uygulayarak saldırı yüzeyini küçültmek ve yanlış yapılandırmalardan kaynaklı riskleri azaltmak.

---

## 1) Temel İlkeler

- En az yetki (least privilege)
- Saldırı yüzeyini küçültme (küçük imaj, az paket)
- Ayrıcalıkları düşürme (root olmayan kullanıcı, capabilities azaltma)
- Salt-okunur dosya sistemi ve geçici yazma alanları
- Güvenli sır yönetimi (secrets)
- Supply chain güvenliği (imaj tarama, SBOM, imza/doğrulama)
- Kaynak sınırları ve izolasyon

---

## 2) Dockerfile Güvenlik İpuçları

Python örneği (Ödev 4’teki yapı üzerine):
```Dockerfile
FROM python:3.12-slim AS runtime
WORKDIR /app

# Sadece gereken dosyaları ekleyin
COPY hello.py .

# Root olmayan kullanıcı oluşturun
RUN useradd -u 10001 -m appuser
USER 10001:10001

# Salt-okunur dosya sistemi kullanmayı planlıyorsanız
# uygulamanızın yazma ihtiyaçlarını dikkate alın.

CMD ["python", "hello.py"]
```

Notlar:
- Root yerine normal kullanıcı kullanın (`USER`). Uygulama yazma gerektirmiyorsa, salt-okunur FS ile çok daha güvenli.
- Gereksiz paket kurmayın; `-slim` taban imaj tercih edin.
- Multi-stage build ile derleme araçlarını runtime’dan uzak tutun.

---

## 3) Çalıştırma (Runtime) Güvenlik Bayrakları

Aşağıdaki bayraklar saldırı yüzeyini ciddi şekilde azaltır. İhtiyaç duydukça kademeli uygulayın.

```bash
docker run --rm \
  --read-only \                     # Dosya sistemi salt-okunur
  --tmpfs /tmp \                    # Geçici yazma alanı
  --cap-drop ALL \                  # Tüm capabilities’i düşür
  --cap-add CHROOT \                # (Örnek) gerekiyorsa belirli bir capability ekle
  --security-opt no-new-privileges \# Yeni ayrıcalık kazanmayı engelle
  --pids-limit 100 \                # Süreç sayısı sınırı
  --memory 256m --cpus 0.5 \        # Kaynak limitleri
  --user 10001:10001 \              # Root olmayan kullanıcı
  --name odev5-sec \
  odev4
```

Gelişmiş seçenekler:
- `--security-opt seccomp=default` veya özel seccomp profili
- AppArmor/SELinux profilleri (dağıtıma/ortama bağlı)
- `--device-read-bps`, `--blkio-weight` gibi I/O sınırlamaları

---

## 4) Secrets ve Konfigürasyon

- Sırları imaja gömmeyin; `.env` dosyalarını imaj içine kopyalamayın.
- Gerekirse `docker secret` (Swarm) veya orkestratör bazlı secret mekanizmaları kullanın.
- Lokal geliştirmede: environment değişkenleri ile verin ve `.dockerignore` ile `.env` dosyalarını dışlayın.

Örnek (yalnızca geliştirme):
```bash
docker run --rm \
  -e API_TOKEN=${API_TOKEN} \
  --name odev5-env \
  odev4
```

---

## 5) Supply Chain Güvenliği

- İmaj tarama: `docker scan` (Docker Scout) veya Trivy/Grype gibi araçlar
- Küçük ve güncel taban imajlar kullanın (CVE düzeltmeleri için güncelleyin).
- SBOM üretme ve izleme (Syft/Anchore vb.).
- İmaj imzalama ve doğrulama (cosign, Notary v2/SBOM doğrulama).

Örnek (Docker Scout):
```bash
docker scout quickview odev4
docker scout cves odev4
```

Trivy (kurulu ise):
```bash
trivy image odev4
```

---

## 6) Ağ ve Socket Güvenliği

- Gereksiz portları yayınlamayın (`-p`).
- `localhost` üzerinden bağlayın: `-p 127.0.0.1:8000:8000`
- Docker daemon socket’i (`/var/run/docker.sock`) container’a bağlamayın; bağlamak zorundaysanız riskini anlayın ve sınırlayın.

---

## 7) Kaynak Sınırları ve İzolasyon

- `--memory`, `--cpus`, `--pids-limit` ile taşma/saldırı etkilerini sınırlayın.
- Read-only FS + `--tmpfs` ile yazma ihtiyacını izole edin.
- `no-new-privileges` ile SUID/SUDO ile ayrıcalık yükseltme riskini azaltın.

---

## 8) Ödev Görevleri

Görev 1 — Root olmayan kullanıcıya geç
- `Dockerfile` içine `USER` ekleyin (ör: `10001:10001`).
- Container’ı `--user` ile de çalıştırmayı deneyin.

Görev 2 — Read-only dosya sistemi ve tmpfs
- `--read-only` ile çalıştırın.
- Uygulamanın ihtiyaç duyduğu yazma dizinleri için `--tmpfs /tmp` veya gerekliyse `-v` ile belirli bir dizin.

Görev 3 — Capabilities azaltma
- `--cap-drop ALL` ile başlatın.
- Hata alırsanız yalnızca gerekli capability’leri `--cap-add` ile ekleyin.

Görev 4 — Kaynak limitleri
- `--memory`, `--cpus`, `--pids-limit` ayarlayın ve uygulamanın çalıştığını doğrulayın.

Görev 5 — İmaj taraması
- `docker scout` veya Trivy ile imajı tarayın ve raporu inceleyin.

Bonus — Seccomp/AppArmor
- Varsayılan profille çalıştırın, sonra kısıtlayıcı bir profil deneyin. Uygulamanın ihtiyaçlarını belgeleyin.

---

## 9) Doğrulama ve Kontrol Listesi

- [USER] Container root olmayan kullanıcıyla çalışıyor mu?
- [FS] `--read-only` aktif, gerekli yazma alanları `--tmpfs` ile sağlandı mı?
- [CAPS] `--cap-drop ALL` uygulandı ve sadece gerekli capability’ler eklendi mi?
- [LIMITS] Bellek/CPU/PIDs limitleri ayarlandı mı?
- [SECRETS] Sırlar imaja gömülmedi mi?
- [SCAN] İmaj taramalarında kritik açıklar giderildi mi?

---

## 10) Faydalı Komutlar Özet

```bash
# Root olmayan kullanıcıyla, salt-okunur, limitli
docker run --rm \
  --read-only \
  --tmpfs /tmp \
  --cap-drop ALL \
  --security-opt no-new-privileges \
  --pids-limit 100 \
  --memory 256m --cpus 0.5 \
  --user 10001:10001 \
  --name odev5 \
  odev4

# İmaj tarama (Docker Scout)
docker scout quickview odev4
docker scout cves odev4
```

---

## 🎓 Sonraki Adım

Ödev 5’i tamamladıysanız, **ÖDEV 6: Docker Compose ile Çok Servisli Yapı** (`ODEV6_COMPOSE.md`) dosyasına geçin!

Başarılar! 🎉


