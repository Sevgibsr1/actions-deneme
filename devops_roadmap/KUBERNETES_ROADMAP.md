## Kubernetes Yol Haritası ve Adım Adım Ödevler (DevOps Stajyeri)

Bu doküman Docker için yaptığımız adım adım yaklaşımın Kubernetes versiyonudur. Her adımda hedefler, komutlar ve ödev teslim kriterleri net olarak verilmiştir. Windows 10/11 + WSL2 ortamı için komut örnekleri eklenmiştir.


### 0) Hazırlık ve Kurulum

- Hedef: Yerel bir Kubernetes ortamı kurmak ve temel araçları hazır etmek.
- Araçlar:
  - WSL2 (Ubuntu 22.04 önerilir)
  - Docker Engine / Docker Desktop (WSL2 entegrasyonlu)
  - kubectl
  - Minikube veya Kind (ikisi de olur, biri yeterli)
  - Helm

- Kurulum (WSL Ubuntu içinde):

```bash
# kubectl
sudo apt update
sudo apt install -y curl ca-certificates apt-transport-https
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubectl
kubectl version --client

# Minikube (opsiyonel, Kind da kullanabilirsiniz)
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
sudo install minikube /usr/local/bin/
minikube version

# Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

- Kümeyi başlatma (Minikube):
```bash
minikube start --driver=docker
kubectl get nodes
```

- Alternatif (Kind):
```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
kind create cluster --name dev
kubectl cluster-info
```

Ödev 0 (Teslim): Kullandığın aracı (Minikube/Kind) ve `kubectl get nodes` çıktısını ekran görüntüsü veya metin olarak paylaş.


### 1) Kubernetes Temelleri: Objeler ve YAML

- Hedef: Pod, ReplicaSet, Deployment, Service kavramlarını ve YAML manifest yapısını öğrenmek.
- Adımlar:
  1. Basit bir `Deployment` ve `Service` YAML’ı incele.
  2. `kubectl` ile CRUD işlemlerini uygula: apply, get, describe, logs, delete.

Örnek:
```bash
kubectl create namespace dev
kubectl config set-context --current --namespace=dev

# Örnek bir NGINX deployment + service
cat > nginx-deploy.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
spec:
  replicas: 2
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-svc
spec:
  type: ClusterIP
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
EOF

kubectl apply -f nginx-deploy.yaml
kubectl get deploy,rs,pods,svc
kubectl describe svc nginx-svc
```

Ödev 1 (Teslim): Kendi yazdığın `Deployment + Service` YAML dosyalarını repo’na ekle, `kubectl get` ve `kubectl describe` çıktısını paylaş.


### 2) Mevcut Uygulamanı Taşı: İlk Gerçek Deploy

- Hedef: Docker ile çalıştırdığın basit web servisinin Kubernetes’e taşınması.
- Adımlar:
  1. Mevcut imajını bir container registry’e itin (Docker Hub olabilir).
  2. `Deployment` ile bu imajı çalıştır.
  3. `Service` (ClusterIP/NodePort) ile iç/dış erişimi ayarla.
  4. Rollout ve rollback komutlarını dene.

Komutlar:
```bash
# rollout ve revision izle
kubectl rollout status deploy/<deploy-adi>
kubectl rollout history deploy/<deploy-adi>
kubectl rollout undo deploy/<deploy-adi> --to-revision=1
```

Ödev 2 (Teslim): “Uygulamanız Kubernetes’de çalışıyor” kanıtı: YAML’lar + erişim testi (curl veya tarayıcı) + rollout history ekran görüntüsü/metni.


### 3) Konfigürasyon Yönetimi: ConfigMap ve Secret

- Hedef: Ortam değişkenlerini ve gizli bilgileri objelere dışarı almak.
- Adımlar:
  1. `ConfigMap` ile yapılandırma değerlerini tanımla ve Pod’a env/envFrom ile geçir.
  2. `Secret` ile hassas bilgileri (ör. DB şifresi) base64 kodlu şekilde tut.
  3. Volume olarak mount etmeyi ve env değişkeni olarak kullanmayı dene.

Örnek:
```bash
kubectl create configmap app-config --from-literal=APP_MODE=dev
kubectl create secret generic app-secret --from-literal=DB_PASSWORD='s3cr3t'
```

Ödev 3 (Teslim): `ConfigMap` ve `Secret` içeren bir `Deployment` manifesti + Pod içinde env değerlerinin doğru geldiğini gösteren `kubectl exec env` çıktısı.


### 4) Sağlık Kontrolleri ve Ölçekleme: Probes, Requests/Limits, HPA

- Hedef: Uygulama sağlığını takip eden probe’lar, kaynak istek/limitleri ve otomatik yatay ölçekleme.
- Adımlar:
  1. `livenessProbe` ve `readinessProbe` ekle (HTTP veya TCP).
  2. Container için `resources.requests/limits` tanımla.
  3. Metrics server kur ve `HPA` ile CPU bazlı scale test et.

Komutlar:
```bash
# minikube için metrics-server eklentisi
minikube addons enable metrics-server

