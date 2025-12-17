# E-Commerce DevOps Platform

A production-ready e-commerce platform with complete DevOps implementation including Docker, CI/CD, monitoring, Kubernetes orchestration, and AWS cloud deployment.

**Author**: Yagiz Kastamonu
**Started**: 2025-12-10
**Last Updated**: 2025-12-17

## Deployment Options

### AWS Cloud (Terraform)
```
Infrastructure as Code with Terraform
├── VPC (10.0.0.0/16)
│   ├── Public Subnet (10.0.1.0/24)
│   └── Internet Gateway
├── Security Groups
│   ├── SSH (22)
│   ├── HTTP (3000, 5000, 9090, 3001)
│   └── PostgreSQL (5432)
└── EC2 Instance (t3.micro)
    ├── Ubuntu 22.04 LTS
    ├── Docker + Docker Compose
    └── Elastic IP (static)
```

**Deploy to AWS:**
```bash
cd terraform
terraform init
terraform apply
```

See [terraform/README.md](terraform/README.md) for detailed instructions.

### Kubernetes (Production)
```
Namespace: ecommerce
├── Frontend (LoadBalancer)
│   └── 2 replicas
├── Backend (ClusterIP)
│   └── 2 replicas + auto-scaling
├── PostgreSQL (ClusterIP)
│   └── 1 replica + 5Gi PVC
├── Prometheus (ClusterIP)
│   └── 1 replica + 10Gi PVC
├── Grafana (LoadBalancer)
│   └── 1 replica + 2Gi PVC
└── Exporters (DaemonSet)
    ├── Node Exporter
    └── Postgres Exporter
```


### Docker Compose (Local Development)
```bash
docker compose up -d
```

**Access URLs (Local):**
- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- PostgreSQL: localhost:5432
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3001 (admin/admin123)


## Project Structure

```
ecommerce-devops-platform/
├── backend/                    # Node.js API
│   ├── database/
│   │   ├── db.js              # PostgreSQL connection pool
│   │   └── init.sql           # Database schema
│   ├── Dockerfile             # Backend container
│   ├── server.js              # Express API with metrics
│   └── package.json
├── frontend/                   # Static HTML/CSS/JS
│   ├── Dockerfile             # Nginx container
│   └── index.html
├── monitoring/                 # Prometheus & Grafana
│   ├── prometheus.yml         # Scrape configuration
│   ├── grafana/
│   │   ├── provisioning/      # Auto-config datasources
│   │   └── dashboards/        # Pre-built dashboards
│   └── README.md
├── k8s/                        # Kubernetes manifests
│   ├── base/
│   │   ├── namespace.yaml
│   │   ├── configmap.yaml
│   │   ├── secret.yaml
│   │   ├── pvc.yaml
│   │   ├── *-deployment.yaml  # All service deployments
│   │   └── prometheus-config.yaml
│   ├── deploy.sh              # Automated deployment
│   └── README.md
├── terraform/                  # AWS Infrastructure as Code
│   ├── main.tf                # Provider configuration
│   ├── variables.tf           # Input variables
│   ├── vpc.tf                 # VPC, subnets, IGW
│   ├── security-groups.tf     # Firewall rules
│   ├── ec2.tf                 # EC2 instance
│   ├── user-data.sh           # Bootstrap script
│   ├── outputs.tf             # Deployment outputs
│   └── README.md
├── docs/
│   └── CHEATSHEET.md          # Complete DevOps reference
├── .github/
│   └── workflows/
│       └── backend-ci.yml     # CI/CD pipeline
└── docker-compose.yml         # Development orchestration
```

## Technology Stack

**Backend:**
- Node.js + Express
- PostgreSQL (pg library)
- Prometheus client (prom-client)

**Frontend:**
- HTML/CSS/JavaScript
- Nginx

**Infrastructure:**
- Docker & Docker Compose
- Kubernetes
- Terraform (AWS)
- GitHub Actions

**Monitoring:**
- Prometheus (metrics collection)
- Grafana (visualization)
- Node Exporter (system metrics)
- Postgres Exporter (database metrics)



### Custom Application Metrics

**Backend exposes `/metrics` endpoint:**
- `http_requests_total` - Total HTTP requests by method, path, status
- `http_request_duration_seconds` - Request latency histogram
- `db_queries_total` - Database query count by type
- `db_connections_active` - Active database connections
- Default Node.js metrics (CPU, memory, event loop)



### Grafana Dashboards

Pre-configured dashboards include:
- API request rates and latency
- System resources (CPU, memory, disk)
- Database performance
- Error rates and status codes

## Testing

### Local Testing

```bash
# Test backend health
curl http://localhost:5000/api/health

# Test API endpoint
curl http://localhost:5000/api/products

# View metrics
curl http://localhost:5000/metrics
```

### CI/CD Testing

GitHub Actions automatically runs:
- Database connection tests
- Table existence validation
- Sample data verification
- Exit code validation



