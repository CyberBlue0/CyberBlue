#!/bin/bash

# ============================================================================
# CyberBlue SOC - Simple Installation (No Hanging, No Logout Required)
# ============================================================================
# This script handles sudo upfront and runs everything without interruption
# ============================================================================

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}"
echo "🚀 =================================="
echo "   CyberBlue SOC Simple Installer"
echo "🚀 =================================="
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}❌ Do not run this script as root.${NC}"
    exit 1
fi

# Get sudo access upfront to prevent hanging
echo "🔐 This script needs sudo access for Docker installation."
echo "Please enter your password once (will be cached for the session):"
sudo true

# Extend sudo timeout
sudo sh -c 'echo "Defaults timestamp_timeout=30" >> /etc/sudoers.d/cyberblue-install' 2>/dev/null || true

echo "✅ Sudo access confirmed and cached"
echo ""

# Check if Docker is already installed
if command -v docker >/dev/null 2>&1 && docker ps >/dev/null 2>&1; then
    echo "✅ Docker already installed and accessible"
    echo "🚀 Starting CyberBlue installation..."
    ./cyberblue_init.sh
    exit 0
fi

echo "📦 Installing prerequisites (non-interactive)..."

# System update
echo "🔄 Updating system packages..."
sudo apt update -qq
sudo DEBIAN_FRONTEND=noninteractive apt upgrade -y -qq

# Install basic packages
echo "📦 Installing basic packages..."
sudo DEBIAN_FRONTEND=noninteractive apt install -y ca-certificates curl gnupg lsb-release git -qq

# Install Docker
echo "🐳 Installing Docker..."
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update -qq
sudo DEBIAN_FRONTEND=noninteractive apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -qq

# Configure Docker
echo "⚙️ Configuring Docker..."
sudo usermod -aG docker $USER
sudo systemctl enable docker
sudo systemctl start docker

# System optimizations
echo "🔧 Applying system optimizations..."
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf >/dev/null
sudo sysctl -p >/dev/null
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf >/dev/null
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf >/dev/null

# Docker daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "iptables": true,
  "userland-proxy": false,
  "live-restore": true,
  "storage-driver": "overlay2"
}
EOF

# Restart Docker
sudo systemctl restart docker
sleep 5

# Fix Docker permissions for immediate access
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock

echo "✅ Prerequisites installation completed"

# Test Docker access
if sg docker -c "docker --version" >/dev/null 2>&1; then
    echo "✅ Docker access ready"
    echo "🚀 Starting CyberBlue installation in Docker context..."
    exec sg docker -c "$PWD/cyberblue_init.sh"
else
    echo "⚠️ Docker group needs session refresh"
    echo "🔄 Restarting in new Docker group context..."
    exec newgrp docker -c "$PWD/cyberblue_init.sh"
fi
