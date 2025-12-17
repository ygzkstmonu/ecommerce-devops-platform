# Terraform Infrastructure

Infrastructure as Code for deploying E-Commerce DevOps Platform to AWS.

## Prerequisites

- Terraform installed (`terraform version`)
- AWS CLI configured (`aws configure`)
- AWS account with appropriate permissions

## Infrastructure Overview

This Terraform configuration creates:

- **VPC** with public and private subnets
- **Internet Gateway** for public internet access
- **Security Groups** (firewall rules for ports 22, 3000, 5000, 9090, 3001)
- **EC2 Instance** (t2.micro - Free Tier eligible)
  - Ubuntu 22.04 LTS
  - Docker & Docker Compose pre-installed
- **Elastic IP** (static public IP)
- **SSH Key Pair** (auto-generated)

## Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

This downloads required providers (AWS).

### 2. Plan Deployment

```bash
terraform plan
```

Review the resources that will be created.

### 3. Apply Configuration

```bash
terraform apply
```

Type `yes` to confirm. This will:
- Create AWS resources (~2-3 minutes)
- Output important information (IP addresses, URLs)

### 4. Get Outputs

```bash
terraform output
```

Shows:
- Public IP address
- SSH command
- Service URLs (Frontend, Backend, Prometheus, Grafana)

## File Structure

```
terraform/
├── main.tf                # Provider configuration
├── variables.tf           # Input variables
├── vpc.tf                 # VPC, subnets, IGW
├── security-groups.tf     # Firewall rules
├── ec2.tf                 # EC2 instance configuration
├── user-data.sh           # Bootstrap script (Docker installation)
├── outputs.tf             # Output values
├── ssh-key.pem           # SSH private key (auto-generated)
└── README.md             # This file
```

## SSH Access

After `terraform apply`, connect to EC2:

```bash
# SSH command is shown in outputs
ssh -i ssh-key.pem ubuntu@<PUBLIC_IP>
```

**Important:**
- `ssh-key.pem` is auto-generated
- Keep it safe (not committed to Git - in .gitignore)
- Permissions: `chmod 600 ssh-key.pem` (Linux/Mac)

## Deploy Application

Once connected via SSH:

```bash
# Clone repository
git clone https://github.com/ygzkstmonu/ecommerce-devops-platform.git
cd ecommerce-devops-platform

# Start services
docker compose up -d

# Check status
docker compose ps
```

## Access Services

After deployment:

- **Frontend:** `http://<PUBLIC_IP>:3000`
- **Backend API:** `http://<PUBLIC_IP>:5000`
- **Prometheus:** `http://<PUBLIC_IP>:9090`
- **Grafana:** `http://<PUBLIC_IP>:3001` (admin/admin123)

## Cleanup

**Important:** Destroy resources to avoid AWS charges!

```bash
terraform destroy
```

Type `yes` to confirm. This will delete all created resources.


## Variables

Customize in `terraform.tfvars` (create if needed):

```hcl
aws_region    = "us-east-1"
environment   = "dev"
instance_type = "t2.micro"
vpc_cidr      = "10.0.0.0/16"
```


## Troubleshooting

### Terraform init fails
```bash
# Check AWS credentials
aws sts get-caller-identity

# Verify Terraform version
terraform version
```

### EC2 instance not accessible
```bash
# Check security group rules
aws ec2 describe-security-groups --group-ids <SG_ID>

# Verify instance is running
aws ec2 describe-instances --instance-ids <INSTANCE_ID>
```

### SSH connection refused
```bash
# Wait 2-3 minutes for instance to fully boot
# Check instance system log
aws ec2 get-console-output --instance-id <INSTANCE_ID>
```

