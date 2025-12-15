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

---

## 🗄️ Database Testing & CI/CD Integration

### PostgreSQL Service Container (GitHub Actions)

CI/CD pipeline'da veritabanı testleri için PostgreSQL service container kullanımı:

```yaml
name: CI Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest

    services:
      postgres:                          # Service adı
        image: postgres:15-alpine        # PostgreSQL image
        env:
          POSTGRES_USER: devops          # Kullanıcı adı
          POSTGRES_PASSWORD: devops123   # Şifre
          POSTGRES_DB: ecommerce         # Database adı
        ports:
          - 5432:5432                    # Port mapping
        options: >-                      # Health check ayarları
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install dependencies
        working-directory: ./backend
        run: npm install

      # Database schema'yı oluştur
      - name: Initialize database schema
        env:
          PGPASSWORD: devops123          # psql için şifre
        run: |
          psql -h localhost -U devops -d ecommerce -f backend/database/init.sql

      # Database testlerini çalıştır
      - name: Run database tests
        working-directory: ./backend
        env:
          DB_HOST: localhost             # Service container'a bağlan
          DB_PORT: 5432
          DB_USER: devops
          DB_PASSWORD: devops123
          DB_NAME: ecommerce
        run: npm test
```

**Service Container Nasıl Çalışır?**

1. **Service Başlatma**: GitHub Actions, test job'ı başlatmadan önce PostgreSQL container'ı ayağa kaldırır
2. **Health Check**: `pg_isready` komutu ile PostgreSQL'in hazır olduğunu bekler
3. **Port Mapping**: Container'ın 5432 portu, runner'ın 5432 portuna map edilir
4. **Test Execution**: Testler `localhost:5432` üzerinden PostgreSQL'e bağlanır
5. **Cleanup**: Job bitince service container otomatik olarak silinir

### Integration Test Örneği (db.test.js)

```javascript
const pool = require('../database/db');  // Connection pool

async function testDatabaseConnection() {
  try {
    // ✅ TEST 1: Bağlantı Kontrolü
    const result = await pool.query('SELECT NOW()');
    console.log('✅ Database connection successful');
    console.log('DB Time:', result.rows[0].now);

    // ✅ TEST 2: Tablo Varlık Kontrolü
    const tableCheck = await pool.query(`
      SELECT EXISTS (
        SELECT FROM information_schema.tables
        WHERE table_name = 'products'
      );
    `);

    if (tableCheck.rows[0].exists) {
      console.log('✅ Products table exists');
    } else {
      throw new Error('Products table not found');
    }

    // ✅ TEST 3: Data Validasyon
    const countResult = await pool.query('SELECT COUNT(*) FROM products');
    const count = parseInt(countResult.rows[0].count);

    if (count >= 5) {
      console.log(`✅ Sample data exists (${count} products)`);
    } else {
      throw new Error(`Expected at least 5 products, found ${count}`);
    }

    console.log('🎉 All database tests passed!');
    process.exit(0);  // ✅ Başarılı exit code

  } catch (error) {
    console.error('❌ Database test failed:', error.message);
    process.exit(1);  // ❌ Hata exit code
  }
}

testDatabaseConnection();
```

### Async/Await ile Database İşlemleri

**Connection Pool Nedir?**
- Veritabanına her seferinde yeni bağlantı açmak yerine, hazır bağlantı havuzu kullanır
- Performans artışı sağlar (bağlantı açma/kapama maliyeti yok)
- Aynı anda birden fazla query çalıştırabilir

```javascript
// db.js - Connection Pool Konfigürasyonu
const { Pool } = require('pg');

const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: process.env.DB_PORT || 5432,
  user: process.env.DB_USER || 'devops',
  password: process.env.DB_PASSWORD || 'devops123',
  database: process.env.DB_NAME || 'ecommerce',
  max: 20,                    // Max 20 bağlantı
  idleTimeoutMillis: 30000,   // 30 saniye boşta kalırsa kapat
  connectionTimeoutMillis: 2000  // 2 saniye içinde bağlan
});

module.exports = pool;
```

**Async/Await Kullanımı:**

```javascript
// ❌ YANLIŞ - Callback Hell
pool.query('SELECT * FROM products', (err, result) => {
  if (err) {
    console.error(err);
  } else {
    pool.query('SELECT * FROM users', (err2, result2) => {
      // İç içe callback'ler...
    });
  }
});

// ✅ DOĞRU - Async/Await
app.get('/api/products', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM products');
    res.json({
      success: true,
      count: result.rows.length,
      data: result.rows
    });
  } catch (error) {
    console.error('Database error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to fetch products'
    });
  }
});
```

