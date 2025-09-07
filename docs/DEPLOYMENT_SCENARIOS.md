# 🚀 CyberBlue Deployment Scenarios

Comprehensive deployment guides for different environments and use cases.

---

## 🎯 Overview

CyberBlue can be deployed in various scenarios depending on your needs, resources, and security requirements. This guide covers different deployment patterns with specific configurations and best practices.

---

## 🧪 **Development Environment**

Perfect for learning, testing, and development work.

### System Requirements
- **CPU**: 4 cores minimum
- **RAM**: 8GB minimum
- **Storage**: 50GB free space
- **Network**: Basic internet connectivity

### Quick Setup
```bash
# Clone repository
git clone https://github.com/m7siri/cyber-blue-project.git
cd cyber-blue-project

# Use development configuration
cp .env.development .env

# Quick start
./quick-start.sh
```

### Development-Specific Configuration

#### `.env.development`
```bash
# =================================
# DEVELOPMENT CONFIGURATION
# =================================
HOST_IP=localhost
PORTAL_PORT=5500
ENVIRONMENT=development

# =================================
# REDUCED RESOURCE LIMITS
# =================================
OS_JAVA_MEM=512m
INNODB_BUFFER_POOL_SIZE=512M

# =================================
# SECURITY (Development Only)
# =================================
WAZUH_ADMIN_PASSWORD=development123
OPENSEARCH_ADMIN_PASSWORD=development123
MISP_ADMIN_PASSWORD=development123

# =================================
# DEVELOPMENT FEATURES
# =================================
DEBUG=true
DISABLE_SSL_REDIRECT=true
ENABLE_DEBUG_LOGS=true
```

#### `docker-compose.dev.yml`
```yaml
version: '3.8'

services:
  # Minimal service set for development
  portal:
    extends:
      file: docker-compose.yml
      service: portal
    environment:
      - FLASK_ENV=development
      - DEBUG=true
    ports:
      - "5500:5500"

  # Lightweight services only
  cyberchef:
    extends:
      file: docker-compose.yml
      service: cyberchef

  misp-core:
    extends:
      file: docker-compose.yml
      service: misp-core
    deploy:
      resources:
        limits:
          memory: 1G

  # Disable resource-intensive services
  # opensearch, velociraptor, arkime disabled
```

### Development Commands
```bash
# Start development environment
docker-compose -f docker-compose.dev.yml up -d

# Quick restart for code changes
docker-compose restart portal

# Development logs
docker-compose logs -f portal

# Clean development data
docker-compose down -v
```

---

## 🧪 **Staging Environment**

Production-like environment for testing and validation.

### System Requirements
- **CPU**: 6-8 cores
- **RAM**: 12-16GB
- **Storage**: 100GB SSD
- **Network**: Dedicated network segment

### Staging Configuration

#### `.env.staging`
```bash
# =================================
# STAGING CONFIGURATION
# =================================
HOST_IP=staging.cyberblue.local
PORTAL_PORT=5500
ENVIRONMENT=staging

# =================================
# MODERATE RESOURCE ALLOCATION
# =================================
OS_JAVA_MEM=1g
INNODB_BUFFER_POOL_SIZE=1024M

# =================================
# SECURITY (Production-like)
# =================================
WAZUH_ADMIN_PASSWORD=StagingSecure2024!
OPENSEARCH_ADMIN_PASSWORD=StagingSecure2024!
MISP_ADMIN_PASSWORD=StagingSecure2024!

# =================================
# SSL CONFIGURATION
# =================================
SSL_ENABLED=true
SSL_CERT_PATH=./ssl/staging-cert.pem
SSL_KEY_PATH=./ssl/staging-key.pem

# =================================
# MONITORING & LOGGING
# =================================
ENABLE_MONITORING=true
LOG_LEVEL=info
BACKUP_ENABLED=true
BACKUP_SCHEDULE="0 2 * * *"
```

#### Staging-Specific Services
```yaml
# docker-compose.staging.yml
version: '3.8'

services:
  # All production services with staging configs
  portal:
    extends:
      file: docker-compose.yml
      service: portal
    environment:
      - FLASK_ENV=staging
      - SSL_ENABLED=true
    volumes:
      - ./ssl:/app/ssl:ro

  # Add monitoring stack
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    ports:
      - "9090:9090"
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - cyber-blue

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    ports:
      - "3000:3000"
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=staging123
    networks:
      - cyber-blue

  # Backup service
  backup:
    image: alpine:latest
    container_name: backup-service
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./backups:/backups
    command: |
      sh -c "
      while true; do
        echo 'Starting backup...'
        /backups/backup-script.sh
        sleep 86400
      done"
```

