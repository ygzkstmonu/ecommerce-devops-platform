# Monitoring Stack

Prometheus + Grafana monitoring configuration for the e-commerce platform.

## Services

### Prometheus (Port: 9090)
**URL**: http://localhost:9090
**Config**: `prometheus.yml`

Collects and stores metrics from:
- Backend API (HTTP requests, response times)
- PostgreSQL (via postgres-exporter)
- System resources (via node-exporter)

Scrape interval: 15 seconds

### Grafana (Port: 3001)
**URL**: http://localhost:3001
**Credentials**: admin / admin123

Visualizes Prometheus metrics through dashboards. Auto-configured via provisioning files.

### Node Exporter (Port: 9100)
**Endpoint**: http://localhost:9100/metrics

System metrics: CPU, RAM, Disk, Network

### Postgres Exporter (Port: 9187)
**Endpoint**: http://localhost:9187/metrics

Database metrics: Active connections, query duration, database size, transactions

## Backend Metrics

**Endpoint**: http://localhost:5000/metrics

Custom application metrics:
- `http_requests_total` - Total HTTP requests
- `http_request_duration_seconds` - Request latency
- `db_queries_total` - Database query count
- `db_connections_active` - Active DB connections

Default Node.js metrics: CPU, heap memory, event loop lag

## Quick Start

```bash
# Start all services
docker compose up -d

# Access Prometheus
http://localhost:9090

# Access Grafana
http://localhost:3001
```

## Sample PromQL Queries

```promql
# HTTP request rate (last 5 min)
rate(http_requests_total[5m])

# CPU usage (%)
100 - (avg by (instance) (rate(node_cpu_seconds_total{mode="idle"}[5m])) * 100)

# Memory usage (%)
(node_memory_MemTotal_bytes - node_memory_MemAvailable_bytes) / node_memory_MemTotal_bytes * 100

# Database connections
db_connections_active

# Requests per endpoint
sum by (path) (http_requests_total)

# Error rate (5xx errors)
sum(rate(http_requests_total{status=~"5.."}[5m]))
```

## Architecture

```
Backend (5000) ──┐
                 │
PostgreSQL ──────┤         Prometheus (9090)
                 │ /metrics      │
Node Exporter ───┤ ──────────────┤
                 │               │
Postgres Exp. ───┘               │ query
                                 ↓
                            Grafana (3001)
```

## Monitoring Methodologies

**Golden Signals** (Google SRE):
- Latency: `http_request_duration_seconds`
- Traffic: `rate(http_requests_total[5m])`
- Errors: `http_requests_total{status=~"5.."}`
- Saturation: CPU, RAM, Disk usage

**RED Method** (Services):
- Rate: Request rate
- Errors: Error rate
- Duration: Response time

**USE Method** (Resources):
- Utilization: Resource usage percentage
- Saturation: Queue length
- Errors: Error count

## Troubleshooting

**Prometheus can't scrape targets:**
```bash
# Check Docker network
docker network inspect ecommerce-devops-platform_app-network

# Test DNS resolution
docker exec ecommerce-prometheus nslookup backend

# Test HTTP endpoint
docker exec ecommerce-prometheus wget -O- http://backend:5000/metrics
```

**Grafana datasource connection fails:**
- Use container name: `http://prometheus:9090` (not localhost)
- Verify both containers are on the same network
- Check provisioning files are mounted correctly