### Exit Codes (Çıkış Kodları)

**Neden Önemli?**
- CI/CD pipeline'lar exit code'a bakarak success/failure kararı verir
- `0` = Başarılı, `1` (veya 0 dışı) = Hata

```javascript
// Test başarılıysa
process.exit(0);   // ✅ GitHub Actions bu adımı başarılı sayar

// Test başarısızsa
process.exit(1);   // ❌ GitHub Actions bu adımı başarısız sayar, pipeline durur
```

**CI Pipeline'da Kullanımı:**

```yaml
- name: Run database tests
  run: npm test           # npm test, db.test.js'i çalıştırır
  # Eğer db.test.js exit(1) dönerse:
  # → Bu step ❌ FAIL olur
  # → Sonraki step'ler çalışmaz (needs: test varsa)
  # → PR merge edilemez (branch protection varsa)
```

### Database Test Senaryoları

**1. Connection Test (Bağlantı Testi)**
```javascript
const result = await pool.query('SELECT NOW()');
// PostgreSQL'e basit bir query gönder
// Eğer cevap gelirse → Bağlantı ✅
// Eğer hata fırlatırsa → Bağlantı ❌
```

**2. Table Existence (Tablo Varlık Kontrolü)**
```javascript
const tableCheck = await pool.query(`
  SELECT EXISTS (
    SELECT FROM information_schema.tables
    WHERE table_name = 'products'
  );
`);
// information_schema: PostgreSQL'in kendi metadata sistemi
// Tablo varsa → exists: true
// Tablo yoksa → exists: false
```

**3. Data Validation (Veri Doğrulama)**
```javascript
const countResult = await pool.query('SELECT COUNT(*) FROM products');
const count = parseInt(countResult.rows[0].count);
// COUNT(*): Tablodaki satır sayısı
// En az 5 satır olmalı → init.sql'de 5 product ekledik
```

### Real-World Scenario (Gerçek Hayat Senaryosu)

**Durum:** Developer yeni bir özellik geliştiriyor, yanlışlıkla `products` tablosunu `product` olarak yazmış.

**CI Pipeline Olmadan:**
1. Developer kodu push eder
2. Kod production'a gider
3. Uygulama crash eder → `products` tablosu bulunamıyor
4. 🔥 Production'da sorun!

**CI Pipeline İle:**
1. Developer kodu push eder
2. GitHub Actions tetiklenir
3. Database testleri çalışır
4. `products` tablosu bulunamıyor → ❌ Test FAIL
5. PR merge edilemez
6. Developer sorunu görür ve düzeltir
7. ✅ Production güvende!

### Integration Test Output Örneği

**✅ Başarılı Test:**
```
✅ Database connection successful
DB Time: 2025-12-15T10:30:45.123Z
✅ Products table exists
✅ Sample data exists (5 products)
🎉 All database tests passed!
Exit code: 0
```

**❌ Başarısız Test:**
```
✅ Database connection successful
DB Time: 2025-12-15T10:30:45.123Z
❌ Database test failed: Products table not found
Exit code: 1
```

### PostgreSQL Komutları (psql)

```bash
# Database'e bağlan
psql -h localhost -U devops -d ecommerce

# SQL dosyası çalıştır (CI'da kullanılır)
psql -h localhost -U devops -d ecommerce -f init.sql

# Şifre environment variable'dan
PGPASSWORD=devops123 psql -h localhost -U devops -d ecommerce

# Tabloları listele
\dt

# Tablo yapısını gör
\d products

# Query çalıştır ve çık
psql -h localhost -U devops -d ecommerce -c "SELECT COUNT(*) FROM products"
```

### Test-Driven CI/CD Pipeline Akışı

```
1. Developer: Code yaz + Push
                ↓
2. GitHub Actions: Workflow tetikle
                ↓
3. Service Container: PostgreSQL başlat
                ↓
4. Init Database: Schema oluştur (init.sql)
                ↓
5. Run Tests: db.test.js çalıştır
                ↓
          ✅ PASS?    ❌ FAIL?
           ↓            ↓
6. Backend Test    PR Merge Block
           ↓            ↓
7. Docker Build    Developer Fix
           ↓            ↓
8. Deploy Ready    Tekrar Test
```

