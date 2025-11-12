# 🚀 GitHub Actions Öğrenme Rehberi - DevOps Stajyeri İçin

## 📚 GitHub Actions Nedir?

**GitHub Actions**, GitHub'da CI/CD (Continuous Integration / Continuous Deployment) yapmanızı sağlayan bir otomasyon platformudur.

### Temel Kavramlar:

1. **Workflow (İş Akışı)**: Otomasyonu tarif eden dosya
   - `.github/workflows/` klasöründe `.yml` veya `.yaml` uzantılı dosyalar
   - Her workflow bir otomasyon senaryosudur

2. **Job (İş)**: Bir workflow içinde çalışan görevler
   - Birden fazla job olabilir
   - Job'lar paralel veya sırayla çalışabilir

3. **Step (Adım)**: Job içinde çalışan küçük görevler
   - Her step bir komut çalıştırır veya bir action kullanır

4. **Action**: Hazır kullanılabilen eylemler
   - `actions/checkout@v3` gibi hazır action'lar
   - Kendi action'larınızı da yazabilirsiniz

5. **Runner**: Workflow'ların çalıştığı makine
   - GitHub-hosted (GitHub'ın sağladığı) veya self-hosted (kendi sunucunuz)

---

## 📁 Dosya Yapısı

```
projeniz/
├── .github/
│   └── workflows/
│       └── python-test-new.yml  ← Workflow dosyanız
├── hello.py
├── test_bol.py
└── ...
```

**Önemli**: Workflow dosyaları `.github/workflows/` klasöründe olmalıdır!

---

## 🔍 Mevcut Workflow'unuzu Anlama

Projenizdeki `python-test-new.yml` dosyasını adım adım açıklayalım:

### 1️⃣ Workflow Adı ve Tetikleyici

```yaml
name: Python Test Workflow (Genişletilmiş)

on:
  push:
    branches:
      - main
```

**Açıklama:**
- `name`: Workflow'un adı (GitHub'da görünen isim)
- `on`: Workflow'un ne zaman çalışacağını belirtir
- `push`: Kod push edildiğinde
- `branches: - main`: Sadece `main` branch'ine push edildiğinde

**Diğer Tetikleyici Örnekleri:**
```yaml
# Pull request oluşturulduğunda
on:
  pull_request:
    branches: [main]

# Manuel olarak çalıştırma
on:
  workflow_dispatch:

# Her 5 dakikada bir (cron)
on:
  schedule:
    - cron: '*/5 * * * *'

# Birden fazla tetikleyici
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  workflow_dispatch:
```

### 2️⃣ Job Tanımı

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
```

**Açıklama:**
- `jobs`: Tüm job'ları tanımlar
- `test`: Job'un adı (istediğiniz ismi verebilirsiniz)
- `runs-on`: Hangi işletim sisteminde çalışacağını belirtir
  - `ubuntu-latest`: En son Ubuntu versiyonu
  - `windows-latest`: Windows
  - `macos-latest`: macOS

### 3️⃣ Steps (Adımlar)

#### Step 1: Kodu Alma

```yaml
- name: Kodu al
  uses: actions/checkout@v3
```

**Açıklama:**
- `name`: Step'in adı (loglarda görünen isim)
- `uses`: Hazır bir action kullan
- `actions/checkout@v3`: GitHub'dan kodunuzu alan resmi action
- **Neden gerekli?** Runner'da başlangıçta boş bir klasör vardır, kodunuzu almak için bu action gerekir

#### Step 2: Python Ortamını Kurma

```yaml
- name: Python ortamını kur
  uses: actions/setup-python@v3
  with:
    python-version: '3.10'
```

**Açıklama:**
- `actions/setup-python@v3`: Python'u yükleyen resmi action
- `with`: Action'a parametre gönder
- `python-version`: Hangi Python versiyonunu yükleyeceğini belirtir

#### Step 3: Bağımlılıkları Yükleme

```yaml
- name: Bağımlılıkları yükle
  run: |
    python -m pip install --upgrade pip
    pip install pytest pytest-cov flake8
