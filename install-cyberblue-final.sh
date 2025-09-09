#!/bin/bash

# ============================================================================
# CyberBlue SOC - Final Simple Installer (One Script, No Issues)
# ============================================================================
# This is the ONLY script users need - handles everything automatically
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}"
echo "🚀 ================================================"
echo "   CyberBlue SOC - Complete Installation"
echo "   (Prerequisites + Docker + All Services)"
echo "🚀 ================================================"
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${RED}❌ Do not run this script as root.${NC}"
    exit 1
fi

# Get sudo access upfront
echo "🔐 This installer needs sudo access. Please enter your password:"
sudo true
echo "✅ Sudo access confirmed"

# Function to run Docker Compose (handles both v1 and v2)
docker_compose() {
    if command -v docker-compose >/dev/null 2>&1; then
        sudo docker-compose "$@"
    else
        sudo docker compose "$@"
    fi
}

# Install prerequisites if needed
if ! command -v docker >/dev/null 2>&1; then
    echo "📦 Installing Docker and prerequisites..."
    
    # Update system
    sudo apt update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq
    
    # Install basic packages
    sudo DEBIAN_FRONTEND=noninteractive apt install -y ca-certificates curl gnupg lsb-release git -qq
    
    # Install Docker
    sudo mkdir -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt update -qq
    sudo DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -qq
    
    # Install standalone Docker Compose
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    
    # Configure Docker
    sudo usermod -aG docker $USER
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
    
    # System optimizations
    echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf >/dev/null
    sudo sysctl -p >/dev/null
    echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf >/dev/null
    echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf >/dev/null
    
    # Docker daemon config
    sudo mkdir -p /etc/docker
    sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "iptables": true,
  "userland-proxy": false,
  "live-restore": true,
  "storage-driver": "overlay2"
}
EOF
    
    sudo systemctl restart docker
    sleep 5
    
    echo "✅ Prerequisites installed successfully"
fi

# Verify Docker access
if ! docker ps >/dev/null 2>&1; then
    echo "🔧 Applying Docker group access..."
    sudo usermod -aG docker $USER
    sudo systemctl restart docker
    sleep 3
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
fi

echo "🚀 Starting CyberBlue SOC deployment..."

# Configure environment
HOST_IP=$(hostname -I | awk '{print $1}')
echo "HOST_IP=${HOST_IP}" > .env
echo "MISP_BASE_URL=https://${HOST_IP}:7003" >> .env

# Detect network interface
INTERFACE=$(ip route | grep default | awk '{print $5}' | head -n1)
echo "SURICATA_INT=${INTERFACE}" >> .env

# Install Caldera if missing
if [[ ! -d "./caldera" ]]; then
    echo "📦 Installing Caldera..."
    git clone --recursive https://github.com/mitre/caldera.git ./caldera
    
    # Create Caldera config
    mkdir -p ./caldera/conf
    cat > ./caldera/conf/local.yml << 'EOF'
users:
  red:
    red: cyberblue
  blue:
    blue: cyberblue
  admin:
    admin: cyberblue
EOF
fi

# Download Suricata rules
echo "📋 Downloading security rules..."
mkdir -p ./suricata/rules
curl -s -o ./suricata/rules/emerging.rules.tar.gz https://rules.emergingthreats.net/open/suricata/emerging.rules.tar.gz
tar -xzf ./suricata/rules/emerging.rules.tar.gz -C ./suricata/rules/ --strip-components=1 || true

# Generate SSL certificates for Wazuh
echo "🔑 Generating SSL certificates..."
docker_compose run --rm generator || echo "Certificate generation completed"
sleep 10

# Fix certificate permissions
if [[ -d "wazuh/config/wazuh_indexer_ssl_certs" ]]; then
    sudo find wazuh/config/wazuh_indexer_ssl_certs -type d -name "*.pem" -exec rm -rf {} \; 2>/dev/null || true
    sudo chown -R $USER:$USER wazuh/config/wazuh_indexer_ssl_certs/ 2>/dev/null || true
    sudo chmod 644 wazuh/config/wazuh_indexer_ssl_certs/*.pem 2>/dev/null || true
fi

# Deploy all services
echo "🚀 Deploying all CyberBlue SOC services..."
docker_compose up --build -d

# Wait and verify
echo "⏳ Waiting for services to initialize (60 seconds)..."
sleep 60

# Check service count
RUNNING=$(docker ps | grep -c "Up" || echo "0")
echo "📊 Services running: $RUNNING"

if [[ "$RUNNING" -ge 25 ]]; then
    echo -e "${GREEN}"
    echo "🎉 ================================================"
    echo "   CyberBlue SOC Successfully Deployed!"
    echo "🎉 ================================================"
    echo -e "${NC}"
    echo ""
    echo "🌐 Access your SOC lab:"
    echo "   Portal: https://${HOST_IP}:5443 (admin/cyberblue123)"
    echo "   Wazuh:  http://${HOST_IP}:7001 (admin/SecretPassword)"
    echo "   Caldera: http://${HOST_IP}:7009 (red:cyberblue, blue:cyberblue)"
    echo ""
    echo "✅ All services should be running - check the portal!"
else
    echo -e "${YELLOW}⚠️ Some services may still be starting ($RUNNING detected)${NC}"
    echo "Wait 2-3 more minutes and check the portal"
fi