### Staging Deployment
```bash
# Deploy staging environment
docker-compose -f docker-compose.yml -f docker-compose.staging.yml up -d

# Staging-specific monitoring
docker-compose logs -f prometheus grafana

# Run staging tests
./scripts/staging-tests.sh
```

---

## 🏭 **Production Environment**

Enterprise-grade deployment with full security and monitoring.

### System Requirements
- **CPU**: 16+ cores (32 recommended)
- **RAM**: 32GB minimum (64GB recommended)
- **Storage**: 500GB+ NVMe SSD
- **Network**: Dedicated VLAN, load balancer, firewall

### Production Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Load Balancer │    │   Firewall      │    │   Backup        │
│   (HAProxy)     │    │   (iptables)    │    │   (Automated)   │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────┐    ┌┴─────────────────┐    ┌─────────────────┐
         │   Monitoring    │    │ CyberBlue Stack  │    │  External DB    │
         │   (Prometheus)  │    │  (Docker Swarm)  │    │  (PostgreSQL)   │
         └─────────────────┘    └──────────────────┘    └─────────────────┘
```

### Production Configuration

#### `.env.production`
```bash
# =================================
# PRODUCTION CONFIGURATION
# =================================
HOST_IP=cyberblue.company.com
PORTAL_PORT=443
ENVIRONMENT=production

# =================================
# HIGH RESOURCE ALLOCATION
# =================================
OS_JAVA_MEM=4g
INNODB_BUFFER_POOL_SIZE=4096M
PHP_MEMORY_LIMIT=4096M

# =================================
# SECURITY (Production)
# =================================
WAZUH_ADMIN_PASSWORD=${WAZUH_PROD_PASSWORD}
OPENSEARCH_ADMIN_PASSWORD=${OPENSEARCH_PROD_PASSWORD}
MISP_ADMIN_PASSWORD=${MISP_PROD_PASSWORD}

# =================================
# SSL CONFIGURATION
# =================================
SSL_ENABLED=true
SSL_CERT_PATH=/etc/ssl/certs/cyberblue.crt
SSL_KEY_PATH=/etc/ssl/private/cyberblue.key
HSTS_MAX_AGE=31536000

# =================================
# EXTERNAL DATABASES
# =================================
EXTERNAL_POSTGRES=true
POSTGRES_HOST=db.company.com
POSTGRES_PORT=5432
POSTGRES_SSL=require

# =================================
# MONITORING & ALERTING
# =================================
PROMETHEUS_ENABLED=true
GRAFANA_ENABLED=true
ALERTMANAGER_ENABLED=true
SLACK_WEBHOOK_URL=${SLACK_WEBHOOK}

# =================================
# BACKUP CONFIGURATION
# =================================
BACKUP_ENABLED=true
BACKUP_STORAGE=s3://company-backups/cyberblue
BACKUP_ENCRYPTION=true
BACKUP_RETENTION_DAYS=90
```

#### Production Docker Swarm Stack
```yaml
# docker-stack.production.yml
version: '3.8'

services:
  portal:
    image: cyberblue/portal:latest
    deploy:
      replicas: 3
      placement:
        constraints:
          - node.role == worker
      resources:
        limits:
          memory: 2G
          cpus: '1.0'
        reservations:
          memory: 1G
          cpus: '0.5'
      restart_policy:
        condition: on-failure
        delay: 5s
        max_attempts: 3
    ports:
      - "443:5500"
    secrets:
      - ssl_cert
      - ssl_key
    configs:
      - source: portal_config
        target: /app/config.yml

  wazuh-manager:
    image: wazuh/wazuh-manager:4.12.0
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.role == siem
      resources:
        limits:
          memory: 8G
          cpus: '4.0'
    volumes:
      - wazuh_data:/var/ossec

  # External monitoring
  prometheus:
    image: prom/prometheus:latest
    deploy:
      replicas: 1
      placement:
        constraints:
          - node.labels.role == monitoring
    configs:
      - source: prometheus_config
        target: /etc/prometheus/prometheus.yml

secrets:
  ssl_cert:
    external: true
  ssl_key:
    external: true

