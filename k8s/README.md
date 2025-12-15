# Kubernetes Deployment

E-commerce platform Kubernetes manifests for production-grade orchestration.

## Prerequisites

- **Kubernetes cluster** (minikube, kind, or cloud provider)
- **kubectl** CLI installed and configured
- **Docker images** pushed to registry (Docker Hub)

## Quick Start

```bash
# Deploy entire stack
./deploy.sh

# Or manually step by step:
kubectl apply -f base/namespace.yaml
kubectl apply -f base/configmap.yaml
kubectl apply -f base/secret.yaml
kubectl apply -f base/pvc.yaml
kubectl apply -f base/
```

## Architecture

```
┌─────────────────────────────────────────────────┐
│         Kubernetes Cluster (ecommerce ns)       │
│                                                  │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐      │
│  │ Frontend │  │ Backend  │  │PostgreSQL│      │
│  │   x2     │──│   x2     │──│   x1     │      │
│  │ (LB)     │  │ (ClIP)   │  │ (ClIP)   │      │
│  └──────────┘  └──────────┘  └──────────┘      │
│                     │                            │
│  ┌──────────┐  ┌───┴──────┐  ┌──────────┐      │
│  │Prometheus│  │ Postgres │  │   Node   │      │
│  │   x1     │──│ Exporter │  │ Exporter │      │
│  │ (ClIP)   │  │   x1     │  │(DaemonSet│      │
│  └────┬─────┘  └──────────┘  └──────────┘      │
│       │                                          │
│  ┌────┴─────┐                                   │
│  │ Grafana  │                                   │
│  │   x1     │                                   │
│  │  (LB)    │                                   │
│  └──────────┘                                   │
└─────────────────────────────────────────────────┘
```

## Resources Overview

### Deployments & ReplicaSets
| Service | Replicas | Image | Resources |
|---------|----------|-------|-----------|
| Frontend | 2 | ecommerce-frontend:latest | 64Mi-128Mi / 50m-100m |
| Backend | 2 | ecommerce-backend:latest | 128Mi-256Mi / 100m-200m |
| PostgreSQL | 1 | postgres:15-alpine | 256Mi-512Mi / 250m-500m |
| Prometheus | 1 | prom/prometheus:latest | 256Mi-512Mi / 200m-500m |
| Grafana | 1 | grafana/grafana:latest | 128Mi-256Mi / 100m-200m |
| Postgres Exporter | 1 | postgres-exporter:latest | 32Mi-64Mi / 50m-100m |
| Node Exporter | DaemonSet | node-exporter:latest | 32Mi-64Mi / 50m-100m |

### Services
| Service | Type | Port | Target |
|---------|------|------|--------|
| frontend-service | LoadBalancer | 80 | 80 |
| backend-service | ClusterIP | 5000 | 5000 |
| postgres-service | ClusterIP | 5432 | 5432 |
| prometheus-service | ClusterIP | 9090 | 9090 |
| grafana-service | LoadBalancer | 3000 | 3000 |
| postgres-exporter-service | ClusterIP | 9187 | 9187 |
| node-exporter-service | ClusterIP | 9100 | 9100 |

### Storage
| PVC | Size | Access Mode | Used By |
|-----|------|-------------|---------|
| postgres-pvc | 5Gi | ReadWriteOnce | PostgreSQL |
| prometheus-pvc | 10Gi | ReadWriteOnce | Prometheus |
| grafana-pvc | 2Gi | ReadWriteOnce | Grafana |

## Configuration

### ConfigMap
- Application settings (ports, environment)
- Non-sensitive configuration

### Secrets
- Database credentials
- Admin passwords
- Connection strings

⚠️ **Production**: Use external secret management (Vault, AWS Secrets Manager, etc.)

## Key Kubernetes Concepts Used

### 1. Deployments
Manages stateless applications with rolling updates and rollbacks.

```yaml
spec:
  replicas: 2
  strategy:
    type: RollingUpdate
```

### 2. Services
Network abstraction for pod communication.

- **ClusterIP**: Internal cluster communication
- **LoadBalancer**: External access with cloud provider LB

### 3. ConfigMaps & Secrets
Configuration and sensitive data management.

```yaml
env:
  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: ecommerce-config
        key: DB_HOST
```

### 4. PersistentVolumeClaims
Persistent storage for stateful workloads.

```yaml
volumeMounts:
  - name: postgres-storage
    mountPath: /var/lib/postgresql/data
```

### 5. Health Probes
Application health monitoring.

- **livenessProbe**: Restart unhealthy pods
- **readinessProbe**: Control traffic routing

### 6. Resource Limits
CPU and memory constraints.

```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

## Common Commands

```bash
# View all resources
kubectl get all -n ecommerce

# Check pod logs
kubectl logs -f <pod-name> -n ecommerce

# Describe resource
kubectl describe deployment backend -n ecommerce

# Scale deployment
kubectl scale deployment backend --replicas=3 -n ecommerce

# Port forward for testing
kubectl port-forward svc/backend-service 5000:5000 -n ecommerce

# Execute command in pod
kubectl exec -it <pod-name> -n ecommerce -- /bin/sh

# Delete all resources
kubectl delete namespace ecommerce
```

## Monitoring Access

### Prometheus
```bash
kubectl port-forward svc/prometheus-service 9090:9090 -n ecommerce
```
Visit: http://localhost:9090

### Grafana
```bash
kubectl port-forward svc/grafana-service 3000:3000 -n ecommerce
```
Visit: http://localhost:3000 (admin / admin123)

## Troubleshooting

### Pods not starting
```bash
# Check pod status
kubectl get pods -n ecommerce

# View pod events
kubectl describe pod <pod-name> -n ecommerce

# Check logs
kubectl logs <pod-name> -n ecommerce
```

### Service not accessible
```bash
# Check service endpoints
kubectl get endpoints -n ecommerce

# Test service DNS
kubectl run test --rm -it --image=busybox -n ecommerce -- nslookup backend-service
```

### PVC pending
```bash
# Check PVC status
kubectl get pvc -n ecommerce

# Describe PVC
kubectl describe pvc postgres-pvc -n ecommerce

# Check storage class
kubectl get storageclass
```

## Production Considerations

- [ ] Use Ingress controller instead of LoadBalancer
- [ ] Implement Network Policies for pod isolation
- [ ] Add HorizontalPodAutoscaler for auto-scaling
- [ ] Configure resource quotas and limits
- [ ] Use external secret management (Vault)
- [ ] Implement RBAC for access control
- [ ] Add Pod Disruption Budgets
- [ ] Configure backup strategy for PVCs
- [ ] Use Helm for templating and versioning
- [ ] Implement GitOps with ArgoCD/Flux

## Next Steps

1. **Set up Ingress**: Expose services via Ingress controller
2. **Implement HPA**: Auto-scaling based on metrics
3. **Add Monitoring**: Prometheus ServiceMonitor resources
4. **Helm Charts**: Convert manifests to Helm charts
5. **GitOps**: Deploy via ArgoCD
