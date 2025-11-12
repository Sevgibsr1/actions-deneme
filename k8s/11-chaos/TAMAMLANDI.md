# ✅ Ödev 11: Chaos Engineering - TAMAMLANDI

## 📋 Yapılanlar

### 1. Dosya Yapısı Oluşturuldu
- ✅ `00-prerequisites.yaml` - Deployment, Service, HPA manifestleri
- ✅ `01-rbac.yaml` - RBAC yapılandırması (ServiceAccount, Role, RoleBinding)
- ✅ `02-chaosengine.yaml` - ChaosEngine manifesti
- ✅ `03-observations-template.md` - Gözlem raporu şablonu
- ✅ `README.md` - Ana kılavuz
- ✅ `run-chaos-test.sh` - Otomatik test scripti
- ✅ `monitor-chaos.sh` - Gözlem scripti
- ✅ `OZET_RAPOR.md` - Özet rapor

### 2. Gereksiz Dosyalar Temizlendi
- ❌ `check-cluster.sh` - Silindi (gereksiz)
- ❌ `setup.sh` - Silindi (gereksiz)
- ❌ `quick-start.sh` - Silindi (gereksiz)
- ❌ `ADIMLAR.md` - Silindi (README'de var)
- ❌ `GOZLEM_KOMUTLARI.md` - Silindi (README'de var)

## 🎯 Ödev İçeriği

### Hedef
Kubernetes üzerinde LitmusChaos kullanarak pod kill testi yapmak ve sistemin dayanıklılığını test etmek.

### Adımlar
1. **Ön Koşullar**: Deployment, Service, HPA oluşturma
2. **LitmusChaos Kurulumu**: Operator ve experiment kurulumu
3. **RBAC**: Chaos için gerekli yetkilendirme
4. **Chaos Testi**: Pod kill testini çalıştırma
5. **Gözlem**: Pod'ların öldürülmesi ve yeniden oluşturulmasını izleme

## 📊 Nasıl Kullanılır

### Hızlı Başlangıç
```bash
cd k8s/11-chaos

# 1. Ön koşulları hazırla
minikube addons enable metrics-server
kubectl apply -f 00-prerequisites.yaml
kubectl wait --for=condition=ready pod -l app=nginx -n dev --timeout=120s

# 2. LitmusChaos kur
kubectl create namespace litmus
kubectl apply -f https://litmuschaos.github.io/litmus/litmus-operator-v3.7.0.yaml
kubectl apply -f https://hub.litmuschaos.io/api/chaos/master?file=charts/generic/pod-delete/experiment.yaml

# 3. RBAC uygula
kubectl apply -f 01-rbac.yaml

# 4. Chaos testini çalıştır
chmod +x run-chaos-test.sh
./run-chaos-test.sh
```

### Gözlem
```bash
# Pod'ları izle
kubectl get pods -n dev -l app=nginx -w

# HPA'yı izle
kubectl get hpa -n dev -w

# Event'leri izle
kubectl get events -n dev --sort-by='.lastTimestamp' -w
```

## 📝 Teslim İçin

1. **Gözlem Raporu**: `03-observations-template.md` dosyasını doldurun
2. **Komut Çıktıları**: Test sırasında aldığınız çıktıları kaydedin
3. **İyileştirme Önerileri**: Gözlemlerinize dayanarak öneriler yazın

## 🎓 Öğrenilenler

- Chaos Engineering kavramı
- LitmusChaos kullanımı
- Kubernetes HPA (Horizontal Pod Autoscaler)
- Probe'lar (Readiness/Liveness)
- RBAC (Role-Based Access Control)

## ✅ Ödev Tamamlandı!

Tüm dosyalar hazır, ödevi çalıştırmak için yukarıdaki adımları takip edin.