### Key Takeaways (Önemli Noktalar)

✅ **Service Containers:** CI/CD'de geçici veritabanı için kullan
✅ **Integration Tests:** Gerçek database ile test et, mock kullanma
✅ **Exit Codes:** 0 = success, 1 = failure → CI/CD buna göre karar verir
✅ **Async/Await:** Database işlemleri her zaman async (callback hell'den kaç)
✅ **Connection Pool:** Her query için yeni bağlantı açma, pool kullan
✅ **Health Checks:** Service container hazır olana kadar bekle
✅ **Environment Variables:** Credentials'ı kodda bırakma, env'den al
✅ **Schema Initialization:** CI'da init.sql ile database'i hazırla

---

## 📊 Prometheus & Grafana Monitoring

### Prometheus Konfigürasyonu Nasıl Çalışır?

**Akış:**
```
1. Sen config yazıyorsun:
   ./monitoring/prometheus.yml (Host)

2. Docker mount ediyor:
   ./monitoring/prometheus.yml → /etc/prometheus/prometheus.yml (Container)

3. Prometheus başlarken okuyor:
   --config.file=/etc/prometheus/prometheus.yml

4. Target'ları buluyor:
   Docker Network DNS ile (backend:5000 → container IP)

5. Metrikleri topluyor:
   HTTP GET http://backend:5000/metrics (her 15 saniyede)
```

### prometheus.yml Anatomisi

```yaml
global:
  scrape_interval: 15s      # Her 15 saniyede bir metrik topla
  evaluation_interval: 15s  # Alert kurallarını ne sıklıkla kontrol et

scrape_configs:
  - job_name: 'backend'           # Job adı (Prometheus UI'da görünür)
    static_configs:
      - targets: ['backend:5000'] # Docker DNS ile backend container'ı bul
    metrics_path: '/metrics'      # Hangi endpoint'ten metrik çek
```

**DevOps Kararları:**
- `scrape_interval`: Production'da 15-30s (daha sık = daha fazla CPU/network)
- `targets`: Docker Compose'da container adı, Kubernetes'te service discovery
- `metrics_path`: Default `/metrics` ama değiştirilebilir (örn: `/actuator/prometheus`)

### Docker Network DNS

**Container'lar birbirini nasıl buluyor?**

```yaml
# docker-compose.yml
networks:
  app-network:
    driver: bridge

services:
  prometheus:
    networks:
      - app-network
  backend:
    networks:
      - app-network
```

**Docker otomatik DNS oluşturur:**
```
Container Adı    →   IP Adresi
─────────────────────────────
backend          →   172.18.0.3
prometheus       →   172.18.0.4
grafana          →   172.18.0.5
```

**Prometheus container'ından:**
```bash
# DNS lookup
nslookup backend
# → 172.18.0.3

# HTTP request
wget http://backend:5000/metrics
# → Prometheus formatında metrikler!
```

### Grafana Provisioning

**Datasource Otomatik Yükleme:**
```yaml
# monitoring/grafana/provisioning/datasources/prometheus.yml
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    access: proxy          # Grafana server üzerinden bağlan (güvenli)
    url: http://prometheus:9090
    isDefault: true        # Default datasource olsun
    editable: false        # Production'da UI'dan değiştirilemez
```

**Dashboard Otomatik Yükleme:**
```yaml
# monitoring/grafana/provisioning/dashboards/dashboard.yml
apiVersion: 1
providers:
  - name: 'Default'
    folder: ''                      # Root folder
    type: file                      # Dosyadan yükle
    disableDeletion: false          # false: UI'dan silinebilir
    updateIntervalSeconds: 10       # Her 10 saniyede dosyaları kontrol et
    allowUiUpdates: true            # true: UI'dan değiştirilebilir ama kaybolur
    options:
      path: /etc/grafana/dashboards # Dashboard JSON'ları buradan yükle
```

**DevOps Kararları:**
- **Development:** `disableDeletion: false`, `allowUiUpdates: true` (deneme yapsınlar)
- **Production:** `disableDeletion: true`, `allowUiUpdates: false` (GitOps, kod ile güncellensin)

### Volume Mounting

**Prometheus:**
```yaml
volumes:
  - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml  # Config
  - prometheus_data:/prometheus                                 # Data (persistent)
```

**Grafana:**
```yaml
volumes:
  - grafana_data:/var/lib/grafana                              # Database (persistent)
  - ./monitoring/grafana/provisioning:/etc/grafana/provisioning # Provisioning
  - ./monitoring/grafana/dashboards:/etc/grafana/dashboards    # Dashboards
```

**Ne demek?**
- Sol taraf (Host): Senin bilgisayarın
- Sağ taraf (Container): Container içi
- Named volume (`prometheus_data`): Docker yönetir, container silinse bile kalır

### Metrik Toplama Akışı

```
[15 saniye geçti]
         ↓
┌────────────────┐
│   Prometheus   │
└────────┬───────┘
         │
         ├─→ Job: backend
         │   ├─ DNS: backend → 172.18.0.3
         │   ├─ GET http://172.18.0.3:5000/metrics
         │   └─ Metrikleri kaydet
         │
         ├─→ Job: postgres-exporter
         │   ├─ DNS: postgres-exporter → 172.18.0.6
         │   ├─ GET http://172.18.0.6:9187/metrics
         │   └─ PostgreSQL metriklerini kaydet
         │
         └─→ Job: node-exporter
             ├─ DNS: node-exporter → 172.18.0.5
             ├─ GET http://172.18.0.5:9100/metrics
             └─ Sistem metriklerini kaydet

[Grafana'dan PromQL query]
         ↓
    Query Prometheus
         ↓
    Dashboard'da göster
```

### Environment Variables (Grafana)

```yaml
environment:
  - GF_SECURITY_ADMIN_USER=admin
  - GF_SECURITY_ADMIN_PASSWORD=admin123
```

**Naming Convention:**
- `GF_` prefix → Grafana env variable
- `SECURITY_ADMIN_USER` → Config path: `[security] admin_user`

**Production Örneği:**
```yaml
environment:
  - GF_SECURITY_ADMIN_PASSWORD=${GRAFANA_PASSWORD}  # Secret'tan çek
  - GF_SERVER_ROOT_URL=https://grafana.company.com
  - GF_SMTP_ENABLED=true                            # Email alerts
  - GF_AUTH_GOOGLE_ENABLED=true                     # Google OAuth
```

### PromQL Query Örnekleri

```promql
# HTTP request rate (son 5 dakika)
rate(http_requests_total[5m])

# CPU kullanımı (%)
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory kullanımı (%)
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Database bağlantıları
db_connections_active

# Endpoint başına request sayısı
sum by (path) (http_requests_total)

# 5xx error rate
sum(rate(http_requests_total{status=~"5.."}[5m]))
```

### Monitoring Best Practices

**Golden Signals (Google SRE):**
1. **Latency**: İstek ne kadar sürdü? → `http_request_duration_seconds`
2. **Traffic**: Kaç request geliyor? → `rate(http_requests_total[5m])`
3. **Errors**: Kaç hata var? → `http_requests_total{status=~"5.."}`
4. **Saturation**: Kaynaklar doldu mu? → CPU, RAM, Disk

**RED Method (Microservices):**
- **Rate**: Request rate
- **Errors**: Error rate
- **Duration**: Request duration

**USE Method (Infrastructure):**
- **Utilization**: Kaynak kullanım %
- **Saturation**: Kuyruk uzunluğu
- **Errors**: Hata sayısı

### Config Reload

**Prometheus config değiştirdin, reload nasıl yapılır?**

```bash
# 1. Container restart (her zaman çalışır)
docker restart ecommerce-prometheus

# 2. Config reload (downtime yok)
docker exec ecommerce-prometheus kill -HUP 1

# 3. API ile reload (--web.enable-lifecycle flag gerekli)
curl -X POST http://localhost:9090/-/reload
```

### Troubleshooting

**Problem:** Prometheus target'ı bulamıyor

**Çözüm:**
```bash
# 1. Container network'ü kontrol et
docker network inspect ecommerce-devops-platform_app-network

# 2. DNS test et
docker exec ecommerce-prometheus nslookup backend

# 3. HTTP test et
docker exec ecommerce-prometheus wget -O- http://backend:5000/metrics
```

**Problem:** Grafana datasource bağlanamıyor

**Çözüm:**
```bash
# 1. Prometheus URL kontrol et (container adı kullan, localhost değil!)
# ❌ YANLIŞ: http://localhost:9090
# ✅ DOĞRU:  http://prometheus:9090

# 2. Network kontrol et (aynı network'te olmalılar)
docker compose ps
```

### Key Takeaways

✅ **Config Management:** prometheus.yml ve grafana provisioning → Git'te tut (IaC)
✅ **Docker DNS:** Container'lar birbirini isimle bulur (`backend:5000`)
✅ **Volume Mounting:** Config dosyalarını host'tan container'a mount et
✅ **Persistent Storage:** `named volumes` kullan (data kaybolmasın)
✅ **Access Mode:** Grafana'da `proxy` kullan (güvenli, browser'dan direkt değil)
✅ **Scrape Interval:** Production'da 15-30s (balance: freshness vs performance)
✅ **Environment Variables:** Secrets'ı env'den çek, kodda bırakma

