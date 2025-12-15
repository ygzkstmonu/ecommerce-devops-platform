# DevOps Cheat Sheet - Hızlı Hatırlatma

## 🐳 Docker Komutları

### Image İşlemleri

```bash
docker images                    # Image'ları listele
docker build -t isim:tag .      # Image build et
docker rmi image_id             # Image sil
Container İşlemleri
docker ps                       # Çalışan container'lar
docker ps -a                    # Tüm container'lar
docker run -d -p 5000:5000 image  # Container başlat
docker stop container_id        # Durdur
docker logs container_id        # Logları gör
docker exec -it container sh    # Container'a gir
Docker Compose
docker-compose up -d            # Başlat (detached)
docker-compose down             # Durdur ve sil
docker-compose ps               # Container'ları listele
docker-compose logs -f          # Logları izle
docker-compose build            # Image'ları yeniden build et

📦 Dockerfile Anatomisi

FROM node:18-alpine             # Base image
WORKDIR /app                    # Çalışma dizini
COPY package.json .             # Dependency dosyası
RUN npm install                 # Build-time komut
COPY . .                        # Uygulama kodu
EXPOSE 5000                     # Port bilgisi
CMD ["npm", "start"]            # Runtime komutu

🌐 Git Komutları

git status                      # Değişiklikleri gör
git branch                      # Branch'leri listele
git checkout -b feature/x       # Yeni branch
git add .                       # Tümünü stage et
git commit -m "message"         # Commit
git push origin branch          # Push
git checkout main               # Main'e geç
git pull origin main            # Güncelle

🔧 Proje Yapısı Hatırlatma

ecommerce-devops-platform/
├── backend/
│   ├── Dockerfile              # Backend container tarifi
│   ├── server.js               # Express API
│   └── package.json            # Dependencies
├── frontend/
│   ├── Dockerfile              # Frontend container tarifi
│   └── index.html              # UI
├── docker-compose.yml          # Tüm servisleri orkestre et
├── scripts/
│   └── backup.sh               # Backup script'i
└── README.md

💡 Önemli Konseptler

Port Mapping: -p 3000:80
3000: Host (bilgisayarınız)
80: Container içi
Volume: Data kalıcılığı
volumes:
  - ./data:/app/data
Network: Container'lar arası iletişim
networks:
  - app-network

🚨 Sık Karşılaşılan Sorunlar

Container sürekli restart oluyor
docker logs container_name      # Hata mesajını gör
Port zaten kullanımda
# Windows'ta portu kontrol et
netstat -ano | findstr :5000
Image build etmiyor
# Cache'siz build et
docker build --no-cache -t image:tag .

📅 1-2 HAFTA SONRA GERİ DÖNÜŞ PLANI
# 1. Projeyi aç
cd ~/ecommerce-devops-platform

# 2. Cheat sheet'i oku
cat docs/CHEATSHEET.md

# 3. Projeyi başlat
docker-compose up -d

# 4. "Hmm, şu kısım neydi?" diye düşünürseniz
git log --oneline          # Commit history'ye bakın
cat docs/CHEATSHEET.md     # Cheat sheet'e bakın


## 🔄 GitHub Actions CI/CD

### Workflow Yapısı

```yaml
name: Workflow Adı              # GitHub Actions'da görünen isim

on:                             # Tetikleyiciler
  push:
    branches: [main]            # Hangi branch'e push olunca?
  pull_request:
    branches: [main]            # Hangi branch'e PR açılınca?

jobs:                           # Yapılacak işler
  job-name:                     # İş adı (istediğiniz isim)
    runs-on: ubuntu-latest      # Hangi OS'te çalışsın?
    needs: previous-job         # Bu job başarılıysa çalış (opsiyonel)
    
    steps:                      # Adımlar
      - name: Step name         # Adım adı
        uses: action/name@v3    # Hazır action kullan
        
      - name: Run command       # Terminal komutu çalıştır
        run: npm install
        
      - name: Multi-line        # Çok satırlı komut
        run: |
          echo "Line 1"
          echo "Line 2"

Yaygın Hazır Actions
# Kod checkout (her job'da ilk adım)
- uses: actions/checkout@v3

# Node.js kur
- uses: actions/setup-node@v3
  with:
    node-version: '18'

# Python kur
- uses: actions/setup-python@v3
  with:
    python-version: '3.10'

