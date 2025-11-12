# 📊 Chaos Engineering Ödevi - Özet Rapor

## ✅ Tamamlanan Adımlar

### 1. Ön Koşullar
- ✅ Metrics server etkinleştirildi
- ✅ Deployment (nginx-deploy) oluşturuldu
- ✅ Service (nginx-svc) oluşturuldu
- ✅ HPA (nginx-deploy-hpa) oluşturuldu
- ✅ RBAC (ServiceAccount, Role, RoleBinding) uygulandı

### 2. LitmusChaos Kurulumu
- ✅ Litmus operator kuruldu
- ✅ ChaosExperiment (pod-delete) kuruldu

### 3. Chaos Testi
- ✅ ChaosEngine oluşturuldu ve başlatıldı
- ✅ Pod kill testi çalıştırıldı

## 📝 Gözlemler

### Pod Öldürme ve Toparlanma
Chaos testi sırasında:
- Pod'lar belirli aralıklarla öldürüldü
- Deployment otomatik olarak yeni pod'lar oluşturdu
- Sistem kendini toparladı

**Gözlem komutları:**
```bash
# Pod durumunu görmek için
kubectl get pods -n dev -l app=nginx -w

# Event'leri görmek için
kubectl get events -n dev --sort-by='.lastTimestamp' | grep -i kill
```

### HPA Davranışı
- HPA CPU metriklerini izledi
- Pod sayısı 1-5 arasında otomatik ayarlandı (CPU yüküne göre)

**Gözlem komutları:**
```bash
kubectl get hpa -n dev -w
kubectl describe hpa nginx-deploy-hpa -n dev
```

### Probe Sonuçları
- Readiness ve Liveness probe'ları pod'ların sağlığını kontrol etti
- Pod'lar hazır olduğunda trafiğe alındı

## 🔧 İyileştirme Önerileri

### 1. Probe Ayarları
- `initialDelaySeconds`: Pod'un başlaması için yeterli süre verilmeli
- `periodSeconds`: Probe kontrol sıklığı optimize edilebilir
- `failureThreshold`: Başarısızlık toleransı ayarlanabilir

### 2. HPA Ayarları
- CPU threshold değeri workload'a göre ayarlanmalı
- `minReplicas` ve `maxReplicas` değerleri uygulama ihtiyacına göre belirlenmeli

### 3. Deployment Stratejisi
- `maxUnavailable` ve `maxSurge` değerleri yüksek erişilebilirlik için optimize edilebilir
- Pod Disruption Budget eklenebilir

### 4. Kaynak Yönetimi
- CPU/Memory request ve limit değerleri uygulama ihtiyacına göre ayarlanmalı

## 📁 Kullanılan Dosyalar

### Temel Dosyalar
- `00-prerequisites.yaml` - Deployment, Service, HPA
- `01-rbac.yaml` - RBAC yapılandırması
- `02-chaosengine.yaml` - ChaosEngine manifesti

### Yardımcı Scriptler
- `run-chaos-test.sh` - Otomatik test scripti
- `monitor-chaos.sh` - Gözlem scripti

### Dokümantasyon
- `README.md` - Detaylı kılavuz
- `ADIMLAR.md` - Hızlı başlangıç
- `GOZLEM_KOMUTLARI.md` - Gözlem komutları
- `03-observations-template.md` - Gözlem raporu şablonu

## 🎯 Sonuç

Chaos Engineering testi başarıyla tamamlandı. Sistem:
- ✅ Pod öldürme durumunda kendini toparladı
- ✅ HPA ile otomatik ölçeklendirme çalıştı
- ✅ Probe'lar ile sağlık kontrolü yapıldı
- ✅ Dayanıklılık test edildi

## 📚 Öğrenilenler

1. **Chaos Engineering**: Sistemin dayanıklılığını test etme yöntemi
2. **LitmusChaos**: Kubernetes için chaos engineering aracı
3. **HPA**: Otomatik ölçeklendirme mekanizması
4. **Probe'lar**: Pod sağlık kontrolü
5. **RBAC**: Kubernetes yetkilendirme sistemi

## 🔗 Kaynaklar

- [LitmusChaos Dokümantasyonu](https://docs.litmuschaos.io/)
- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Kubernetes Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)

