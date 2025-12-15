#!/bin/bash

# Kubernetes Deployment Script for E-commerce Platform
# Author: Yagiz Kastamonu
# Date: 2025-12-15

set -e

echo "Deploying E-commerce Platform to Kubernetes..."

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if cluster is accessible
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

echo -e "${GREEN}✓${NC} kubectl is installed and cluster is accessible"

# Create namespace
echo -e "\n${YELLOW} Creating namespace...${NC}"
kubectl apply -f base/namespace.yaml

# Create ConfigMaps and Secrets
echo -e "\n${YELLOW} Creating ConfigMaps and Secrets...${NC}"
kubectl apply -f base/configmap.yaml
kubectl apply -f base/secret.yaml
kubectl apply -f base/prometheus-config.yaml

# Create PersistentVolumeClaims
echo -e "\n${YELLOW} Creating PersistentVolumeClaims...${NC}"
kubectl apply -f base/pvc.yaml

# Deploy Database
echo -e "\n${YELLOW} Deploying PostgreSQL...${NC}"
kubectl apply -f base/postgres-deployment.yaml

# Wait for PostgreSQL to be ready
echo " Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres -n ecommerce --timeout=120s

# Deploy Backend
echo -e "\n${YELLOW} Deploying Backend API...${NC}"
kubectl apply -f base/backend-deployment.yaml

# Deploy Frontend
echo -e "\n${YELLOW} Deploying Frontend...${NC}"
kubectl apply -f base/frontend-deployment.yaml

# Deploy Monitoring Stack
echo -e "\n${YELLOW} Deploying Monitoring Stack...${NC}"
kubectl apply -f base/prometheus-deployment.yaml
kubectl apply -f base/grafana-deployment.yaml
kubectl apply -f base/exporters-deployment.yaml

# Wait for all deployments to be ready
echo -e "\n${YELLOW}  Waiting for all deployments to be ready...${NC}"
kubectl wait --for=condition=available deployment --all -n ecommerce --timeout=300s

# Display status
echo -e "\n${GREEN}✅ Deployment completed successfully!${NC}"
echo -e "\n${YELLOW}  Resource Status:${NC}"
kubectl get all -n ecommerce

echo -e "\n${YELLOW}  Access URLs:${NC}"
echo "Frontend: http://localhost:30080"
echo "Backend API: http://localhost:30500"
echo "Prometheus: http://localhost:30900"
echo "Grafana: http://localhost:30300"
echo ""
echo "Grafana credentials: admin / admin123"
