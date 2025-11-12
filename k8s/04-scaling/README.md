# Kubernetes Scaling - Deployment ve HPA

Bu klasör, Kubernetes'te deployment ölçeklendirme ve HPA (Horizontal Pod Autoscaler) yapılandırmalarını içerir.

## 📁 Dosyalar

- `deployment-patch.yaml` - Nginx deployment manifesti
- `hpa.yaml` - Horizontal Pod Autoscaler manifesti

## ⚙️ Namespace Kullanımı

**ÖNEMLİ:** Tüm dosyalar `dev` namespace'ini kullanır.

### Deployment
```yaml
metadata:
  name: nginx-deploy
  namespace: dev
```

### HPA
```yaml
metadata:
  name: nginx-deploy-hpa
  namespace: dev
spec:
  scaleTargetRef:
    name: nginx-deploy  # Aynı namespace'teki deployment'ı hedefler
```

## 🚀 Kullanım

### Deployment ve HPA'yı birlikte uygula:
```bash
kubectl apply -f deployment-patch.yaml
kubectl apply -f hpa.yaml
```

### Kontrol et:
```bash
# Deployment durumu
kubectl get deployment nginx-deploy -n dev

# Pod'ları görüntüle
kubectl get pods -n dev -l app=nginx

# HPA durumu
kubectl get hpa nginx-deploy-hpa -n dev

# HPA detayları
kubectl describe hpa nginx-deploy-hpa -n dev
```

## 📊 HPA Ayarları

- **Min Replicas**: 1
- **Max Replicas**: 5
- **CPU Target**: %50
- **Metric Type**: Resource (CPU)

HPA, CPU kullanımı %50'yi aştığında pod sayısını artırır, düştüğünde azaltır.

## 🔧 Farklı Namespace Kullanımı

Eğer farklı bir namespace kullanmak isterseniz:

```bash
# Tüm dosyalardaki namespace'i değiştir
sed -i 's/namespace: dev/namespace: your-namespace/g' *.yaml

# VEYA manuel olarak dosyaları düzenleyin
```

## 📚 İlgili Dokümantasyon

- [Kubernetes HPA](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/)
- [Deployment Strategy](https://kubernetes.io/docs/concepts/workloads/controllers/deployment/#strategy)

