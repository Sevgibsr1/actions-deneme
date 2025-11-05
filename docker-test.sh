#!/bin/bash

# 🐳 Docker Test Script - Adım Adım Docker İşlemleri
# Bu script Docker image oluşturma, görüntüleme ve test işlemlerini yapar

echo "=========================================="
echo "🐳 Docker Test Script Başlatılıyor..."
echo "=========================================="
echo ""

# Renkli çıktı için
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 1. Docker'ın kurulu olup olmadığını kontrol et
echo -e "${BLUE}📋 ADIM 1: Docker kurulumu kontrol ediliyor...${NC}"
if ! command -v docker &> /dev/null; then
    echo "❌ Docker bulunamadı! Lütfen Docker'ı kurun."
    exit 1
fi
echo "✅ Docker kurulu: $(docker --version)"
echo ""

# 2. Docker servisinin çalışıp çalışmadığını kontrol et
echo -e "${BLUE}📋 ADIM 2: Docker servisi kontrol ediliyor...${NC}"
if ! docker ps &> /dev/null; then
    echo "❌ Docker servisi çalışmıyor! Lütfen Docker Desktop'ı başlatın."
    exit 1
fi
echo "✅ Docker servisi çalışıyor"
echo ""

# 3. Docker image oluştur
echo -e "${BLUE}📋 ADIM 3: Docker image oluşturuluyor...${NC}"
echo "Komut: docker build -t actions-deneme ."
echo ""
docker build -t actions-deneme .

if [ $? -ne 0 ]; then
    echo "❌ Image oluşturma başarısız!"
    exit 1
fi
echo -e "${GREEN}✅ Image başarıyla oluşturuldu!${NC}"
echo ""

# 4. Image'ları listele
echo -e "${BLUE}📋 ADIM 4: Docker image'ları listeleniyor...${NC}"
echo "Komut: docker images"
echo ""
docker images
echo ""

# 5. Belirli image'ı görüntüle
echo -e "${BLUE}📋 ADIM 5: actions-deneme image detayları...${NC}"
echo "Komut: docker images actions-deneme"
echo ""
docker images actions-deneme
echo ""

# 6. Image boyutu ve ID
echo -e "${BLUE}📋 ADIM 6: Image bilgileri...${NC}"
echo "Image Boyutu:"
docker images actions-deneme --format "{{.Size}}"
echo ""
echo "Image ID:"
docker images actions-deneme --format "{{.ID}}"
echo ""

# 7. Container çalıştır
echo -e "${BLUE}📋 ADIM 7: Container çalıştırılıyor (test)...${NC}"
echo "Komut: docker run --rm actions-deneme"
echo ""
docker run --rm actions-deneme
echo ""

# 8. Container içindeki dosyaları listele
echo -e "${BLUE}📋 ADIM 8: Container içindeki dosyalar...${NC}"
echo "Komut: docker run --rm actions-deneme ls -la /app"
echo ""
docker run --rm actions-deneme ls -la /app
echo ""

# 9. Özet
echo "=========================================="
echo -e "${GREEN}✅ Tüm işlemler tamamlandı!${NC}"
echo "=========================================="
echo ""
echo "📝 Öğrendiğiniz komutlar:"
echo "  - docker build -t actions-deneme .    # Image oluştur"
echo "  - docker images                        # Image'ları listele"
echo "  - docker run --rm actions-deneme      # Container çalıştır"
echo "  - docker run -it --rm actions-deneme bash  # Container içine gir"
echo ""

