#!/bin/bash

# Chaos Engineering - Gözlem Scripti
# Bu script chaos testi sırasında durumu izler

echo "🔍 Chaos Engineering - Gözlem Başlatılıyor"
echo "=========================================="
echo ""

# ChaosEngine durumu
echo "1️⃣  ChaosEngine Durumu:"
kubectl get chaosengine nginx-pod-delete -n dev
echo ""
kubectl describe chaosengine nginx-pod-delete -n dev | grep -A 10 "Status\|Phase" || kubectl describe chaosengine nginx-pod-delete -n dev | tail -20
echo ""

# Chaos runner pod'u
echo "2️⃣  Chaos Runner Pod'u:"
kubectl get pods -n dev | grep chaos || echo "   Henüz chaos runner pod'u oluşmadı"
echo ""

# Nginx pod'ları
echo "3️⃣  Nginx Pod'ları:"
kubectl get pods -n dev -l app=nginx -o wide
echo ""

# HPA durumu
echo "4️⃣  HPA Durumu:"
kubectl get hpa -n dev
echo ""

# Son event'ler
echo "5️⃣  Son Event'ler (son 10):"
kubectl get events -n dev --sort-by='.lastTimestamp' | tail -10
echo ""

# Chaos runner logları (varsa)
echo "6️⃣  Chaos Runner Logları (son 20 satır):"
RUNNER_POD=$(kubectl get pods -n dev -l app=chaos-runner -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
if [ -n "$RUNNER_POD" ]; then
    kubectl logs -n dev $RUNNER_POD --tail=20
else
    echo "   Chaos runner pod'u henüz oluşmadı"
fi
echo ""

echo "=========================================="
echo "💡 İzleme için ayrı terminal'lerde çalıştırın:"
echo "   Terminal 1: kubectl get pods -n dev -l app=nginx -w"
echo "   Terminal 2: kubectl get hpa -n dev -w"
echo "   Terminal 3: kubectl get events -n dev -w"
echo "   Terminal 4: kubectl logs -n dev -l app=chaos-runner -f"