# Docker login
- uses: docker/login-action@v2
  with:
    username: ${{ secrets.DOCKER_USERNAME }}
    password: ${{ secrets.DOCKER_PASSWORD }}

Tetikleyici Örnekleri
# Sadece main branch'e push
on:
  push:
    branches: [main]

# Birden fazla branch
on:
  push:
    branches: [main, develop, staging]

# Tag push
on:
  push:
    tags:
      - 'v*'

# Schedule (cron)
on:
  schedule:
    - cron: '0 0 * * *'  # Her gece 00:00

# Manuel trigger
on:
  workflow_dispatch:
Environment Variables & Secrets
env:                            # Global env variables
  NODE_ENV: production

jobs:
  build:
    env:                        # Job-level env
      API_URL: https://api.example.com
    
    steps:
      - name: Use secret
        run: echo "${{ secrets.API_KEY }}"  # GitHub Secrets
      
      - name: Use env
        run: echo "${{ env.NODE_ENV }}"

Conditional Steps
steps:
  - name: Run only on main
    if: github.ref == 'refs/heads/main'
    run: echo "Main branch!"
  
  - name: Run only on PR
    if: github.event_name == 'pull_request'
    run: echo "This is a PR!"
  
  - name: Run on failure
    if: failure()
    run: echo "Previous step failed!"
Job Dependencies
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - run: npm test
  
  build:
    needs: test               # test başarılı olmalı
    runs-on: ubuntu-latest
    steps:
      - run: docker build
  
  deploy:
    needs: [test, build]      # İkisi de başarılı olmalı
    runs-on: ubuntu-latest
    steps:
      - run: kubectl apply

Artifacts (Dosya Paylaşımı)
jobs:
  build:
    steps:
      - run: npm run build
      
      # Artifact upload (jobs arası paylaşım)
      - uses: actions/upload-artifact@v3
        with:
          name: dist-files
          path: dist/
  
  deploy:
    needs: build
    steps:
      # Artifact download
      - uses: actions/download-artifact@v3
        with:
          name: dist-files

Matrix Strategy (Paralel Test)
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        node-version: [14, 16, 18]  # 3 job paralel çalışır
        os: [ubuntu-latest, macos-latest]
    
    steps:
      - uses: actions/setup-node@v3
        with:
          node-version: ${{ matrix.node-version }}
      - run: npm test

Debugging
# Debug modunda çalıştırma
steps:
  - name: Debug info
    run: |
      echo "Event: ${{ github.event_name }}"
      echo "Ref: ${{ github.ref }}"
      echo "SHA: ${{ github.sha }}"
      echo "Actor: ${{ github.actor }}"
      env  # Tüm env variables

Docker Build & Push
jobs:
  docker:
    steps:
      - uses: actions/checkout@v3
      
      - name: Build image
        run: docker build -t myapp:${{ github.sha }} .
      
      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}
      
      - name: Push image
        run: |
          docker tag myapp:${{ github.sha }} user/myapp:latest
          docker push user/myapp:latest

Caching (Hızlandırma)
steps:
  - uses: actions/checkout@v3
  
  # Node modules cache
  - uses: actions/cache@v3
    with:
      path: ~/.npm
      key: ${{ runner.os }}-node-${{ hashFiles('**/package-lock.json') }}
  
  - run: npm install  # Cache'den gelirse hızlı

🎯 CI/CD Best Practices
Her commit'te çalıştır - Erken hata tespiti
Testler geçmezse merge etme - Branch protection rules
Build başarısızsa deploy etme - needs: kullan
Secrets kullan - API key'leri kodda bırakma
Cache kullan - npm, pip paketlerini cache'le
Matrix test - Birden fazla versiyonda test et
Artifacts kullan - Jobs arası dosya paylaş
Status badge ekle - README'de göster

📊 GitHub Actions Terimleri

Workflow: YAML dosyası, tüm süreç

Job: Bağımsız görev (paralel çalışabilir)

Step: Job içindeki tek adım

Action: Hazır kod parçası (uses:)

Runner: Sanal makine (ubuntu, windows, macos)

Artifact: Jobs arası paylaşılan dosya

Secret: Güvenli değişken (şifreler, token'lar)
🔍 Workflow Durumları
🟡 Queued: Sırada bekliyor
🔵 In progress: Çalışıyor
✅ Success: Başarılı
❌ Failure: Başarısız
⚪ Cancelled: İptal edildi
⏭️ Skipped: Atlandı (conditional)