# HPA örneği (CPU %50 hedef)
kubectl autoscale deployment <deploy-adi> --cpu-percent=50 --min=1 --max=5
kubectl get hpa
```

Ödev 4 (Teslim): Probe’ları ve `resources` alanını gösteren YAML + HPA’nın çalıştığını gösteren `kubectl get hpa` ve pod sayı değişimi evidansı.


### 5) Servis Ağı ve Ingress

- Hedef: Servis türleri ve Ingress ile dış dünyaya yayın.
- Adımlar:
  1. `Service` türlerini test et: `ClusterIP`, `NodePort`.
  2. `Nginx Ingress Controller` kur.
  3. Host tabanlı bir `Ingress` ile uygulamayı publish et, gerekirse TLS ekle.

Minikube kolay test:
```bash
minikube addons enable ingress
kubectl get pods -n ingress-nginx
```

Ödev 5 (Teslim): `Ingress` YAML’ı + `curl -H "Host: example.local"` gibi bir komutla başarılı yanıt evidansı. TLS denediysen sertifika/secret tanımını göster.


### 6) Kalıcı Depolama ve Stateful Uygulamalar

- Hedef: PersistentVolume (PV), PersistentVolumeClaim (PVC) ve StatefulSet kullanımı.
- Adımlar:
  1. Basit bir `PVC` oluştur ve bir Pod’a volume olarak bağla.
  2. Bir veritabanını `StatefulSet + Service + PVC` ile ayağa kaldır (ör. PostgreSQL).
  3. Veri kalıcılığını pod yeniden başlatma sonrasında doğrula.

Ödev 6 (Teslim): StatefulSet + PVC manifestleri ve veri kalıcılığını gösteren kanıt (ör: tabloda kayıt kalmış).


### 7) Gözlemlenebilirlik (Observability): Prometheus & Grafana

- Hedef: Kümenden metrik toplamak ve dashboard ile izlemek.
- Adımlar:
  1. Helm ile Prometheus ve Grafana kur.
  2. Service/Ingress ile Grafana’ya eriş.
  3. Basit bir dashboard yükle ve CPU/Memory grafikleri göster.

Komutlar (örnek repo/chart isimleri değişebilir):
```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prom prometheus-community/kube-prometheus-stack -n monitoring
kubectl get pods -n monitoring
```

Ödev 7 (Teslim): Grafana erişim bilgisi + ekran görüntüsü/metrik evidansı.


### 8) Güvenlik: Namespaces, RBAC, NetworkPolicy, Image Security

- Hedef: Yetkilendirme ve ağ politikalarını temel seviyede uygulamak.
- Adımlar:
  1. `Namespace` yapısı oluştur, servis hesapları (ServiceAccount) tanımla.
  2. `Role/ClusterRole` + `RoleBinding/ClusterRoleBinding` ile RBAC uygula.
  3. `NetworkPolicy` ile pod’lar arası trafiği kısıtla.
  4. İmaj zafiyet taraması yap (ör. Trivy).

Komutlar:
```bash
sudo apt install -y trivy
trivy image <dockerhub-kullanici>/<image>:<tag>
```

Ödev 8 (Teslim): RBAC YAML’ları + NetworkPolicy YAML’ı + Trivy çıktısı ve yorumun.


### 9) CI/CD ve GitOps’a Giriş

- Hedef: Otomatik build ve deploy akışı kurmak.
- Adımlar:
  1. GitHub Actions ile Docker imajını build ve push.
  2. Deploy aşaması: `kubectl` veya `Helm` ile manifestleri cluster’a uygula.
  3. Bonus: ArgoCD/Flux ile GitOps yaklaşımı incele.

Ödev 9 (Teslim): `.github/workflows/` pipeline YAML + başarılı run kanıtı (screenshot/link).


### 10) Yaygın Yayın Stratejileri: RollingUpdate, Blue/Green, Canary

- Hedef: Kesintisiz veya kontrollü geçiş stratejilerini pratik etmek.
- Adımlar:
  1. `Deployment` ile RollingUpdate parametrelerini değiştir (maxUnavailable, maxSurge).
  2. Blue/Green için iki ayrı sürüm ve `Service` switch senaryosu.
  3. Canary için Ingress/Service ağırlıklı routing ya da Argo Rollouts kullanımı.

Ödev 10 (Teslim): Seçtiğin bir strateji için YAML ve geçişin başarılı olduğuna dair kanıt.


### 11) Ekstra: Chaos Engineering (İsteğe Bağlı)

- Hedef: Dayanıklılık testleri.
- Adımlar:
  1. LitmusChaos veya benzeri bir araç ile pod kill testi.
  2. Uygulamanın HPA ve probe’larla kendini toparlama davranışını incele.

Ödev 11 (Teslim): Senaryo adımları + gözlemler + iyileştirme önerilerin.


### Teslim Biçimi ve İpuçları

- Her adımın YAML ve komut çıktıları repo’da ayrı klasörlerde tutulmalı: `k8s/<adim-adi>/...`
- Küçük ama anlamlı commit mesajları kullan.
- `kubectl explain <resource>` ile alanları hızlıca öğren.
- Minikube kullanıyorsan `minikube service <svc-adi> --url -n <ns>` ile servis URL’ini al.
- Sorun yaşarsan `kubectl describe` ve `kubectl logs` ilk bakılacak yerler.


### Yolun Genel Akışı (Özet)

1) Kurulum ve cluster (Minikube/Kind) → 2) Objeler ve YAML → 3) İlk gerçek deploy → 4) ConfigMap/Secret → 5) Probes/Resources/HPA → 6) Networking/Ingress → 7) PVC/StatefulSet → 8) Observability → 9) Güvenlik → 10) CI/CD → 11) İleri stratejiler ve chaos.

Hazırsan 0. adımdan başla; her adımı repo’da iz bırakacak şekilde tamamla. Takıldığın noktada sor!


