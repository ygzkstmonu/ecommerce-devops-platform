# Monitoring & Observability

Bu dizin, Prometheus ve Grafana ile sistem izleme konfigürasyonlarını içerir.

## Servisler

### Prometheus (Port: 9090)
- **Amaç**: Metrikleri toplar ve saklar
- **URL**: http://localhost:9090
- **Konfigürasyon**: `prometheus.yml`

**Ne Yapar?**
- Backend'den HTTP request metrikleri toplar
- PostgreSQL'den database metrikleri toplar
- Node Exporter'dan sistem metrikleri (CPU, RAM, Disk) toplar
- Her 15 saniyede bir tüm kaynaklardan veri çeker

### Grafana (Port: 3001)
- **Amaç**: Metrikleri görselleştirir
- **URL**: http://localhost:3001
- **Login**:
  - Username: `admin`
  - Password: `admin123`

**Ne Yapar?**
- Prometheus'tan veri çeker
- Güzel dashboardlar oluşturur
- Grafikler, tablolar, alertler gösterir

### Node Exporter (Port: 9100)
- **Amaç**: Sistem metriklerini toplar
- **URL**: http://localhost:9100/metrics

**Topladığı Metrikler:**
- CPU kullanımı
- RAM kullanımı
- Disk kullanımı
- Network trafiği

### Postgres Exporter (Port: 9187)
- **Amaç**: PostgreSQL metriklerini toplar
- **URL**: http://localhost:9187/metrics

**Topladığı Metrikler:**
- Aktif bağlantı sayısı
- Query süreleri
- Database boyutu
- Transaction sayısı

## Backend Metrics Endpoint

Backend'de `/metrics` endpoint'i var:
- **URL**: http://localhost:5000/metrics

**Topladığı Custom Metrikler:**
- `http_requests_total`: Toplam HTTP request sayısı
- `http_request_duration_seconds`: Request süreleri
- `db_queries_total`: Toplam database query sayısı
- `db_connections_active`: Aktif database bağlantıları

**Default Node.js Metrikleri:**
- `process_cpu_user_seconds_total`: CPU kullanımı
- `nodejs_heap_size_total_bytes`: Heap memory
- `nodejs_eventloop_lag_seconds`: Event loop lag

## Kullanım

### 1. Servisleri Başlat
```bash
docker compose up -d
```

### 2. Prometheus'a Bağlan
http://localhost:9090 adresine git

**Örnek Queries:**
```promql
# HTTP request rate (son 5 dakika)
rate(http_requests_total[5m])

# CPU kullanımı
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory kullanımı
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Database bağlantıları
db_connections_active

# Endpoint başına request sayısı
sum by (path) (http_requests_total)
```

### 3. Grafana'ya Bağlan
http://localhost:3001 adresine git
- Username: `admin`
- Password: `admin123`

**İlk Kurulum:**
1. Configuration → Data Sources → Add data source
2. Prometheus seç
3. URL: `http://prometheus:9090`
4. Save & Test

**Dashboard Import:**
1. Dashboards → Import
2. `grafana-dashboard.json` dosyasını yükle
3. Prometheus data source seç
4. Import

## Monitoring Architecture

```
┌─────────────┐
│   Backend   │───────┐
│  (Node.js)  │       │
│ Port: 5000  │       │
└─────────────┘       │
                      │ /metrics
┌─────────────┐       │
│  PostgreSQL │       │
│ Port: 5432  │───┐   │
└─────────────┘   │   │
                  │   │
┌─────────────┐   │   │
│Postgres     │   │   │
│Exporter     │───┤   │
│Port: 9187   │   │   │
└─────────────┘   │   │
                  │   │
┌─────────────┐   │   │        ┌──────────────┐
│   Node      │   │   │        │  Prometheus  │
│  Exporter   │───┼───┼───────▶│  Port: 9090  │
│Port: 9100   │   │   │ scrape │              │
└─────────────┘   │   │        └──────┬───────┘
                  │   │               │
                  └───┘               │ query
                                      │
                              ┌───────▼────────┐
                              │    Grafana     │
                              │  Port: 3001    │
                              │  (Dashboard)   │
                              └────────────────┘
```

## Real-World Scenario

**Durum**: Production'da API yavaşladı, kullanıcılar şikayet ediyor.

**Monitoring Olmadan:**
- "API yavaş" → Nerede? Hangi endpoint? Ne zaman başladı?
- Tahmin yürütürsün → "Belki database?"
- Random yerlerden debugging başlarsın
- Saatler boşa gider

**Monitoring İle:**
1. Grafana'ya bak → `/api/products` endpoint'inin response time'ı arttı
2. Prometheus'a bak → Database query sayısı normal, ama süresi uzun
3. PostgreSQL metrikleri → Bağlantı sayısı 19/20 (limit dolmuş!)
4. Çözüm → Connection pool size'ı artır veya query'leri optimize et
5. 10 dakikada sorun çözüldü ✅

## DevOps Best Practices

✅ **Golden Signals** (Google SRE):
1. **Latency**: Request ne kadar sürdü? → `http_request_duration_seconds`
2. **Traffic**: Kaç request geliyor? → `rate(http_requests_total[5m])`
3. **Errors**: Kaç hata var? → `http_requests_total{status=~"5.."}`
4. **Saturation**: Kaynaklar doldu mu? → CPU, RAM, Disk

✅ **RED Method** (Microservices):
- **Rate**: Request rate
- **Errors**: Error rate
- **Duration**: Request duration

✅ **USE Method** (Infrastructure):
- **Utilization**: Kaynak kullanım yüzdesi
- **Saturation**: Kuyruk uzunluğu
- **Errors**: Hata sayısı