```

**Açıklama:**
- `run`: Komut çalıştır (terminal komutları gibi)
- `|`: Çok satırlı komut için kullanılır
- `pip install`: Python paketlerini yükler

**Tek satırlı komut:**
```yaml
- name: Tek satır
  run: echo "Merhaba"
```

#### Step 4: Lint Kontrolü

```yaml
- name: Lint kontrolü (flake8)
  run: |
    echo "🧹 Kod kalitesi kontrolü başlatılıyor..."
    flake8 . --count --select=E9,F63,F7,F82 --show-source --statistics
    flake8 . --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
```

**Açıklama:**
- `flake8`: Python kod kalitesi kontrolü yapan araç
- `--exit-zero`: Hata olsa bile workflow'u durdurmaz
- Lint: Kod stilini ve hataları kontrol eder

#### Step 5: Test Çalıştırma

```yaml
- name: Testleri çalıştır ve coverage raporu oluştur
  run: |
    echo "🚀 Testler başlatılıyor..."
    pytest --cov=. --cov-report=term-missing --cov-report=xml
```

**Açıklama:**
- `pytest`: Python test framework'ü
- `--cov=.`: Coverage (test kapsamı) raporu oluştur
- `--cov-report=term-missing`: Terminal'de eksik satırları göster
- `--cov-report=xml`: XML formatında rapor oluştur

#### Step 6: Artifact Yükleme

```yaml
- name: Coverage raporunu yükle (Artifact)
  uses: actions/upload-artifact@v4
  with:
    name: coverage-report
    path: coverage.xml
```

**Açıklama:**
- `actions/upload-artifact@v4`: Dosya kaydetme action'ı
- `name`: Artifact'ın adı
- `path`: Hangi dosyayı kaydedeceğini belirtir
- **Artifact nedir?** Workflow çalıştıktan sonra indirebileceğiniz dosyalar

#### Step 7-8: Docker İşlemleri

```yaml
- name: Docker kurulumu
  uses: docker/setup-buildx-action@v3

- name: Docker image oluştur
  run: docker build -t actions-deneme .

- name: Docker container'ı test et
  run: docker run actions-deneme
```

**Açıklama:**
- `docker/setup-buildx-action@v3`: Docker'ı hazırlayan action
- `docker build`: Docker image oluştur
- `docker run`: Docker container çalıştır

#### Step 9: Bildirim Gönderme

```yaml
- name: Bildirim gönder (E-posta ve Slack)
  if: always()
  run: |
    # Slack ve E-posta gönderme kodları
```

**Açıklama:**
- `if: always()`: Her durumda çalışır (başarılı veya başarısız olsun)
- `secrets.SLACK_WEBHOOK_URL`: GitHub Secrets'tan alınan gizli bilgi

**Diğer `if` örnekleri:**
```yaml
if: success()    # Sadece başarılı olursa
if: failure()    # Sadece başarısız olursa
if: always()     # Her zaman
```

---

## 🔐 GitHub Secrets (Gizli Bilgiler)

Workflow'larda şifre, API key gibi hassas bilgileri saklamak için **Secrets** kullanılır.

### Secrets Nasıl Eklenir?

1. GitHub repository'nize gidin
2. **Settings** → **Secrets and variables** → **Actions**
3. **New repository secret** tıklayın
4. İsim ve değer girin

### Secrets Nasıl Kullanılır?

```yaml
run: echo ${{ secrets.MY_SECRET }}
```

**Örnek:**
```yaml
- name: Slack bildirimi
  run: |
    curl -X POST ${{ secrets.SLACK_WEBHOOK_URL }} \
      --data '{"text":"Test tamamlandı"}'
```

**⚠️ ÖNEMLİ**: Secrets'ları asla log'lara yazdırmayın!

---

## 🎯 YAML Syntax Temelleri

GitHub Actions YAML formatında yazılır. Temel kurallar:

### 1. Girintiler (Indentation)

```yaml
# ✅ DOĞRU (2 boşluk veya tab)
name: Test
on: push

# ❌ YANLIŞ (tutarsız girintiler)
name: Test
  on: push
```

### 2. String Değerler

```yaml
# Tırnak işareti gerekmez (basit stringler için)
name: Test Workflow

