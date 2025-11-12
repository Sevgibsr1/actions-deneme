# Chaos Engineering Ödevi - Gözlem Raporu

## Senaryo Adımları

1. **LitmusChaos kurulumu:** [ ] Tamamlandı / [ ] Başarısız
2. **RBAC yapılandırması:** [ ] Tamamlandı / [ ] Başarısız
3. **ChaosEngine uygulaması:** [ ] Tamamlandı / [ ] Başarısız
4. **Pod kill testi:** [ ] Tamamlandı / [ ] Başarısız

---

## Gözlemler

### Pod Öldürme ve Toparlanma

- **Pod öldürülme zamanı:** `_____________`
- **Pod yeniden oluşturulma zamanı:** `_____________`
- **Toparlanma süresi:** `_____________` saniye
- **Pod sayısı değişimi:**
  - Başlangıç pod sayısı: `_____________`
  - Minimum pod sayısı (ölüm sonrası): `_____________`
  - Son pod sayısı: `_____________`


Event'lerden gördüklerini yaz:
Pod öldürülme zamanları: 7m22s, 4m15s
Pod yeniden oluşturulma: 4m17s
HPA durumu: CPU 1%/50%, REPLICAS: 1
İyileştirme önerilerini ekle:
ChaosExperiment manifestinin düzeltilmesi
Chaos runner pod'unun oluşmaması sorunu


**Komut çıktısı:**
```bash
# Pod durumunu izleme çıktısı buraya
kubectl get pods -n dev -l app=nginx -w
```

---

### HPA Davranışı

- **HPA pod sayısını artırdı mı?** `[ ] Evet / [ ] Hayır`
- **Maksimum pod sayısı:** `_____________`
- **Minimum pod sayısı:** `_____________`
- **CPU kullanımı (ortalama):** `_____________%`
- **HPA tetiklenme zamanı:** `_____________`

**Komut çıktısı:**
```bash
# HPA durumu
kubectl get hpa nginx-deploy-hpa -n dev

# HPA detayları
kubectl describe hpa nginx-deploy-hpa -n dev
```

---

### Probe Sonuçları

- **Readiness probe başarısız oldu mu?** `[ ] Evet / [ ] Hayır`
- **Liveness probe başarısız oldu mu?** `[ ] Evet / [ ] Hayır`
- **Probe başarısızlık süresi:** `_____________` saniye
- **Uygulama erişilebilir miydi?** `[ ] Evet / [ ] Hayır`
- **Başarısız istek sayısı (varsa):** `_____________`

**Komut çıktısı:**
```bash
# Pod probe durumları
kubectl describe pod -n dev -l app=nginx | grep -A 5 "Readiness\|Liveness"

# Pod durumları
kubectl get pods -n dev -l app=nginx -o wide
```

---

### Event'ler ve Loglar

**Önemli event'ler:**
```bash
kubectl get events -n dev --sort-by='.lastTimestamp' | grep -i "kill\|delete\|terminat\|create\|start"
```

**Pod logları (varsa hata):**
```bash
kubectl logs -n dev -l app=nginx --tail=100
```

---

## İyileştirme Önerileri

### 1. Probe Ayarları
- [ ] `initialDelaySeconds` değerini optimize et: `Mevcut: _____ → Önerilen: _____`
- [ ] `periodSeconds` değerini ayarla: `Mevcut: _____ → Önerilen: _____`
- [ ] `failureThreshold` değerini gözden geçir: `Mevcut: _____ → Önerilen: _____`

### 2. HPA Ayarları
- [ ] CPU threshold değerini ayarla: `Mevcut: _____% → Önerilen: _____%`
- [ ] `minReplicas` değerini artır: `Mevcut: _____ → Önerilen: _____`
- [ ] `maxReplicas` değerini gözden geçir: `Mevcut: _____ → Önerilen: _____`

### 3. Deployment Stratejisi
- [ ] `maxUnavailable` değerini ayarla: `Mevcut: _____ → Önerilen: _____`
- [ ] `maxSurge` değerini ayarla: `Mevcut: _____ → Önerilen: _____`
- [ ] Pod disruption budget ekle: `[ ] Evet / [ ] Hayır`

### 4. Kaynak Yönetimi
- [ ] CPU/Memory request'lerini optimize et
- [ ] CPU/Memory limit'lerini gözden geçir
- [ ] Resource quota ekle (gerekirse)

### 5. Diğer Öneriler
- [ ] _________________________________________________
- [ ] _________________________________________________
- [ ] _________________________________________________

---

## Komut Çıktıları

### ChaosEngine Durumu
```bash
kubectl get chaosengine -n dev
kubectl describe chaosengine nginx-pod-delete -n dev
```

### Pod Durumları (Zaman Serisi)
```bash
# Başlangıç
kubectl get pods -n dev -l app=nginx

# Chaos sırasında
kubectl get pods -n dev -l app=nginx

# Son durum
kubectl get pods -n dev -l app=nginx
```

### HPA Metrikleri
```bash
kubectl get hpa -n dev
kubectl top pods -n dev -l app=nginx
```

---

## Sonuç ve Değerlendirme

**Genel Değerlendirme:**
- [ ] Sistem hızlı toparlandı (< 30 saniye)
- [ ] Sistem orta hızda toparlandı (30-60 saniye)
- [ ] Sistem yavaş toparlandı (> 60 saniye)
- [ ] Sistem toparlanamadı / Hata oluştu

**Dayanıklılık Skoru:** `_____ / 10`

**Açıklama:**
```
[Buraya genel gözlemlerinizi ve değerlendirmenizi yazın]
```

---

## Ek Notlar

```
[Buraya ek gözlemler, sorunlar veya öneriler ekleyebilirsiniz]
```

