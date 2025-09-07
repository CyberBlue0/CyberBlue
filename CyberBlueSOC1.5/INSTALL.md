# 📋 CyberBlue Installation Guide

This comprehensive guide will walk you through installing and configuring CyberBlue on your system.

---

## 📋 Pre-Installation Checklist

### ✅ **System Requirements**

#### Minimum Requirements
- **Operating System**: Linux (Ubuntu 20.04+, CentOS 8+, Debian 11+)
- **CPU**: 4 cores minimum
- **RAM**: 8GB minimum
- **Storage**: 50GB free disk space
- **Network**: Internet connection for Docker image downloads

#### Recommended Requirements
- **Operating System**: Ubuntu 22.04 LTS or CentOS Stream 9
- **CPU**: 8+ cores (Intel i7/AMD Ryzen 7 or better)
- **RAM**: 16GB+ (32GB for production)
- **Storage**: 100GB+ SSD with high IOPS
- **Network**: Gigabit Ethernet

#### Supported Platforms
- ✅ **Linux**: Ubuntu, CentOS, RHEL, Debian, Fedora
- ✅ **macOS**: Intel and Apple Silicon (M1/M2)
- ✅ **Windows**: Via WSL2 (Windows Subsystem for Linux)

---

## 🐳 Docker & Docker Compose Installation

### Ubuntu/Debian Installation

```bash
# Update package index
sudo apt update && sudo apt upgrade -y

# Install required packages
sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release

# Add Docker's official GPG key
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Add Docker repository
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Enable Docker to start on boot
sudo systemctl enable docker
sudo systemctl start docker

# Verify installation
docker --version
docker compose version
```

### CentOS/RHEL Installation

```bash
# Install required packages
sudo dnf install -y dnf-utils

# Add Docker repository
sudo dnf config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo

# Install Docker Engine
sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Start and enable Docker
sudo systemctl start docker
sudo systemctl enable docker

# Add user to docker group
sudo usermod -aG docker $USER
newgrp docker

# Verify installation
docker --version
docker compose version
```

### macOS Installation