# Tırnak işareti gerekir (özel karakterler varsa)
name: "Test Workflow - v1.0"
```

### 3. Listeler (Arrays)

```yaml
# Kısa format
branches: [main, develop]

# Uzun format
branches:
  - main
  - develop
```

### 4. Çok Satırlı Komutlar

```yaml
# | kullan (satır sonlarını korur)
run: |
  echo "Satır 1"
  echo "Satır 2"

# > kullan (satır sonlarını boşluğa çevirir)
run: >
  echo "Satır 1"
  echo "Satır 2"
```

---

## 📊 Workflow Yapısı Özeti

```yaml
name: Workflow Adı          # Workflow'un adı

on:                         # Tetikleyiciler
  push:
    branches: [main]

jobs:                       # İşler
  job-adı:                  # Job adı
    runs-on: ubuntu-latest  # Runner
    
    steps:                  # Adımlar
      - name: Adım 1        # Step adı
        uses: action/...    # Action kullan
        
      - name: Adım 2
        run: komut          # Komut çalıştır
```

---

## 🛠️ Yaygın Kullanılan Actions

### 1. Checkout (Kodu Alma)

```yaml
- uses: actions/checkout@v3
```

### 2. Setup Python

```yaml
- uses: actions/setup-python@v3
  with:
    python-version: '3.10'
```

### 3. Setup Node.js

```yaml
- uses: actions/setup-node@v3
  with:
    node-version: '18'
```

### 4. Upload Artifact

```yaml
- uses: actions/upload-artifact@v4
  with:
    name: my-artifact
    path: dosya.yml
```

### 5. Download Artifact

```yaml
- uses: actions/download-artifact@v4
  with:
    name: my-artifact
```

### 6. Docker Setup

```yaml
- uses: docker/setup-buildx-action@v3
```

---

## 💡 Pratik Örnekler

### Örnek 1: Basit Test Workflow

```yaml
name: Basit Test

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Python kur
        uses: actions/setup-python@v3
        with:
          python-version: '3.10'
      
      - name: Test çalıştır
        run: pytest
```

### Örnek 2: Birden Fazla Job

```yaml
name: Test ve Build

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: pytest
  
  build:
    runs-on: ubuntu-latest
    needs: test  # test job'u bitince çalışır
    steps:
      - uses: actions/checkout@v3
      - run: docker build -t myapp .
```

### Örnek 3: Matris Build (Birden Fazla Versiyon)

```yaml
name: Multi-version Test

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ['3.9', '3.10', '3.11']
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Python ${{ matrix.python-version }} kur
        uses: actions/setup-python@v3
        with:
          python-version: ${{ matrix.python-version }}
      
      - name: Test çalıştır
        run: pytest
```

**Açıklama:**
- `strategy.matrix`: Birden fazla versiyon için test yapar
- `${{ matrix.python-version }}`: Matrix değerini kullanır
- Bu örnekte 3 farklı Python versiyonu için test çalışır

### Örnek 4: Manuel Çalıştırma (Workflow Dispatch)

```yaml
name: Manuel Test

on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Hangi environment?'
        required: true
        default: 'staging'
        type: choice
        options:
          - staging
          - production

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Environment seçildi
        run: echo "Seçilen: ${{ inputs.environment }}"
```

**Açıklama:**
- `workflow_dispatch`: Manuel olarak çalıştırılabilir
- `inputs`: Kullanıcıdan bilgi alır
- GitHub'da "Actions" sekmesinden manuel çalıştırabilirsiniz

---

## 🔍 Debug ve Hata Ayıklama

### 1. Workflow Loglarını Görme

1. GitHub repository'nize gidin
2. **Actions** sekmesine tıklayın
3. Workflow çalıştırmasını seçin
4. Job'u tıklayın
5. Step'i tıklayın → Logları görürsünüz

### 2. Yaygın Hatalar

#### YAML Syntax Hatası

```yaml
# ❌ YANLIŞ (girinti hatası)
jobs:
  test:
  runs-on: ubuntu-latest  # Girinti yanlış!

# ✅ DOĞRU
jobs:
  test:
    runs-on: ubuntu-latest  # Doğru girinti