---

## ☸️ Kubernetes (K8s) - Container Orchestration

### Docker Compose vs Kubernetes

**Docker Compose:**
- Development için ideal
- Tek sunucuda çalışır
- Basit YAML konfigürasyonu
- Manuel scaling

**Kubernetes:**
- Production için tasarlandı
- Cluster (birden fazla sunucu) yönetir
- Auto-scaling, self-healing
- High availability

### Kubernetes Temel Kavramları

**Cluster:**
- Master Node(s): Control plane (API server, scheduler, controller)
- Worker Node(s): Container'ların çalıştığı sunucular

**Pod:**
- En küçük deployable unit
- 1 veya daha fazla container içerir
- Shared network ve storage
- Ephemeral (geçici) - ölürse yenisi oluşturulur

```yaml
# Pod örneği (genellikle direkt kullanılmaz)
apiVersion: v1
kind: Pod
metadata:
  name: backend-pod
spec:
  containers:
  - name: backend
    image: ecommerce-backend:latest
    ports:
    - containerPort: 5000
```

**Deployment:**
- Pod'ların lifecycle'ını yönetir
- Replica count (kaç pod olacak)
- Rolling updates / Rollbacks
- Self-healing (pod ölürse yenisini başlatır)

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: ecommerce
spec:
  replicas: 2                    # 2 pod çalışsın
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: backend
        image: ecommerce-backend:latest
        ports:
        - containerPort: 5000
        env:
        - name: DB_HOST
          valueFrom:
            configMapKeyRef:
              name: ecommerce-config
              key: DB_HOST
        resources:
          requests:              # Minimum kaynak
            memory: "128Mi"
            cpu: "100m"
          limits:                # Maximum kaynak
            memory: "256Mi"
            cpu: "200m"