1. Download Docker Desktop from [docker.com](https://www.docker.com/products/docker-desktop)
2. Install the `.dmg` file
3. Start Docker Desktop
4. Verify installation in terminal:
   ```bash
   docker --version
   docker compose version
   ```

---

## 📥 Downloading CyberBlue

### Method 1: Git Clone (Recommended)

```bash
# Clone the repository
git clone https://github.com/CyberBlue0/CyberBlueSOC1.git

# Navigate to directory
cd CyberBlueSOC

# Verify files
ls -la
```

### Method 2: Download ZIP

```bash
# Download and extract
wget https://github.com/CyberBlue0/CyberBlueSOC1/archive/main.zip
unzip main.zip
cd CyberBlueSOC1-main
```

---

## ⚙️ Configuration

### 1. Environment Configuration

```bash
# Copy environment template
cp .env.template .env

# Edit configuration file
nano .env
```

### 2. Environment Variables

Configure the following variables in `.env`:

```bash
# =================================
# NETWORK CONFIGURATION
# =================================
HOST_IP=10.0.0.40                    # Your server's IP address
NETWORK_SUBNET=172.18.0.0/16         # Docker internal network
PORTAL_PORT=5500                     # CyberBlue portal port

# =================================
# SECURITY CONFIGURATION
# =================================
WAZUH_ADMIN_PASSWORD=SecurePass123!
OPENSEARCH_ADMIN_PASSWORD=SecurePass123!
MISP_ADMIN_EMAIL=admin@cyberblue.local
MISP_ADMIN_PASSWORD=SecurePass123!

# =================================
# DATABASE CONFIGURATION
# =================================
POSTGRES_PASSWORD=SecurePass123!
MYSQL_ROOT_PASSWORD=SecurePass123!
ELASTICSEARCH_PASSWORD=SecurePass123!

# =================================
# SSL CONFIGURATION
# =================================
SSL_CERT_PATH=./ssl/cert.pem
SSL_KEY_PATH=./ssl/key.pem
```

### 3. System Optimization

```bash
# Increase virtual memory for Elasticsearch
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Increase file descriptor limits
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# Optimize Docker daemon
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<EOF
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "storage-driver": "overlay2"
}
EOF

sudo systemctl restart docker
```

---

## 🚀 Deployment

### Quick Start Deployment (Recommended)

```bash
# Make scripts executable
chmod +x cyberblue_init.sh

# Run initialization script (includes everything)
./cyberblue_init.sh
```

This single script will:
- Configure dynamic network interface detection
- Set up environment variables automatically
- Deploy all Docker containers
- Initialize Arkime with sample traffic data
- Set up Suricata with proper interface detection
- Install and configure Caldera
- Generate SSL certificates for HTTPS
- Create admin users for all tools
- Start the secure portal with authentication

### Manual Deployment (Advanced)

```bash
# 1. Initialize system with all enhancements
./cyberblue_init.sh

# 2. Optional: Reinitialize specific components
./scripts/initialize-arkime.sh --capture-live
./update-network-interface.sh --restart-suricata

# 3. Monitor deployment
sudo docker-compose logs -f

# 4. Verify all services
sudo docker ps
```

### Step-by-Step Deployment

```bash
# 1. Pull all images (optional, for faster startup)
docker compose pull

# 2. Create networks
docker network create cyberblue-network

# 3. Start core services first
docker compose up -d opensearch wazuh-indexer

# 4. Wait for core services (30 seconds)
sleep 30

# 5. Start remaining services
docker compose up -d

# 6. Verify all containers are running
docker compose ps
```

---

## ✅ Verification & Testing

### 1. Container Health Check

```bash
# Check all containers
docker compose ps

# Expected output: All services should show "running" status
# If any service shows "unhealthy" or "exited", check logs:
docker compose logs [service-name]
```

### 2. Service Accessibility Test

```bash
# Test portal accessibility (HTTPS with authentication)
curl -k -f https://localhost:5443/login || echo "Portal not accessible"

# Test individual services
curl -k -f https://localhost:7000 || echo "Velociraptor not accessible"
curl -k -f https://localhost:7001 || echo "Wazuh not accessible"
curl -f http://localhost:7004 || echo "CyberChef not accessible"
curl -f http://localhost:7008 || echo "Arkime not accessible"
curl -f http://localhost:7009 || echo "Caldera not accessible"
curl -f http://localhost:7015 || echo "EveBox not accessible"

# Test with authentication (example for Arkime)
curl -u admin:admin http://localhost:7008/api/sessions
```

### 3. Port Verification

```bash
# Check all CyberBlueSOC ports
sudo ss -tulpn | grep -E "(5443|5500|700[0-9]|7010|7011|7013|7014|9443)"

# Expected ports:
# 5443 - Portal HTTPS
# 7000 - Velociraptor HTTPS
# 7001 - Wazuh HTTPS  
# 7002 - Shuffle HTTPS
# 7003 - MISP HTTPS
# 7004 - CyberChef HTTP
# 7005 - TheHive HTTP
# 7006 - Cortex HTTP
# 7007 - FleetDM HTTP
# 7008 - Arkime HTTP
# 7009 - Caldera HTTP
# 7015 - EveBox HTTP
# 7011 - Wireshark HTTP
# 7013 - MITRE Navigator HTTP
# 7014 - OpenVAS HTTP
# 9443 - Portainer HTTPS

# Quick port test
for port in 5443 7000 7001 7002 7003 7004 7005 7006 7007 7008 7009 7010 7011 7013 7014 7015 9443; do
  nc -z localhost $port && echo "Port $port: OPEN" || echo "Port $port: CLOSED"
done
```

---

## 🔧 First-Time Service Setup

### 1. CyberBlue Portal (Primary Interface)

1. Access: `https://YOUR_IP:5443`
2. Login: `admin` / `cyberblue123`
3. Navigate through the beautiful dashboard
4. Access all tools through the portal interface

### 2. Wazuh Dashboard Setup

1. Access: `https://YOUR_IP:7001`
2. Login: `admin` / `SecretPassword`
3. Complete initial setup wizard
4. Configure agents as needed
5. Review pre-configured detection rules

### 3. MISP Setup

1. Access: `https://YOUR_IP:7003`
2. Login: `admin@admin.test` / `admin`
3. Complete organization setup
4. Configure feeds and taxonomies
5. Import threat intelligence feeds

### 4. Arkime Network Analysis

1. Access: `http://YOUR_IP:7008`
2. Login: `admin` / `admin`
3. **Sample data already loaded** - 98 packets ready for analysis
4. Explore network sessions and packet details
5. Upload additional PCAP files as needed

### 5. Caldera Adversary Emulation

1. Access: `http://YOUR_IP:7009`
2. Login: `red` / `cyberblue` (Red Team) or `blue` / `cyberblue` (Blue Team)
3. Explore pre-loaded adversary techniques
4. Set up agents for testing
5. Create custom attack scenarios

### 6. Velociraptor Endpoint Forensics

1. Access: `https://YOUR_IP:7000`
2. Login: `admin` / `cyberblue`
3. Configure client endpoints
4. Set up artifact collection
5. Deploy agents to endpoints

### 7. Shuffle Automation Platform

1. Access: `https://YOUR_IP:7002`
2. Login: `admin` / `password`
3. Configure app integrations
4. Build your first security workflow
5. Connect with other CyberBlueSOC tools

### 8. Additional Tools

- **Cortex**: `http://YOUR_IP:7006` (admin/cyberblue123) - Observable analysis
- **TheHive**: `http://YOUR_IP:7005` (admin@thehive.local/secret) - Case management
- **EveBox**: `http://YOUR_IP:7015` (no auth) - **50K+ Suricata events ready**
- **CyberChef**: `http://YOUR_IP:7004` (no auth) - Data analysis toolkit
- **OpenVAS**: `http://YOUR_IP:7014` (admin/cyberblue) - Vulnerability scanning
- **Portainer**: `https://YOUR_IP:9443` (admin/cyberblue123) - Container management

---

## 📊 Advanced Configuration

### Custom Domain Setup

```bash
# Add to /etc/hosts or configure DNS
echo "YOUR_IP cyberblue.local" | sudo tee -a /etc/hosts
echo "YOUR_IP wazuh.cyberblue.local" | sudo tee -a /etc/hosts
echo "YOUR_IP misp.cyberblue.local" | sudo tee -a /etc/hosts
```

### SSL Certificate Configuration

```bash
# Generate self-signed certificates
mkdir -p ssl
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ssl/key.pem \
  -out ssl/cert.pem \
  -subj "/C=US/ST=State/L=City/O=CyberBlue/CN=cyberblue.local"

# Or use Let's Encrypt for production
# certbot certonly --standalone -d your-domain.com
```

### Resource Optimization

```bash
# For systems with limited resources, edit docker-compose.yml:
# Reduce memory limits for services
# Disable unnecessary services

# Example: Disable some services
docker compose stop wireshark evebox
```

---

## 🔍 Troubleshooting

### Common Installation Issues

#### Docker Permission Denied
```bash
# Fix: Add user to docker group
sudo usermod -aG docker $USER
newgrp docker
```

#### Out of Memory Errors
```bash
# Increase virtual memory
sudo sysctl -w vm.max_map_count=262144
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
```

#### Port Already in Use
```bash
# Find process using port
sudo netstat -tulpn | grep :7001
# Kill process
sudo kill -9 [PID]
```

#### Container Fails to Start
```bash
# Check logs
docker compose logs [service-name]

# Restart specific service
docker compose restart [service-name]

# Rebuild container
docker compose up -d --force-recreate [service-name]
```

### Service-Specific Issues

#### Elasticsearch/OpenSearch Issues
```bash
# Check cluster health
curl -X GET "localhost:9200/_cluster/health?pretty"

# Reset passwords
docker compose exec opensearch /usr/share/opensearch/plugins/opensearch-security/tools/securityadmin.sh -cd /usr/share/opensearch/plugins/opensearch-security/securityconfig/ -icl -nhnv -cacert /usr/share/opensearch/config/certificates/root-ca.pem -cert /usr/share/opensearch/config/certificates/admin.pem -key /usr/share/opensearch/config/certificates/admin.key
```

#### Database Connection Issues
```bash
# Test database connectivity
docker compose exec postgres psql -U postgres -c "\l"
docker compose exec mysql mysql -u root -p -e "SHOW DATABASES;"
```

### Performance Monitoring

```bash
# Monitor resource usage
docker stats

# Check disk usage
docker system df

# Clean up unused resources
docker system prune -a
```

---

## 🔄 Maintenance Tasks

### Regular Updates

```bash
# Update images
docker compose pull

# Restart with new images
docker compose up -d --force-recreate
```

### Backup Procedures

```bash
# Backup configurations
tar -czf cyberblue-backup-$(date +%Y%m%d).tar.gz \
  .env docker-compose.yml configs/ ssl/

# Backup databases
docker compose exec postgres pg_dumpall -U postgres > postgres-backup.sql
docker compose exec mysql mysqldump -u root -p --all-databases > mysql-backup.sql
```

### Log Management

```bash
# View logs
docker compose logs -f --tail=100

# Clean old logs
docker system prune --volumes
```

---

## 📚 Next Steps

After successful installation:

1. **📖 Read the User Guide**: Learn how to use each tool effectively
2. **🔒 Review Security Guide**: Implement security best practices
3. **🎯 Configure Use Cases**: Set up specific detection scenarios
4. **📊 Set Up Monitoring**: Configure alerting and dashboards
5. **🤝 Join Community**: Participate in discussions and contribute

---

## 🆘 Getting Help

If you encounter issues:

1. **Check Logs**: `sudo docker logs [container-name]`
2. **Review Troubleshooting**: Common issues above and [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
3. **Check Arkime Setup**: [Arkime Setup Guide](ARKIME_SETUP.md)
4. **Search Issues**: [GitHub Issues](https://github.com/CyberBlue0/CyberBlueSOC1/issues)
5. **Ask Community**: [GitHub Discussions](https://github.com/CyberBlue0/CyberBlueSOC1/discussions)
6. **Report Bug**: Create detailed issue report with system verification

---

## 📋 Summary

Congratulations! You've successfully installed CyberBlue. Your cybersecurity lab is now ready with:

- ✅ **15+ Security Tools** fully configured and operational
- ✅ **Secure HTTPS Portal** with authentication at `https://YOUR_IP:5443`
- ✅ **Real Data Integration** - Arkime with network traffic, Suricata with 50K+ events
- ✅ **Production-ready** configurations with SSL encryption
- ✅ **Monitoring & Logging** enabled with comprehensive changelog
- ✅ **Security Hardening** applied with authentication and access controls
- ✅ **Dynamic Configuration** with automatic network interface detection
- ✅ **Backup & Recovery** system for disaster recovery
- ✅ **Enterprise Features** ready for production deployment

**Next Steps**:
1. **Access Portal**: `https://YOUR_IP:5443` (admin/cyberblue123)
2. **Explore Arkime**: Network analysis with sample traffic data
3. **Review EveBox**: 50K+ Suricata security events ready for analysis
4. **Test Caldera**: Adversary emulation scenarios available
5. **Configure Tools**: Customize individual tools for your environment

---

*Need help? Check our [Documentation](README.md) or [Support Channels](https://github.com/CyberBlue0/CyberBlueSOC1/discussions)* 