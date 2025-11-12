# 🎯 Ödev 11: Chaos Engineering

Bu ödev, Kubernetes üzerinde LitmusChaos kullanarak pod kill testi yapmayı ve sistemin dayanıklılığını test etmeyi içerir.

## 📋 Ön Koşullar

1. Kubernetes cluster çalışıyor (Minikube/Kind)
2. `kubectl` yapılandırılmış
3. Metrics server kurulu (HPA için)

## 🚀 Hızlı Başlangıç

### Adım 1: Ön Koşulları Hazırla

```bash
cd k8s/11-chaos

# Metrics server'ı etkinleştir
minikube addons enable metrics-server

# Deployment, Service ve HPA oluştur
kubectl apply -f 00-prerequisites.yaml

# Pod'ların hazır olmasını bekle
kubectl wait --for=condition=ready pod -l app=nginx -n dev --timeout=120s
```

### Adım 2: LitmusChaos Kur

```bash
# Litmus namespace oluştur
kubectl create namespace litmus

# Litmus operator'ü kur
kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator-v3.7.0.yaml

# Pod-delete experiment'ini kur (yerel manifest'ten)
kubectl apply -f 04-chaosexperiment.yaml

# VEYA URL'den (eğer yerel dosya yoksa)
# kubectl apply -f https://hub.litmuschaos.io/api/chaos/master?file=charts/generic/pod-delete/experiment.yaml

# Operator'ün hazır olmasını bekle
kubectl wait --for=condition=ready pod -l app=litmus-operator -n litmus --timeout=120s
```

### Adım 3: RBAC Uygula

```bash
kubectl apply -f 01-rbac.yaml
```

### Adım 4: Chaos Testini Çalıştır

**Otomatik (Önerilen):**
```bash
chmod +x run-chaos-test.sh
./run-chaos-test.sh
```

**Manuel:**
```bash
kubectl apply -f 02-chaosengine.yaml

# Pod'ları izle
kubectl get pods -n dev -l app=nginx -w
```

## 👀 Gözlem

### Pod'ları İzle
```bash
kubectl get pods -n dev -l app=nginx -w
```

### HPA'yı İzle
```bash
kubectl get hpa -n dev -w
```

### Event'leri İzle
```bash
kubectl get events -n dev --sort-by='.lastTimestamp' -w
```

### ChaosEngine Durumu
```bash
kubectl describe chaosengine nginx-pod-delete -n dev
```

## 📊 Gözlem Raporu

Gözlemlerinizi `03-observations-template.md` dosyasına kaydedin.

## 🧹 Temizlik

```bash
# ChaosEngine'i sil
kubectl delete chaosengine nginx-pod-delete -n dev

# Deployment ve HPA'yı sil (opsiyonel)
kubectl delete -f 00-prerequisites.yaml

# Litmus'u temizle (opsiyonel)
kubectl delete -f https://litmuschaos.github.io/litmus/litmus-operator-v3.7.0.yaml
kubectl delete namespace litmus
```

## 📁 Dosya Yapısı

- `00-prerequisites.yaml` - Deployment, Service, HPA
- `01-rbac.yaml` - RBAC yapılandırması
- `02-chaosengine.yaml` - ChaosEngine manifesti
- `04-chaosexperiment.yaml` - ChaosExperiment manifesti (pod-delete)
- `03-observations-template.md` - Gözlem raporu şablonu
- `run-chaos-test.sh` - Otomatik test scripti
- `monitor-chaos.sh` - Gözlem scripti
- `OZET_RAPOR.md` - Özet rapor

## 🎯 Beklenen Sonuçlar

✅ Pod'lar öldürülmeli ve yeniden oluşturulmalı  
✅ Deployment otomatik olarak yeni pod'lar oluşturmalı  
✅ HPA (eğer CPU yükü varsa) pod sayısını ayarlamalı  
✅ Probe'lar pod'ların sağlığını kontrol etmeli  
✅ Sistem 30-60 saniye içinde normale dönmeli

## 📚 Öğrenilenler

1. **Chaos Engineering**: Sistemin dayanıklılığını test etme
2. **LitmusChaos**: Kubernetes için chaos engineering aracı
3. **HPA**: Otomatik ölçeklendirme
4. **Probe'lar**: Pod sağlık kontrolü
5. **RBAC**: Kubernetes yetkilendirme

## 🔗 Kaynaklar

- [LitmusChaos Dokümantasyonu](https://docs.litmuschaos.io/)
- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Kubernetes Probes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/)