```

**Service:**
- Pod'lara network erişimi sağlar
- Load balancing (replica'lar arası dağıtım)
- DNS (service adı ile erişim)

```yaml
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: ecommerce
spec:
  type: ClusterIP              # İçerden erişim
  ports:
  - port: 5000                 # Service portu
    targetPort: 5000           # Container portu
  selector:
    app: backend               # Hangi pod'lara yönlendir
```

**Service Types:**
- **ClusterIP**: Cluster içinden erişim (default)
- **NodePort**: Node IP'si üzerinden dışarıdan erişim
- **LoadBalancer**: Cloud provider'ın LB'sini kullan
- **ExternalName**: DNS CNAME mapping

### ConfigMap & Secret

**ConfigMap:** Non-sensitive configuration

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: ecommerce-config
  namespace: ecommerce
data:
  DB_HOST: "postgres-service"
  DB_PORT: "5432"
  NODE_ENV: "production"
```

**Secret:** Sensitive data (base64 encoded)

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: ecommerce-secrets
  namespace: ecommerce
type: Opaque
stringData:                    # stringData: otomatik encode eder
  DB_USER: "devops"
  DB_PASSWORD: "devops123"
```

**Container'da Kullanım:**

```yaml
env:
  # ConfigMap'ten değer
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: ecommerce-config
        key: DB_HOST

  # Secret'tan değer
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: ecommerce-secrets
        key: DB_PASSWORD
```

### PersistentVolume (PV) & PersistentVolumeClaim (PVC)

**Neden Gerekli?**
- Pod'lar ephemeral (geçici)
- Pod ölürse, içindeki data kaybolur
- Database gibi stateful uygulamalar için persistent storage gerekli

```yaml
# PVC (Developer talep eder)
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: postgres-pvc
  namespace: ecommerce
spec:
  accessModes:
    - ReadWriteOnce          # Tek pod okuyup yazabilir
  resources:
    requests:
      storage: 5Gi           # 5GB storage istiyorum
  storageClassName: standard # Hangi storage sınıfı
