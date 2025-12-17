#!/bin/bash
# User Data Script for EC2 Instance
# Installs Docker, Docker Compose, and sets up the environment

set -e

# Update system
echo " Updating system packages..."
apt-get update -y
apt-get upgrade -y

# Install dependencies
echo "Installing dependencies..."
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git

# Add Docker GPG key
echo "Adding Docker GPG key..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Add Docker repository
echo "Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker
echo "Installing Docker..."
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Start Docker
echo "Starting Docker service..."
systemctl start docker
systemctl enable docker

# Add ubuntu user to docker group
usermod -aG docker ubuntu

# Verify installation
echo "✅ Docker version:"
docker --version
docker compose version

# Create project directory
echo "Creating project directory..."
mkdir -p /home/ubuntu/${project_name}
chown ubuntu:ubuntu /home/ubuntu/${project_name}

# Clone or download project (placeholder - will be done manually or via CI/CD)
cat > /home/ubuntu/README.txt << 'EOF'
E-Commerce DevOps Platform - EC2 Instance

Docker and Docker Compose are installed and ready.

Next steps:
1. Clone your repository:
   git clone https://github.com/ygzkstmonu/ecommerce-devops-platform.git

2. Navigate to project:
   cd ecommerce-devops-platform

3. Start services:
   docker compose up -d

4. Access services:
   - Frontend: http://<PUBLIC_IP>:3000
   - Backend: http://<PUBLIC_IP>:5000
   - Prometheus: http://<PUBLIC_IP>:9090
   - Grafana: http://<PUBLIC_IP>:3001

SSH Access:
ssh -i ssh-key.pem ubuntu@<PUBLIC_IP>
EOF

chown ubuntu:ubuntu /home/ubuntu/README.txt

echo "Setup complete! Docker is ready to use."
