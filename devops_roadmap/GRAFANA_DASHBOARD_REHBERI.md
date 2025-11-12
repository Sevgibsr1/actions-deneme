# Grafana Dashboard Import Rehberi

## 📊 Adım Adım Dashboard Import

### 1. Prometheus Data Source Kontrolü

Önce Prometheus data source'unun ekli olduğundan emin olun:

1. Sol menüden **"Connections"** → **"Data sources"** tıklayın
2. **"Prometheus"** listede görünüyor mu kontrol edin
3. Eğer yoksa:
   - **"Add new data source"** tıklayın
   - **"Prometheus"** seçin
   - **URL:** `http://prometheus-operated:9090`
   - **"Save & test"** ile test edin

**Not:** kube-prometheus-stack ile kurulduğunda Prometheus genellikle otomatik eklenir.

### 2. Dashboard Import Etme

#### Yöntem 1: Grafana.com'dan (Önerilen)

1. Sol menüden **"Dashboards"** → **"Import"** tıklayın
2. **"Grafana.com dashboard URL or ID"** alanına dashboard ID'sini girin
3. **"Load"** butonuna tıklayın
4. Dashboard bilgileri yüklenecek, **"Import"** tıklayın

#### Yöntem 2: JSON Dosyasından

1. Sol menüden **"Dashboards"** → **"Import"** tıklayın
2. **"Upload dashboard JSON file"** bölümüne JSON dosyasını sürükleyin
3. Veya **"Import via dashboard JSON model"** alanına JSON'u yapıştırın
4. **"Load"** → **"Import"** tıklayın

## 🎯 Önerilen Dashboard'lar

### Kubernetes Cluster Monitoring
- **ID:** `7249`
- **Açıklama:** Kubernetes cluster'ınızın genel durumunu gösterir
- **Link:** https://grafana.com/grafana/dashboards/7249

### Node Exporter Full
- **ID:** `1860`
- **Açıklama:** Node metrikleri (CPU, Memory, Disk, Network)
- **Link:** https://grafana.com/grafana/dashboards/1860

### Kubernetes / Compute Resources / Cluster
- **ID:** `15758`
- **Açıklama:** Cluster seviyesinde kaynak kullanımı
- **Link:** https://grafana.com/grafana/dashboards/15758

### Kubernetes / Compute Resources / Namespace (Pods)
- **ID:** `15759`
- **Açıklama:** Namespace ve Pod seviyesinde kaynak kullanımı
- **Link:** https://grafana.com/grafana/dashboards/15759

## 🚀 Hızlı Başlangıç

En popüler dashboard'u import etmek için:

1. Grafana'da **"Dashboards"** → **"Import"** tıklayın
2. **"Grafana.com dashboard URL or ID"** alanına: `7249` yazın
3. **"Load"** → **"Import"** tıklayın
4. Dashboard hazır! 🎉

## 📝 Ödev 7 İçin

Kubernetes roadmap'ine göre:
- ✅ Grafana erişim bilgisi (kayıtlı: `.grafana-credentials`)
- ✅ Dashboard import etme
- ⏳ CPU/Memory grafikleri gösteren ekran görüntüsü

**Teslim için:** Dashboard'u import ettikten sonra CPU ve Memory grafiklerinin göründüğü ekran görüntüsü alın.

## 🔍 Troubleshooting

### Dashboard'da veri görünmüyor

1. **Prometheus data source kontrolü:**
   - Connections → Data sources → Prometheus → "Test" butonuna tıklayın
   - "Data source is working" mesajı görünmeli

2. **Prometheus servisinin çalıştığını kontrol edin:**
   ```bash
   kubectl get pods -n monitoring | grep prometheus
   kubectl get svc -n monitoring | grep prometheus
   ```

3. **Dashboard'da time range kontrolü:**
   - Sağ üstteki zaman aralığını kontrol edin
   - "Last 5 minutes" veya "Last 1 hour" seçin

### Data source bulunamıyor

Prometheus'u manuel eklemek için:
1. Connections → Add new connection → Data sources
2. Prometheus seçin
3. URL: `http://prometheus-operated:9090`
4. Save & test