```

**Pod'da Kullanım:**

```yaml
volumes:
  - name: postgres-storage
    persistentVolumeClaim:
      claimName: postgres-pvc

volumeMounts:
  - name: postgres-storage
    mountPath: /var/lib/postgresql/data
```

### Namespace

**Neden Kullanılır?**
- Resource izolasyonu
- Environment separation (dev, staging, prod)
- RBAC (Role-Based Access Control)

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: ecommerce
```

**Namespace ile Çalışma:**

```bash
# Namespace belirtmeden (default namespace)
kubectl get pods

# Namespace belirterek
kubectl get pods -n ecommerce

# Tüm namespace'lerdeki pod'lar
kubectl get pods --all-namespaces
```

### Health Probes

**Liveness Probe:** Pod sağlıklı mı? (Sağlıksızsa restart et)

```yaml
livenessProbe:
  httpGet:
    path: /api/health
    port: 5000
  initialDelaySeconds: 30    # İlk 30 saniye bekleme
  periodSeconds: 10          # Her 10 saniyede kontrol
```

**Readiness Probe:** Pod traffic alabilir mi? (Hazır değilse traffic gönderme)

```yaml
readinessProbe:
  httpGet:
    path: /api/health
    port: 5000
  initialDelaySeconds: 5
  periodSeconds: 5
```

**Fark:**
- Liveness fail → Pod restart
- Readiness fail → Traffic gönderilmez ama pod restart olmaz

### Resource Requests & Limits

```yaml
resources:
  requests:                  # Minimum garantili kaynak
    memory: "128Mi"
    cpu: "100m"             # 100 millicore = 0.1 CPU
  limits:                    # Maximum kullanabileceği
    memory: "256Mi"
    cpu: "200m"
```

**CPU Units:**
- `1` = 1 full CPU core
- `100m` = 0.1 CPU (millicore)
- `500m` = 0.5 CPU

**Memory Units:**
- `128Mi` = 128 Mebibytes
- `1Gi` = 1 Gibibyte

**Ne Olur?**
- Request'ten az kaynak olan node'a schedule edilmez
- Limit'i aşarsa:
  - CPU: Throttle edilir (yavaşlar)
  - Memory: OOMKilled (Out of Memory)

### kubectl Komutları

```bash
# Cluster bilgisi
kubectl cluster-info
kubectl get nodes

# Resource oluşturma
kubectl apply -f deployment.yaml
kubectl apply -f .                    # Tüm yaml'ları

# Resource listeleme
kubectl get pods -n ecommerce
kubectl get deployments -n ecommerce
kubectl get services -n ecommerce
kubectl get all -n ecommerce          # Tümü

# Detaylı bilgi
kubectl describe pod <pod-name> -n ecommerce
kubectl describe deployment backend -n ecommerce

# Loglar
kubectl logs <pod-name> -n ecommerce
kubectl logs -f <pod-name>            # Follow (tail -f gibi)
kubectl logs <pod-name> --previous    # Önceki (crash olduysa)

# Pod içine girme
kubectl exec -it <pod-name> -n ecommerce -- /bin/sh

# Port forwarding (local test için)
kubectl port-forward svc/backend-service 5000:5000 -n ecommerce

# Scaling
kubectl scale deployment backend --replicas=3 -n ecommerce

# Resource silme
kubectl delete pod <pod-name> -n ecommerce
kubectl delete deployment backend -n ecommerce
kubectl delete namespace ecommerce    # Namespace ve içindeki her şey

# Config değişikliği
kubectl edit deployment backend -n ecommerce

# Resource durumu izleme
kubectl get pods -n ecommerce -w      # Watch mode
```

### Deployment Stratejileri

**Rolling Update (Default):**
- Yavaş yavaş pod'ları güncelle
- Zero downtime
- Rollback kolay

```yaml
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxUnavailable: 1    # En fazla 1 pod down olabilir
      maxSurge: 1          # En fazla 1 extra pod oluşturulabilir
```

**Recreate:**
- Önce tüm pod'ları sil
- Sonra yenilerini başlat
- Downtime var ama temiz geçiş

```yaml
spec:
  strategy:
    type: Recreate
```

### Labels & Selectors

**Labels:** Key-value metadata

```yaml
metadata:
  labels:
    app: backend
    tier: api
    environment: production
```

**Selectors:** Label'lara göre filtreleme