configs:
  portal_config:
    external: true
  prometheus_config:
    external: true

volumes:
  wazuh_data:
    driver: local
    driver_opts:
      type: nfs
      o: addr=storage.company.com,rw
      device: :/exports/cyberblue/wazuh
```

### Production Deployment
```bash
# Initialize Docker Swarm
docker swarm init

# Deploy secrets
echo "cert_content" | docker secret create ssl_cert -
echo "key_content" | docker secret create ssl_key -

# Deploy stack
docker stack deploy -c docker-stack.production.yml cyberblue

# Monitor deployment
docker service ls
docker stack ps cyberblue
```

---

## ☁️ **Cloud Deployments**

### AWS Deployment

#### Infrastructure as Code (Terraform)
```hcl
# main.tf
provider "aws" {
  region = var.aws_region
}

# VPC and Networking
resource "aws_vpc" "cyberblue" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "CyberBlue-VPC"
  }
}

# EC2 Instance for CyberBlue
resource "aws_instance" "cyberblue" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type         = "m5.4xlarge"  # 16 vCPU, 64GB RAM
  key_name              = var.key_pair_name
  vpc_security_group_ids = [aws_security_group.cyberblue.id]
  subnet_id             = aws_subnet.cyberblue_public.id

  root_block_device {
    volume_type = "gp3"
    volume_size = 500
    encrypted   = true
  }

  user_data = file("${path.module}/scripts/install-cyberblue.sh")

  tags = {
    Name = "CyberBlue-Main"
  }
}

