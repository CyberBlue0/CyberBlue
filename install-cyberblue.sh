#!/bin/bash

# ============================================================================
# CyberBlue SOC - Complete Installation Wrapper
# ============================================================================
# This wrapper handles the Docker group issue and ensures smooth installation
# without requiring logout/login during the process.
# ============================================================================

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "🚀 =================================="
echo "   CyberBlue SOC Complete Installer"
echo "🚀 =================================="
echo -e "${NC}"

# Check if running as root
if [[ $EUID -eq 0 ]]; then
    echo -e "${YELLOW}❌ Do not run this script as root.${NC}"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Function to check if Docker is accessible
check_docker_access() {
    if docker ps >/dev/null 2>&1; then
        return 0
    elif sg docker -c "docker ps" >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

echo -e "${CYAN}🔍 Checking current system state...${NC}"

# Verify sudo access upfront
echo "🔐 Verifying sudo access..."
if ! sudo -n true 2>/dev/null; then
    echo "Please enter your password for sudo access:"
    sudo true
fi
echo "✅ Sudo access confirmed"

# Check if prerequisites are needed
if ! command -v docker >/dev/null 2>&1; then
    echo "📦 Installing prerequisites..."
    chmod +x install-prerequisites.sh
    ./install-prerequisites.sh --force
    
    echo -e "${YELLOW}🔧 Docker group was added. Restarting in Docker context...${NC}"
    
    # Execute the main installation in Docker group context
    exec sg docker -c "$SCRIPT_DIR/cyberblue_init.sh"
    
elif ! check_docker_access; then
    echo -e "${YELLOW}🔧 Docker is installed but group access needed. Fixing permissions...${NC}"
    
    # Fix Docker permissions
    sudo usermod -aG docker $USER
    sudo systemctl restart docker
    sleep 3
    sudo chown root:docker /var/run/docker.sock
    sudo chmod 660 /var/run/docker.sock
    
    # Execute in Docker group context
    exec sg docker -c "$SCRIPT_DIR/cyberblue_init.sh"
    
else
    echo "✅ Prerequisites satisfied, starting CyberBlue installation..."
    ./cyberblue_init.sh
fi