```bash
# Label'a göre listele
kubectl get pods -l app=backend -n ecommerce
kubectl get pods -l tier=api,environment=production -n ecommerce
```

**Service → Pod Matching:**

```yaml
# Service
selector:
  app: backend

# Pod (Deployment template)
labels:
  app: backend
```

### Service Discovery

**DNS Resolution:**

```bash
# Aynı namespace içinde
curl http://backend-service:5000

# Farklı namespace'ten
curl http://backend-service.ecommerce.svc.cluster.local:5000
```

**Format:**
```
<service-name>.<namespace>.svc.cluster.local
```

### Kubernetes Monitoring (Prometheus)

**Service Discovery:**

```yaml
scrape_configs:
  - job_name: 'backend'
    kubernetes_sd_configs:
      - role: pod
        namespaces:
          names:
            - ecommerce
    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_label_app]
        action: keep
        regex: backend
```

**Ne Yapıyor?**
1. `kubernetes_sd_configs`: K8s API'den pod'ları otomatik keşfet
2. `relabel_configs`: Sadece `app=backend` label'ı olan pod'ları tut
3. Prometheus her yeni pod'u otomatik ekler/çıkarır

### Troubleshooting

**Problem:** Pod CrashLoopBackOff

```bash
# Logları kontrol et
kubectl logs <pod-name> -n ecommerce

# Previous container logları
kubectl logs <pod-name> --previous -n ecommerce

# Pod detaylarına bak (events)
kubectl describe pod <pod-name> -n ecommerce
```

**Problem:** ImagePullBackOff

```bash
# Image registry'ye erişilebiliyor mu?
kubectl describe pod <pod-name> -n ecommerce
# Event'lerde error mesajını gör

# Image adı doğru mu?
# Image private ise secret gerekebilir
```

**Problem:** Service'e bağlanamıyorum

```bash
# Endpoint'leri kontrol et (pod IP'leri)
kubectl get endpoints backend-service -n ecommerce

# Boş ise:
# - Selector doğru mu? (Service ve Pod label'ları eşleşiyor mu?)
# - Pod'lar Running durumda mı?
# - Readiness probe pass ediyor mu?

# DNS test
kubectl run test --rm -it --image=busybox -n ecommerce -- nslookup backend-service
```

**Problem:** Pod Pending durumunda

```bash
kubectl describe pod <pod-name> -n ecommerce
# Event'lerde neden pending olduğunu gör

# Olası nedenler:
# - Node'larda yeterli kaynak yok (CPU/Memory)
# - PVC bound olmamış
# - ImagePullBackOff
```

### Real-World Deployment Flow

```
1. Developer: Code yaz → Docker image build → Registry'ye push
         ↓
2. Manifest Update: deployment.yaml'de image tag'i güncelle
         ↓
3. kubectl apply: Kubernetes'e gönder
         ↓
4. Rolling Update:
   - Yeni pod başlat (Readiness probe bekle)
   - Traffic'i yeni pod'a yönlendir
   - Eski pod'u terminate et
   - Diğer replica'lar için tekrarla
         ↓
5. Health Check: Liveness probe ile monitoring
         ↓
6. Prometheus: Metrics topla
         ↓
7. Grafana: Dashboard'da izle
```

### Key Takeaways

✅ **Declarative:** İstenilen durumu tanımla (YAML), Kubernetes onu sağlar
✅ **Self-Healing:** Pod crash olursa otomatik yeniden başlatır
✅ **Scaling:** `kubectl scale` veya HorizontalPodAutoscaler
✅ **Service Discovery:** DNS ile pod'lara erişim
✅ **Zero Downtime:** Rolling updates ile deployment
✅ **Resource Management:** Requests/limits ile kaynak garantisi
✅ **ConfigMap/Secret:** Configuration management
✅ **Persistent Storage:** PVC ile data persistence
✅ **Health Probes:** Liveness (restart) + Readiness (traffic)
✅ **Labels:** Resource organization ve selection

### Docker Compose → Kubernetes Mapping

| Docker Compose | Kubernetes |
|----------------|------------|
| `service` | Deployment + Service |
| `image` | Pod spec: image |
| `ports` | Service: ports |
| `environment` | ConfigMap / Secret |
| `volumes` | PersistentVolumeClaim |
| `depends_on` | initContainers |
| `networks` | Default (all pods in namespace) |
| `restart: always` | Deployment (automatic) |