```

#### Action Versiyonu Hatası

```yaml
# ❌ YANLIŞ (eski versiyon)
uses: actions/checkout@v1  # v1 artık desteklenmiyor

# ✅ DOĞRU
uses: actions/checkout@v3  # Güncel versiyon
```

#### Secret Bulunamadı

```yaml
# ❌ YANLIŞ (secret yoksa hata verir)
run: echo ${{ secrets.NONEXISTENT }}

# ✅ DOĞRU (varsa göster, yoksa boş)
run: echo ${ secrets.NONEXISTENT || '' }
```

### 3. Debug İpuçları

```yaml
# Debug için echo kullan
- name: Debug
  run: |
    echo "Değişken: ${{ env.MY_VAR }}"
    echo "Mevcut dizin: $(pwd)"
    echo "Dosyalar: $(ls -la)"

# Step Context kullan
- name: Debug Context
  run: |
    echo "Runner OS: ${{ runner.os }}"
    echo "GitHub Ref: ${{ github.ref }}"
    echo "GitHub SHA: ${{ github.sha }}"
```

---

## 📈 Workflow İyileştirmeleri

### 1. Caching (Önbellekleme)

```yaml
- name: Cache pip packages
  uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('**/requirements.txt') }}
    restore-keys: |
      ${{ runner.os }}-pip-
```

**Faydası:** Paketler her seferinde indirilmez, daha hızlı çalışır

### 2. Paralel Job'lar

```yaml
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - run: flake8 .
  
  test:
    runs-on: ubuntu-latest
    steps:
      - run: pytest
  
  build:
    runs-on: ubuntu-latest
    steps:
      - run: docker build .
```

**Faydası:** Job'lar paralel çalışır, toplam süre kısalır

### 3. Timeout (Zaman Aşımı)

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    timeout-minutes: 30  # 30 dakika sonra durdur
    steps:
      - run: pytest
```

---

## 📊 GitHub Actions Komutları Özeti

| Kavram | Açıklama |
|--------|----------|
| `workflow` | Otomasyon dosyası (.yml) |
| `job` | İş birimi (görev) |
| `step` | Job içindeki küçük adım |
| `action` | Hazır kullanılabilen eylem |
| `runner` | Workflow'un çalıştığı makine |
| `secret` | Gizli bilgi saklama |
| `artifact` | Dosya kaydetme/indirme |
| `matrix` | Birden fazla versiyon için test |

---

## 🎓 Öğrenme Hedefleri

✅ GitHub Actions'ın ne olduğunu anlama
✅ Workflow dosyası oluşturma
✅ Job ve Step kavramlarını anlama
✅ Hazır action'ları kullanma
✅ Secrets kullanma
✅ Artifact yükleme/indirme
✅ Workflow'u debug etme
✅ CI/CD pipeline'ı oluşturma

---

## 🚀 Sonraki Adımlar

1. **Daha fazla action keşfet**: [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
2. **Self-hosted runner**: Kendi sunucunuzda runner çalıştırma
3. **Composite actions**: Kendi action'larınızı oluşturma
4. **Reusable workflows**: Workflow'ları tekrar kullanılabilir hale getirme
5. **Environments**: Staging, production gibi ortamlar yönetme
6. **Deployment**: Otomatik deployment yapma

---

## 💡 İpuçları

1. **Workflow dosyalarını test edin**: Küçük değişiklikler yapıp test edin
2. **Logları okuyun**: Hataları anlamak için logları inceleyin
3. **Action versiyonlarını güncel tutun**: Eski versiyonlar güvenlik riski olabilir
4. **Secrets kullanın**: Şifreleri asla kod içine yazmayın
5. **Caching kullanın**: Build sürelerini kısaltmak için cache ekleyin
6. **YAML syntax'ına dikkat edin**: Girintiler çok önemli!

---

## 📚 Kaynaklar

- [GitHub Actions Dokümantasyonu](https://docs.github.com/en/actions)
- [GitHub Actions Marketplace](https://github.com/marketplace?type=actions)
- [YAML Syntax Rehberi](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions)

---

**Hazırlayan**: DevOps Stajyeri için öğrenme rehberi
**Tarih**: 2024

