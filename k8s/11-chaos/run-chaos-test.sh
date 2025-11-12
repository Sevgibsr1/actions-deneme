#!/bin/bash

# Chaos Engineering Ödevi - Otomatik Test Scripti
# Bu script tüm adımları otomatik olarak yapar

set -e

echo "🚀 Chaos Engineering Ödevi - Otomatik Test"
echo "=========================================="
echo ""

# 1. ChaosExperiment'i kur
echo "1️⃣  ChaosExperiment kuruluyor..."
if kubectl get chaosexperiment pod-delete &>/dev/null; then
    echo "   ✅ ChaosExperiment zaten kurulu"
else
    if [ -f "04-chaosexperiment.yaml" ]; then
        echo "   📦 Yerel manifest'ten kuruluyor..."
        kubectl apply -f 04-chaosexperiment.yaml
    else
        echo "   ⚠️  04-chaosexperiment.yaml bulunamadı, URL'den deneniyor..."
        kubectl apply -f https://hub.litmuschaos.io/api/chaos/master?file=charts/generic/pod-delete/experiment.yaml 2>/dev/null || {
            echo "   ❌ URL'den kurulum başarısız, lütfen 04-chaosexperiment.yaml dosyasını kontrol edin"
            exit 1
        }
    fi
    sleep 3
    kubectl get chaosexperiment pod-delete || {
        echo "   ❌ ChaosExperiment kurulumu başarısız"
        exit 1
    }
    echo "   ✅ ChaosExperiment kuruldu"
fi

echo ""

# 2. Mevcut ChaosEngine'i temizle
echo "2️⃣  Eski ChaosEngine temizleniyor..."
kubectl delete chaosengine nginx-pod-delete -n dev --ignore-not-found=true
sleep 2

echo ""

# 3. ChaosEngine'i başlat
echo "3️⃣  ChaosEngine başlatılıyor..."
kubectl apply -f 02-chaosengine.yaml

echo "   ⏳ ChaosEngine'in başlaması bekleniyor (30 saniye)..."
sleep 30

echo ""

# 4. Durum kontrolü
echo "4️⃣  Durum kontrolü:"
echo ""
echo "   ChaosEngine:"
kubectl get chaosengine nginx-pod-delete -n dev
echo ""
echo "   Pod'lar:"
kubectl get pods -n dev -l app=nginx
echo ""
echo "   Chaos Runner:"
kubectl get pods -n dev | grep chaos || echo "   Henüz oluşmadı"
echo ""

# 5. Gözlem süresi
echo "5️⃣  Gözlem yapılıyor (90 saniye)..."
echo "   Bu süre içinde pod'lar öldürülecek ve yeniden oluşturulacak"
echo ""

for i in {1..9}; do
    sleep 10
    echo "   ⏱️  ${i}0 saniye geçti..."
    kubectl get pods -n dev -l app=nginx --no-headers | wc -l | xargs echo "   Pod sayısı:"
done

echo ""

# 6. Final durum
echo "6️⃣  Final durum:"
echo ""
echo "   ChaosEngine durumu:"
kubectl describe chaosengine nginx-pod-delete -n dev | grep -A 5 "Status\|Phase" || kubectl get chaosengine nginx-pod-delete -n dev -o yaml | grep -A 10 "status:"
echo ""
echo "   Pod'lar:"
kubectl get pods -n dev -l app=nginx
echo ""
echo "   HPA:"
kubectl get hpa -n dev
echo ""
echo "   Son event'ler (pod kill ile ilgili):"
kubectl get events -n dev --sort-by='.lastTimestamp' | grep -i "kill\|delete\|terminat\|create" | tail -10
echo ""

echo "✅ Test tamamlandı!"
echo ""
echo "📊 Gözlem raporu için:"
echo "   kubectl describe chaosengine nginx-pod-delete -n dev"
echo "   kubectl get events -n dev --sort-by='.lastTimestamp' | grep -i kill"

