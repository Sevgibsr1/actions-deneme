# Grafana Erişim Bilgileri

## 🔐 Grafana Giriş Bilgileri

**Kullanıcı Adı:** `admin`

**Şifre:** Kaydedilmiş şifre `.grafana-credentials` dosyasında saklanıyor.

### Kaydedilmiş Bilgiler (Hızlı Erişim)

Tüm bilgileri dosyadan okumak için:
```bash
# Şifre
grep GRAFANA_PASSWORD .grafana-credentials | cut -d'=' -f2

# Namespace
grep GRAFANA_NAMESPACE .grafana-credentials | cut -d'=' -f2

# Kullanıcı adı
grep GRAFANA_USERNAME .grafana-credentials | cut -d'=' -f2
```

**Kaydedilmiş Namespace:** `monitoring`

**Not:** Şifre veya namespace değişirse bu dosyayı güncelleyin. Dosya `.gitignore`'da olduğu için commit edilmeyecek.

### Alternatif: Kubernetes Secret'tan Şifre Alma

Eğer kaydedilmiş şifre çalışmazsa, Kubernetes Secret'tan alabilirsiniz:

## 📋 Adım Adım Erişim

### 1. kubectl Kurulumu (Eğer kurulu değilse)

WSL Ubuntu terminalinde çalıştırın:

```bash
sudo apt update
sudo apt install -y curl ca-certificates apt-transport-https
curl -fsSL https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/kubernetes-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt update && sudo apt install -y kubectl
kubectl version --client
```

### 2. Grafana Admin Şifresini Alma

```bash
# Grafana admin şifresini al
kubectl get secret -n monitoring kube-prom-grafana -o jsonpath="{.data.admin-password}" | base64 -d && echo

# Eğer yukarıdaki çalışmazsa, alternatif secret isimlerini deneyin:
kubectl get secret -n monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 -d && echo

# Veya tüm secret'ları listeleyin:
kubectl get secrets -n monitoring | grep grafana
```

### 3. Grafana'ya Erişim

#### Yöntem 1: Port Forward (Önerilen)

```bash
kubectl port-forward -n monitoring svc/kube-prom-grafana 3000:80
```

Sonra tarayıcıda açın: **http://localhost:3000**

#### Yöntem 2: Minikube Service

```bash
minikube service -n monitoring kube-prom-grafana --url
```

Bu komut size erişim URL'ini verecektir.

#### Yöntem 3: NodePort ile

```bash
# Service'i kontrol edin
kubectl get svc -n monitoring | grep grafana

# Minikube IP'yi alın
minikube ip
```

Sonra: `http://<minikube-ip>:<nodeport>`

## 🔍 Troubleshooting

### ❌ ERR_CONNECTION_REFUSED Hatası (localhost:3000 bağlanamıyor)

Bu hata genellikle şu sebeplerden olur:

#### 1. Cluster çalışmıyor - ÖNCE BUNU KONTROL EDİN!

```bash
# Minikube durumunu kontrol edin
minikube status

# Eğer çalışmıyorsa başlatın
minikube start --driver=docker

# Cluster'ın hazır olduğunu doğrulayın
kubectl get nodes
```

#### 2. Port-forward çalışmıyor

Port-forward komutunu **ayrı bir terminal penceresinde** çalıştırın ve **açık tutun**:

```bash
# Bu komutu çalıştırın ve terminali kapatmayın!
kubectl port-forward -n monitoring svc/kube-prom-grafana 3000:80
```

**ÖNEMLİ:** Port-forward komutu çalışırken terminali kapatırsanız bağlantı kesilir!

#### 3. Grafana kurulu değil

```bash
# Monitoring namespace var mı?
kubectl get namespaces | grep monitoring

# Grafana servisi var mı?
kubectl get svc -n monitoring | grep grafana

# Grafana pod'ları çalışıyor mu?
kubectl get pods -n monitoring | grep grafana
```

Eğer Grafana kurulu değilse, kurun:

```bash
kubectl create namespace monitoring
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
helm install kube-prom prometheus-community/kube-prometheus-stack -n monitoring

# Pod'ların hazır olmasını bekleyin (2-3 dakika)
kubectl get pods -n monitoring -w
```

### Monitoring namespace yoksa:

```bash
kubectl get namespaces
kubectl create namespace monitoring
```

### Grafana pod'u çalışmıyorsa:

```bash
kubectl get pods -n monitoring
kubectl describe pod <pod-adi> -n monitoring
kubectl logs <pod-adi> -n monitoring
```

### Secret bulunamıyorsa:

```bash
# Tüm secret'ları listeleyin
kubectl get secrets -n monitoring

# Helm release'i kontrol edin
helm list -n monitoring
```

## 📝 Notlar

- İlk girişte şifre değiştirmeniz istenebilir
- Port forward komutu çalışırken terminali açık tutun
- Grafana varsayılan portu: 3000
- Kullanıcı adı her zaman: `admin`