# Security Group
resource "aws_security_group" "cyberblue" {
  name_description = "CyberBlue Security Group"
  vpc_id          = aws_vpc.cyberblue.id

  # Portal access
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  # Tool ports
  ingress {
    from_port   = 7000
    to_port     = 7099
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# RDS for external database
resource "aws_db_instance" "cyberblue" {
  identifier = "cyberblue-db"
  engine     = "postgres"
  
  instance_class    = "db.r5.2xlarge"
  allocated_storage = 500
  storage_encrypted = true
  
  db_name  = "cyberblue"
  username = var.db_username
  password = var.db_password
  
  vpc_security_group_ids = [aws_security_group.database.id]
  db_subnet_group_name   = aws_db_subnet_group.cyberblue.name
  
  backup_retention_period = 30
  backup_window          = "03:00-04:00"
  maintenance_window     = "sun:04:00-sun:05:00"
  
  skip_final_snapshot = false
  final_snapshot_identifier = "cyberblue-final-snapshot"
}
```

#### AWS User Data Script
```bash
#!/bin/bash
# scripts/install-cyberblue.sh

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker ubuntu

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Clone CyberBlue
cd /opt
git clone https://github.com/m7siri/cyber-blue-project.git cyberblue
cd cyberblue

# Configure for production
cp .env.production .env
echo "HOST_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)" >> .env

# Deploy
./quick-start.sh

# Setup systemd service
cat > /etc/systemd/system/cyberblue.service << EOF
[Unit]
Description=CyberBlue Security Platform
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/opt/cyberblue
ExecStart=/usr/local/bin/docker-compose up -d
ExecStop=/usr/local/bin/docker-compose down
TimeoutStartSec=0

[Install]
WantedBy=multi-user.target
EOF

systemctl enable cyberblue
systemctl start cyberblue
```

### Azure Deployment

#### Azure Resource Manager Template
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmSize": {
      "type": "string",
      "defaultValue": "Standard_D8s_v3",
      "metadata": {
        "description": "Size of the virtual machine"
      }
    }
  },
  "variables": {
    "vnetName": "CyberBlue-VNet",
    "subnetName": "CyberBlue-Subnet",
    "vmName": "CyberBlue-VM",
    "nicName": "CyberBlue-NIC",
    "nsgName": "CyberBlue-NSG"
  },
  "resources": [
    {
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2020-06-01",
      "name": "[variables('vnetName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": ["10.0.0.0/16"]
        },
        "subnets": [
          {
            "name": "[variables('subnetName')]",
            "properties": {
              "addressPrefix": "10.0.1.0/24"
            }
          }
        ]
      }
    },
    {
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2020-06-01",
      "name": "[variables('vmName')]",
      "location": "[resourceGroup().location]",
      "properties": {
        "hardwareProfile": {
          "vmSize": "[parameters('vmSize')]"
        },
        "osProfile": {
          "computerName": "[variables('vmName')]",
          "adminUsername": "azureuser",
          "customData": "[base64(file('scripts/azure-init.sh'))]"
        },
        "storageProfile": {
          "osDisk": {
            "createOption": "FromImage",
            "diskSizeGB": 500,
            "managedDisk": {
              "storageAccountType": "Premium_LRS"
            }
          }
        }
      }
    }
  ]
}
```

### Google Cloud Platform

#### GCP Deployment Manager
```yaml
# gcp-deployment.yaml
resources:
- name: cyberblue-vm
  type: compute.v1.instance
  properties:
    zone: us-central1-a
    machineType: zones/us-central1-a/machineTypes/n1-standard-16
    disks:
    - deviceName: boot
      type: PERSISTENT
      boot: true
      autoDelete: true
      initializeParams:
        sourceImage: projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts
        diskSizeGb: 500
        diskType: zones/us-central1-a/diskTypes/pd-ssd
    networkInterfaces:
    - network: global/networks/default
      accessConfigs:
      - name: External NAT
        type: ONE_TO_ONE_NAT
    metadata:
      items:
      - key: startup-script
        value: |
          #!/bin/bash
          # GCP-specific startup script
          curl -fsSL https://get.docker.com -o get-docker.sh
          sh get-docker.sh
          usermod -aG docker ubuntu
          
          cd /opt
          git clone https://github.com/m7siri/cyber-blue-project.git cyberblue
          cd cyberblue
          
          # Configure for GCP
          cp .env.production .env
          echo "HOST_IP=$(curl -s http://metadata.google.internal/computeMetadata/v1/instance/network-interfaces/0/external-ip -H 'Metadata-Flavor: Google')" >> .env
          
          ./quick-start.sh
```

---

## 🔧 **Specialized Deployments**

### Air-Gapped Environment

For environments without internet connectivity.

#### Preparation (Online Environment)
```bash
# Save all Docker images
./scripts/export-images.sh

# Create offline package
tar -czf cyberblue-offline.tar.gz \
  docker-images/ \
  cyber-blue-project/ \
  offline-install.sh
```

#### Offline Installation
```bash
# offline-install.sh
#!/bin/bash

# Load Docker images
for image in docker-images/*.tar; do
  docker load -i "$image"
done

# Install CyberBlue
cd cyber-blue-project
cp .env.airgapped .env
./cyberblue_init.sh --offline
```

### High Availability Deployment

#### Docker Swarm Cluster
```bash
# Initialize cluster on manager node
docker swarm init --advertise-addr MANAGER_IP

# Join worker nodes
docker swarm join --token TOKEN MANAGER_IP:2377

# Deploy with HA configuration
docker stack deploy -c docker-stack.ha.yml cyberblue
```

#### HA Configuration
```yaml
# docker-stack.ha.yml
version: '3.8'

services:
  portal:
    image: cyberblue/portal:latest
    deploy:
      replicas: 3
      placement:
        max_replicas_per_node: 1
      update_config:
        parallelism: 1
        delay: 10s
        failure_action: rollback

  wazuh-manager:
    deploy:
      replicas: 2
      placement:
        constraints:
          - node.labels.wazuh == true

  opensearch:
    deploy:
      replicas: 3
      placement:
        max_replicas_per_node: 1
```

---

## 📊 **Resource Planning**

### Small Environment (1-50 Users)
- **VM**: 8 cores, 16GB RAM, 200GB SSD
- **Services**: Core tools only (Wazuh, MISP, Portal)
- **Cost**: ~$200-400/month (cloud)

### Medium Environment (50-200 Users)
- **VM**: 16 cores, 32GB RAM, 500GB SSD
- **Services**: Full stack with monitoring
- **Cost**: ~$500-800/month (cloud)

### Large Environment (200+ Users)
- **Cluster**: 3x VMs (16 cores, 32GB RAM each)
- **Services**: HA deployment with external databases
- **Cost**: ~$1500-3000/month (cloud)

---

## 🔒 **Security Considerations by Environment**

### Development
- Basic authentication
- Self-signed certificates
- Local access only

### Staging
- Strong passwords
- Valid SSL certificates
- VPN access required

### Production
- Multi-factor authentication
- CA-signed certificates
- Network segregation
- Regular security audits
- Compliance monitoring

---

*This deployment guide is regularly updated with new scenarios and best practices. Check the GitHub repository for the latest configurations.*
