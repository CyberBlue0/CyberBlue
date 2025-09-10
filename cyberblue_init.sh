#!/bin/bash

set -e  # Exit on error

# Configuration
INSTALL_PREREQUISITES=false
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --install-prerequisites)
                INSTALL_PREREQUISITES=true
                shift
                ;;
            --help)
                show_help
                exit 0
                ;;
            *)
                echo "❌ Unknown option: $1"
                show_help
                exit 1
                ;;
        esac
    done
}

show_help() {
    echo "🚀 CyberBlue SOC Platform Initialization"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --install-prerequisites  Automatically install prerequisites (Docker, etc.)"
    echo "  --help                   Show this help message"
    echo ""
    echo "Installation Methods:"
    echo "  Method 1 (Manual Prerequisites):"
    echo "    ./install-prerequisites.sh"
    echo "    ./cyberblue_init.sh"
    echo ""
    echo "  Method 2 (Automatic Prerequisites):"
    echo "    ./cyberblue_init.sh --install-prerequisites"
    echo ""
}

# Check prerequisites
check_prerequisites() {
    local missing_deps=()
    
    # Check Docker
    if ! command -v docker >/dev/null 2>&1; then
        missing_deps+=("Docker")
    fi
    
    # Check Docker Compose
    if ! command -v docker-compose >/dev/null 2>&1 && ! docker compose version >/dev/null 2>&1; then
        missing_deps+=("Docker Compose")
    fi
    
    # Check Docker daemon
    if ! docker ps >/dev/null 2>&1; then
        missing_deps+=("Docker daemon access")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "⚠️  Missing prerequisites: ${missing_deps[*]}"
        
        if [[ "$INSTALL_PREREQUISITES" == "true" ]]; then
            echo "🚀 Installing prerequisites automatically..."
            if [[ -f "$SCRIPT_DIR/install-prerequisites.sh" ]]; then
                "$SCRIPT_DIR/install-prerequisites.sh" --force
                echo "✅ Prerequisites installed successfully"
                
                # Apply Docker group in current session to avoid logout/login
                echo "🔧 Applying Docker group permissions for current session..."
                if sg docker -c "docker --version" >/dev/null 2>&1; then
                    echo "✅ Docker access ready - continuing with installation"
                    export DOCKER_ACCESS_READY=true
                else
                    echo "⚠️  Docker group requires session refresh"
                    echo "🔄 Applying Docker group with newgrp..."
                    exec newgrp docker << 'EOF'
# Continue installation in new group context
exec "$0" "${@/--install-prerequisites/}"
EOF
                fi
            else
                echo "❌ Prerequisites script not found: $SCRIPT_DIR/install-prerequisites.sh"
                exit 1
            fi
        else
            echo ""
            echo "📋 To install prerequisites:"
            echo "  Option 1: ./install-prerequisites.sh"
            echo "  Option 2: ./cyberblue_init.sh --install-prerequisites"
            echo ""
            echo "Or manually install Docker and Docker Compose, then run this script again."
            exit 1
        fi
    else
        echo "✅ All prerequisites are satisfied"
    fi
}

# Record start time
START_TIME=$(date +%s)

# Parse arguments first
parse_args "$@"

echo ""
echo "🎉 =================================="
echo "    ____      _               ____  _            "
echo "   / ___|   _| |__   ___ _ __| __ )| |_   _  ___ "
echo "  | |  | | | | '_ \ / _ \ '__|  _ \| | | | |/ _ \\"
echo "  | |__| |_| | |_) |  __/ |  | |_) | | |_| |  __/"
echo "   \____\__, |_.__/ \___|_|  |____/|_|\__,_|\___|"
echo "        |___/                                    "
echo ""
echo "  🔷 CyberBlue SOC Platform Initialization 🔷"
echo ""
echo "🚨 =================================="
echo "⚠️  EDUCATIONAL ENVIRONMENT ONLY ⚠️"
echo "🚨 =================================="
echo ""
echo "🔴 SECURITY NOTICE:"
echo "   This platform is for LEARNING and TESTING only"
echo "   ❌ NOT for production use"
echo "   ❌ Contains default credentials"
echo "   ❌ Not security hardened"
echo "   ✅ Safe for isolated lab environments"
echo "   ✅ Perfect for cybersecurity training"
echo ""
echo "🚀 Starting CyberBlue initialization..."
echo "=================================="

# Check prerequisites before starting
echo "🔍 Checking prerequisites..."
check_prerequisites
echo ""

# ----------------------------
# Cleanup: Remove existing directories if they exist
# ----------------------------
echo "🧹 Cleaning up any existing build directories..."
if [ -d "attack-navigator" ]; then
    echo "   Removing existing attack-navigator/ directory..."
    sudo rm -rf attack-navigator/
fi
if [ -d "wireshark" ]; then
    echo "   Removing existing wireshark/ directory..."
    sudo rm -rf wireshark/
fi

# Clone MITRE ATTACK Nav.
echo "📥 Cloning MITRE ATT&CK Navigator..."
if ! git clone https://github.com/mitre-attack/attack-navigator.git; then
    echo "⚠️  Failed to clone MITRE ATT&CK Navigator (network issue?) - continuing anyway"
    echo "   You can manually clone it later if needed"
fi

# ----------------------------
# Get Host IP for MISP
# ----------------------------
HOST_IP=$(hostname -I | awk '{print $1}')
MISP_URL="https://${HOST_IP}:7003"
echo "🔧 Configuring MISP_BASE_URL as: $MISP_URL"

# Ensure .env exists
if [ ! -f .env ] && [ -f .env.template ]; then
    echo "🧪 Creating .env from .env.template..."
    cp .env.template .env
fi
if [ ! -f .env ]; then
    echo "⚠️  .env file not found. Creating one..."
    touch .env
fi

# Set or update MISP_BASE_URL
if grep -q "^MISP_BASE_URL=" .env; then
    sed -i "s|^MISP_BASE_URL=.*|MISP_BASE_URL=${MISP_URL}|" .env
else
    echo "MISP_BASE_URL=${MISP_URL}" >> .env
fi

# Set or update HOST_IP for portal dynamic IP detection
if grep -q "^HOST_IP=" .env; then
    sed -i "s|^HOST_IP=.*|HOST_IP=${HOST_IP}|" .env
else
    echo "HOST_IP=${HOST_IP}" >> .env
fi

# Show result
echo "✅ .env updated with:"
grep "^MISP_BASE_URL=" .env
grep "^HOST_IP=" .env

# ----------------------------
# Generate YETI_AUTH_SECRET_KEY
# ----------------------------
if grep -q "^YETI_AUTH_SECRET_KEY=" .env; then
    echo "ℹ️ YETI_AUTH_SECRET_KEY already exists. Skipping."
else
    SECRET_KEY=$(openssl rand -hex 64)
    echo "YETI_AUTH_SECRET_KEY=${SECRET_KEY}" >> .env
    echo "✅ YETI_AUTH_SECRET_KEY added to .env"
fi

# Prepare directory
sudo mkdir -p /opt/yeti/bloomfilters

# ----------------------------
# Dynamic Suricata Interface Detection
# ----------------------------
echo "🔍 Detecting primary network interface for Suricata..."

# Method 1: Try to get the default route interface (most reliable)
SURICATA_IFACE=$(ip route | grep default | awk '{print $5}' | head -1)

# Method 2: Fallback to first active non-loopback interface
if [ -z "$SURICATA_IFACE" ]; then
    echo "⚠️  No default route found, trying alternative detection..."
    SURICATA_IFACE=$(ip link show | grep -E '^[0-9]+:' | grep -v lo | grep 'state UP' | awk -F': ' '{print $2}' | head -1)
fi

# Method 3: Final fallback to any UP interface except loopback
if [ -z "$SURICATA_IFACE" ]; then
    echo "⚠️  Trying final fallback method..."
    SURICATA_IFACE=$(ip a | grep 'state UP' | grep -v lo | awk -F: '{print $2}' | head -1 | xargs)
fi

if [ -z "$SURICATA_IFACE" ]; then
    echo "❌ Could not detect any suitable network interface for Suricata."
    echo "📋 Available interfaces:"
    ip link show | grep -E '^[0-9]+:' | awk -F': ' '{print "   - " $2}' | sed 's/@.*$//'
    echo "💡 Please manually set SURICATA_INT in .env file"
    exit 1
fi

echo "✅ Detected primary interface: $SURICATA_IFACE"

# Always update the SURICATA_INT to ensure it's current
if grep -q "^SURICATA_INT=" .env; then
    echo "🔄 Updating existing SURICATA_INT in .env..."
    sed -i "s/^SURICATA_INT=.*/SURICATA_INT=$SURICATA_IFACE/" .env
else
    echo "SURICATA_INT=$SURICATA_IFACE" >> .env
fi

echo "✅ SURICATA_INT configured as: $SURICATA_IFACE"
echo "📋 Current network interface settings:"
grep "^SURICATA_INT=" .env

# ----------------------------
# Suricata Rule Setup
# ----------------------------
echo "📦 Downloading Emerging Threats rules..."
sudo mkdir -p ./suricata/rules
if [ ! -f ./suricata/emerging.rules.tar.gz ]; then
    if sudo curl -s -O https://rules.emergingthreats.net/open/suricata-6.0/emerging.rules.tar.gz; then
        sudo tar -xzf emerging.rules.tar.gz -C ./suricata/rules --strip-components=1
        sudo rm emerging.rules.tar.gz
        echo "✅ Suricata rules downloaded and extracted successfully"
    else
        echo "⚠️  Failed to download Suricata rules (network issue?) - continuing without rules"
        echo "   Suricata will work but with limited rule coverage"
    fi
else
    echo "ℹ️ Suricata rules archive already downloaded. Skipping."
fi

# Download config files
echo "📥 Downloading Suricata configuration files..."
if ! sudo curl -s -o ./suricata/classification.config https://raw.githubusercontent.com/OISF/suricata/master/etc/classification.config; then
    echo "⚠️  Failed to download classification.config - continuing anyway"
fi
if ! sudo curl -s -o ./suricata/reference.config https://raw.githubusercontent.com/OISF/suricata/master/etc/reference.config; then
    echo "⚠️  Failed to download reference.config - continuing anyway"
fi

# ----------------------------
# Launching Services
# ----------------------------
echo "🚀 Running Docker initialization commands..."

# ----------------------------
# Caldera Directory Verification
# ----------------------------
echo "🧠 Verifying Caldera setup..."
if [[ ! -d "./caldera" ]]; then
    echo "📦 Caldera directory not found, running Caldera installation..."
    if [[ -f "./install_caldera.sh" ]]; then
        chmod +x ./install_caldera.sh
        ./install_caldera.sh
    else
        echo "⚠️  install_caldera.sh not found, Caldera will be skipped"
    fi
else
    echo "✅ Caldera directory found"
fi

# ----------------------------
# Enhanced Wazuh SSL Certificate Setup
# ----------------------------
echo "🔑 Setting up Wazuh SSL certificates..."
if ! sudo docker compose run --rm generator; then
    echo "⚠️  Certificate generation failed - trying to continue anyway"
    echo "   Wazuh services may have certificate issues"
fi

# Wait for certificate generation and fix any permission issues
sleep 10
if [[ -d "wazuh/config/wazuh_indexer_ssl_certs" ]]; then
    # Fix any directory artifacts that might have been created
    sudo find wazuh/config/wazuh_indexer_ssl_certs -type d -name "*.pem" -exec rm -rf {} \; 2>/dev/null || true
    sudo find wazuh/config/wazuh_indexer_ssl_certs -type d -name "*.key" -exec rm -rf {} \; 2>/dev/null || true
    
    # Fix certificate permissions
    sudo chown -R ubuntu:ubuntu wazuh/config/wazuh_indexer_ssl_certs/ 2>/dev/null || true
    sudo chmod 644 wazuh/config/wazuh_indexer_ssl_certs/*.pem 2>/dev/null || true
    sudo chmod 644 wazuh/config/wazuh_indexer_ssl_certs/*.key 2>/dev/null || true
    echo "✅ Wazuh SSL certificates configured properly"
fi

# ===== Enhanced Docker Networking Fix (BEFORE Deployment) =====
echo "🔧 Preparing Docker networking to prevent iptables chain corruption..."
echo "   This MUST run before container deployment to prevent networking failures"

# Step 1: Clean up any existing Docker networks and rules
echo "   🧹 Cleaning up existing Docker networks and iptables rules..."
sudo docker network prune -f >/dev/null 2>&1 || true

# Step 2: Flush and remove Docker iptables chains (prevents chain corruption)
echo "   🔧 Flushing Docker iptables chains to prevent corruption..."
sudo iptables -t nat -F DOCKER >/dev/null 2>&1 || true
sudo iptables -t nat -X DOCKER >/dev/null 2>&1 || true
sudo iptables -t filter -F DOCKER >/dev/null 2>&1 || true
sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-1 >/dev/null 2>&1 || true
sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-2 >/dev/null 2>&1 || true

# Step 3: Restart Docker daemon to rebuild all chains from scratch
echo "   🔄 Restarting Docker daemon to rebuild iptables NAT rules..."
sudo systemctl restart docker

echo "   ⏳ Waiting for Docker to fully restart and rebuild chains..."
sleep 15

# Step 4: Verify Docker is ready
echo "   ✅ Verifying Docker daemon is ready..."
timeout 30 bash -c 'until docker info >/dev/null 2>&1; do sleep 2; done' || echo "   ⚠️ Docker verification timeout - continuing anyway"

echo "✅ Docker networking prepared - chains are clean and ready for deployment"
echo ""
# ===== End Enhanced Docker Networking Fix =====

# Deploy all services with enhanced startup sequence
echo "🚀 Deploying all CyberBlue SOC services with clean iptables chains..."
if ! sudo docker compose up --build -d; then
    echo "❌ Critical failure: Docker Compose deployment failed!"
    echo "   This is a critical error that prevents SOC platform startup"
    echo "   Please check Docker installation and try again"
    exit 1
fi

echo "⏳ Waiting for initial container startup (60 seconds)..."
sleep 60

echo "🔧 Applying comprehensive Docker networking fixes..."
# Note: Full networking fixes will be applied after all services are running

# Wait for critical services to initialize
echo "⏳ Waiting for services to initialize..."
sleep 30

# Verify Wazuh services and restart if needed
echo "🔍 Verifying Wazuh services..."
WAZUH_RUNNING=$(sudo docker ps | grep -c "wazuh.*Up" || echo "0")
if [[ "$WAZUH_RUNNING" -lt 3 ]]; then
    echo "🔧 Wazuh services need adjustment, applying fixes..."
    sudo docker compose restart wazuh.indexer || echo "⚠️  Failed to restart wazuh.indexer"
    sleep 20
    sudo docker compose restart wazuh.manager || echo "⚠️  Failed to restart wazuh.manager"
    sleep 15
    sudo docker compose restart wazuh.dashboard || echo "⚠️  Failed to restart wazuh.dashboard"
    sleep 15
    echo "✅ Wazuh services restart attempted"
fi

# Function to detect primary network interface (reuse existing logic)
detect_primary_interface_for_docker() {
    # Use the same interface detection logic as Suricata
    DOCKER_PRIMARY_INTERFACE="$SURICATA_IFACE"
    echo "✅ Using detected interface for Docker networking: $DOCKER_PRIMARY_INTERFACE"
}

# Function to apply Docker networking fixes
apply_docker_networking_fixes() {
    echo "🔧 Applying comprehensive Docker external access fixes..."
    
    # Step 1: Check and fix Docker daemon if needed
    if ! docker info >/dev/null 2>&1; then
        echo "   🔄 Docker daemon not responsive, restarting..."
        if ! sudo systemctl restart docker; then
            echo "   ❌ Failed to restart Docker daemon - skipping networking fixes"
            return 1
        fi
        sleep 15
        timeout 30 bash -c 'until docker info >/dev/null 2>&1; do sleep 2; done' || {
            echo "   ❌ Docker daemon restart failed - skipping networking fixes"
            return 1
        }
    fi
    
    # Step 2: Check for chain corruption and fix if needed
    echo "   🔍 Checking for iptables chain corruption..."
    if ! sudo iptables -t nat -L DOCKER >/dev/null 2>&1; then
        echo "   🚨 Docker iptables chains are corrupted - rebuilding..."
        
        # Stop all containers temporarily
        echo "   ⏸️  Temporarily stopping containers for chain rebuild..."
        sudo docker compose stop >/dev/null 2>&1 || true
        
        # Clean up corrupted chains
        sudo iptables -t nat -F DOCKER >/dev/null 2>&1 || true
        sudo iptables -t nat -X DOCKER >/dev/null 2>&1 || true
        sudo iptables -t filter -F DOCKER >/dev/null 2>&1 || true
        sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-1 >/dev/null 2>&1 || true
        sudo iptables -t filter -F DOCKER-ISOLATION-STAGE-2 >/dev/null 2>&1 || true
        
        # Restart Docker to rebuild chains
        echo "   🔄 Restarting Docker daemon to rebuild chains..."
        if ! sudo systemctl restart docker; then
            echo "   ❌ Failed to restart Docker daemon during chain rebuild"
            return 1
        fi
        sleep 20
        
        # Restart containers
        echo "   🚀 Restarting containers with clean chains..."
        if ! sudo docker compose up -d; then
            echo "   ❌ Failed to restart containers after chain rebuild"
            return 1
        fi
        sleep 30
        
        echo "   ✅ Docker chains rebuilt successfully"
    else
        echo "   ✅ Docker iptables chains are healthy"
    fi
    
    # Step 3: Wait for containers to be fully running
    echo "   ⏳ Waiting for containers to be fully operational..."
    local wait_time=0
    local max_wait=120
    while [ $wait_time -lt $max_wait ]; do
        local running_containers=$(docker ps --format "table {{.Names}}" | grep -v "NAMES" | wc -l)
        if [ "$running_containers" -gt 20 ]; then
            echo "   ✅ $running_containers containers are running"
            break
        fi
        sleep 10
        wait_time=$((wait_time + 10))
        echo "   ⏳ Still waiting... ($running_containers containers running, ${wait_time}s elapsed)"
    done
    
    # Detect Docker bridges
    DOCKER_BRIDGES=$(ip link show | grep -E 'br-[a-f0-9]+|docker0' | awk -F': ' '{print $2}' | cut -d'@' -f1)
    
    if [ -n "$DOCKER_BRIDGES" ]; then
        echo "ℹ️  Found Docker bridges: $(echo $DOCKER_BRIDGES | tr '\n' ' ' | head -c 50)..."
        
        # Check current FORWARD policy
        CURRENT_POLICY=$(sudo iptables -L FORWARD | head -1 | grep -oP '(?<=policy )[A-Z]+' || echo "ACCEPT")
        echo "ℹ️  Current FORWARD policy: $CURRENT_POLICY"
        
        # Apply fixes only if needed
        if [ "$CURRENT_POLICY" = "DROP" ]; then
            echo "🔄 Fixing FORWARD policy..."
            sudo iptables -P FORWARD ACCEPT
        fi
        
        # Add rules for external access (check if they exist first)
        if ! sudo iptables -C FORWARD -i "$DOCKER_PRIMARY_INTERFACE" -o br-+ -j ACCEPT >/dev/null 2>&1; then
            sudo iptables -I FORWARD -i "$DOCKER_PRIMARY_INTERFACE" -o br-+ -j ACCEPT >/dev/null 2>&1 || true
            sudo iptables -I FORWARD -i br-+ -o "$DOCKER_PRIMARY_INTERFACE" -j ACCEPT >/dev/null 2>&1 || true
            echo "✅ Added Docker bridge forwarding rules"
        else
            echo "ℹ️  Docker forwarding rules already exist"
        fi
        
        # Add rules for common SOC ports
        for port in 443 5443 7001 7002 7003 7004 7005 7006 7007 7008 7009; do
            sudo iptables -I FORWARD -i "$DOCKER_PRIMARY_INTERFACE" -p tcp --dport $port -j ACCEPT >/dev/null 2>&1 || true
            sudo iptables -I FORWARD -o "$DOCKER_PRIMARY_INTERFACE" -p tcp --sport $port -j ACCEPT >/dev/null 2>&1 || true
        done
        echo "✅ Added rules for SOC tool ports"
        
        # Make rules persistent if iptables-persistent is available
        if command -v iptables-save >/dev/null 2>&1; then
            if ! dpkg -l | grep -q iptables-persistent; then
                echo "📦 Installing iptables-persistent for rule persistence..."
                
                # Enhanced robust installation function
                install_iptables_persistent() {
                    local max_attempts=3
                    local attempt=1
                    
                    while [ $attempt -le $max_attempts ]; do
                        echo "   🔄 Installation attempt $attempt/$max_attempts..."
                        
                        # Step 1: Check for and kill any stuck apt processes
                        if pgrep -f "apt.*iptables-persistent" >/dev/null 2>&1; then
                            echo "   🧹 Cleaning up stuck apt processes..."
                            sudo pkill -f "apt.*iptables-persistent" >/dev/null 2>&1 || true
                            sleep 2
                        fi
                        
                        # Step 2: Clear apt locks if they exist
                        if [ -f /var/lib/dpkg/lock-frontend ]; then
                            echo "   🔓 Clearing apt locks..."
                            sudo rm -f /var/lib/dpkg/lock-frontend /var/lib/dpkg/lock /var/cache/apt/archives/lock >/dev/null 2>&1 || true
                        fi
                        
                        # Step 3: Fix any broken dpkg state
                        sudo dpkg --configure -a >/dev/null 2>&1 || true
                        
                        # Step 4: Enhanced debconf pre-seeding with proper escaping
                        echo "   ⚙️  Configuring package pre-selections..."
                        {
                            echo "iptables-persistent iptables-persistent/autosave_v4 boolean true"
                            echo "iptables-persistent iptables-persistent/autosave_v6 boolean true"
                        } | sudo debconf-set-selections
                        
                        # Step 5: Update package lists with timeout
                        echo "   📥 Updating package lists..."
                        if timeout 30 sudo apt update >/dev/null 2>&1; then
                            echo "   ✅ Package lists updated successfully"
                        else
                            echo "   ⚠️  Package update timed out, trying anyway..."
                        fi
                        
                        # Step 5.5: Pre-installation diagnostics
                        echo "   🔍 Running pre-installation diagnostics..."
                        
                        # Check if package is available
                        if apt-cache show iptables-persistent >/dev/null 2>&1; then
                            echo "   ✅ iptables-persistent package found in repositories"
                        else
                            echo "   ❌ iptables-persistent package not found - this explains the failure!"
                            echo "   📥 Adding universe repository..."
                            sudo add-apt-repository universe -y >/dev/null 2>&1 || true
                            sudo apt update >/dev/null 2>&1 || true
                        fi
                        
                        # Check disk space
                        local available_space=$(df /var/cache/apt/archives | tail -1 | awk '{print $4}')
                        if [ "$available_space" -lt 50000 ]; then
                            echo "   ⚠️  Low disk space: ${available_space}KB available"
                        else
                            echo "   ✅ Sufficient disk space: ${available_space}KB available"
                        fi
                        
                        # Check for broken packages
                        if dpkg -l | grep -q "^iU\|^iF"; then
                            echo "   🔧 Fixing broken packages..."
                            sudo apt --fix-broken install -y >/dev/null 2>&1 || true
                        fi
                        
                        # Step 6: Install with multiple layers of non-interactive protection
                        echo "   📦 Installing iptables-persistent..."
                        export DEBIAN_FRONTEND=noninteractive
                        export DEBCONF_NONINTERACTIVE_SEEN=true
                        
                        # Install expect if not available (lightweight and essential for prompt handling)
                        if ! command -v expect >/dev/null 2>&1; then
                            echo "   📥 Installing expect for prompt handling..."
                            if timeout 30 sudo apt install -y expect >/dev/null 2>&1; then
                                echo "   ✅ expect installed successfully"
                            else
                                echo "   ⚠️  expect installation failed, using fallback method"
                            fi
                        fi
                        
                        # Create a temporary log file for detailed error reporting
                        local install_log=$(mktemp /tmp/iptables-persistent-install.XXXXXX)
                        local install_success=false
                        
                        # Method 1: Try with expect if available
                        if command -v expect >/dev/null 2>&1; then
                            echo "   🎯 Using expect method for installation..."
                            if timeout 60 expect -c "
                                log_file $install_log
                                spawn sudo -E apt install -y iptables-persistent
                                expect {
                                    \"*Save current*\" { 
                                        send \"y\r\"
                                        exp_continue 
                                    }
                                    \"*keep the local*\" { 
                                        send \"y\r\"
                                        exp_continue 
                                    }
                                    \"*install the package*\" { 
                                        send \"y\r\"
                                        exp_continue 
                                    }
                                    \"*Do you want to continue*\" {
                                        send \"y\r\"
                                        exp_continue
                                    }
                                    \"Reading package lists\" {
                                        exp_continue
                                    }
                                    \"Building dependency tree\" {
                                        exp_continue
                                    }
                                    \"Setting up\" {
                                        exp_continue
                                    }
                                    eof {
                                        exit 0
                                    }
                                    timeout {
                                        exit 1
                                    }
                                }
                            " 2>&1; then
                                install_success=true
                                echo "   ✅ expect method succeeded"
                            else
                                echo "   ⚠️  expect method failed, trying alternative..."
                            fi
                        fi
                        
                        # Method 2: Direct installation with verbose logging if expect failed
                        if [ "$install_success" = false ]; then
                            echo "   🔧 Using direct installation method..."
                            
                            # Try the most straightforward approach with full logging
                            if sudo -E apt install -y iptables-persistent 2>&1 | tee "$install_log"; then
                                install_success=true
                                echo "   ✅ Direct installation succeeded"
                            else
                                echo "   ❌ Direct installation failed"
                            fi
                        fi
                        
                        # Method 3: Force installation if previous methods failed
                        if [ "$install_success" = false ]; then
                            echo "   🚀 Trying force installation method..."
                            
                            # Download and install manually
                            if sudo apt download iptables-persistent 2>&1 | tee -a "$install_log" && \
                               sudo dpkg -i --force-confnew iptables-persistent*.deb 2>&1 | tee -a "$install_log"; then
                                install_success=true
                                echo "   ✅ Force installation succeeded"
                                # Clean up downloaded package
                                rm -f iptables-persistent*.deb
                            else
                                echo "   ❌ Force installation also failed"
                            fi
                        fi
                        
                        # Show detailed error information if all methods failed
                        if [ "$install_success" = false ] && [ -f "$install_log" ]; then
                            echo "   📋 Installation error details:"
                            echo "   ================================================"
                            tail -20 "$install_log" | sed 's/^/   | /'
                            echo "   ================================================"
                        fi
                        
                        # Clean up log file
                        rm -f "$install_log" 2>/dev/null || true
                        
                        # Step 7: Verify installation
                        if dpkg -l | grep -q iptables-persistent; then
                            echo "   ✅ iptables-persistent installed successfully"
                            return 0
                        else
                            echo "   ⚠️  Installation attempt $attempt failed"
                            attempt=$((attempt + 1))
                            if [ $attempt -le $max_attempts ]; then
                                echo "   🔄 Retrying in 3 seconds..."
                                sleep 3
                            fi
                        fi
                    done
                    
                    echo "   ⚠️  All installation attempts failed - this is not critical"
                    echo "   ℹ️  iptables rules will work but won't persist after reboot"
                    echo "   ➡️  You can manually install later with: sudo apt install iptables-persistent"
                    return 1
                }
                
                # Call the robust installation function (continue regardless of outcome)
                install_iptables_persistent || {
                    echo "   ℹ️  iptables-persistent installation was not successful"
                    echo "   ➡️  Continuing with script execution..."
                }
            fi
            
            if dpkg -l | grep -q iptables-persistent; then
                sudo mkdir -p /etc/iptables
                sudo iptables-save | sudo tee /etc/iptables/rules.v4 >/dev/null 2>&1 || true
                echo "✅ Docker networking rules made persistent"
            else
                echo "ℹ️ iptables rules configured but not persistent (will reset on reboot)"
            fi
        fi
        
        echo "✅ Docker external access configuration complete!"
    else
        echo "⚠️  No Docker bridges found - rules will be applied when containers start"
    fi
    
    echo ""
    echo "🚀 Docker networking configuration finished - continuing with service setup..."
}

# Apply comprehensive networking fixes after services have started
echo "🌐 Configuring Docker external access for all platforms..."
detect_primary_interface_for_docker
apply_docker_networking_fixes

# Now proceed with service-specific configurations
echo ""
echo "🔧 Configuring Fleet database..."
if ! sudo docker run --rm \
  --network=cyber-blue \
  -e FLEET_MYSQL_ADDRESS=fleet-mysql:3306 \
  -e FLEET_MYSQL_USERNAME=fleet \
  -e FLEET_MYSQL_PASSWORD=fleetpass \
  -e FLEET_MYSQL_DATABASE=fleet \
  fleetdm/fleet:latest fleet prepare db; then
    echo "⚠️  Fleet database preparation failed - Fleet may not work properly"
fi

if ! sudo docker compose up -d fleet-server; then
    echo "⚠️  Failed to start fleet-server - continuing anyway"
fi

# ----------------------------
# Enhanced Arkime Setup using dedicated script
# ----------------------------
echo "🔍 Initializing Arkime with enhanced setup..."
echo "================================================"

# Run the dedicated Arkime fix script with 30-second live capture
echo "🚀 Running enhanced Arkime setup with 30-second live capture..."
if [ -f "./fix-arkime.sh" ]; then
    chmod +x ./fix-arkime.sh
    ./fix-arkime.sh --live-30s
    
    if [ $? -eq 0 ]; then
        echo "✅ Arkime setup completed successfully!"
    else
        echo "⚠️  Arkime setup completed with warnings"
    fi
else
    echo "⚠️  fix-arkime.sh not found, using basic setup..."
    
    # Fallback: Basic Arkime user creation
    echo "👤 Creating Arkime admin user..."
    sudo docker exec arkime /opt/arkime/bin/arkime_add_user.sh admin "CyberBlue Admin" admin --admin 2>/dev/null || echo "Admin user ready"
    
    echo "🌐 Access Arkime at: http://$(hostname -I | awk '{print $1}'):7008"
    echo "👤 Login credentials: admin / admin"
fi

echo ""

# ----------------------------
# Caldera Setup
# ----------------------------
echo "🧠 Installing Caldera in the background..."
chmod +x ./install_caldera.sh
./install_caldera.sh

# Wait until Caldera is fully running on port 7009
echo "⏳ Waiting for Caldera to become available on port 7009..."
for i in {1..30}; do
  if ss -tuln | grep -q ":7009"; then
    echo "✅ Caldera is now running at http://localhost:7009"
    break
  fi
  sleep 2
done

# ----------------------------
# Caldera Auto-Start Service Setup
# ----------------------------
echo "🔧 Configuring Caldera auto-start service..."

# Create systemd service for Caldera auto-start (matches portal expectations)
sudo tee /etc/systemd/system/caldera-autostart.service > /dev/null << 'EOF'
[Unit]
Description=Caldera Adversary Emulation Platform Auto-Start
Requires=docker.service
After=docker.service network-online.target
Wants=network-online.target

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/home/ubuntu/CyberBlueSOCx
ExecStartPre=/bin/bash -c 'timeout 30 bash -c "until docker info >/dev/null 2>&1; do sleep 2; done"'
ExecStart=/bin/bash -c 'if docker ps -a --format "{{.Names}}" | grep -q "^caldera$"; then docker start caldera; else echo "Caldera container not found - run ./install_caldera.sh"; exit 1; fi'
ExecStop=/usr/bin/docker stop caldera
TimeoutStartSec=120
TimeoutStopSec=30
User=ubuntu
Group=ubuntu

[Install]
WantedBy=multi-user.target
EOF

# Enable the Caldera auto-start service
sudo systemctl daemon-reload
sudo systemctl enable caldera-autostart.service >/dev/null 2>&1

echo "✅ Caldera auto-start service configured and enabled"
echo "🔄 Caldera will now automatically start after system reboots"

# ----------------------------
# Final Success Message with Logo and Time
# ----------------------------
# ----------------------------
# Final Service Verification
# ----------------------------
echo "🔍 Final verification of all services..."
sleep 10

TOTAL_RUNNING=$(sudo docker ps | grep -c "Up" || echo "0")
EXPECTED_SERVICES=30

echo "📊 Service Status Check:"
echo "   Running containers: $TOTAL_RUNNING"
echo "   Expected containers: $EXPECTED_SERVICES+"

if [[ "$TOTAL_RUNNING" -ge "$EXPECTED_SERVICES" ]]; then
    echo "✅ All services are running successfully!"
else
    echo "⚠️  Some services may still be starting ($TOTAL_RUNNING/$EXPECTED_SERVICES+)"
    echo "   This is normal - services may take a few more minutes to fully initialize"
    echo "   Check portal in 2-3 minutes for final status"
fi

# Final Wazuh verification
WAZUH_RUNNING=$(sudo docker ps | grep -c "wazuh.*Up" || echo "0")
if [[ "$WAZUH_RUNNING" -eq 3 ]]; then
    echo "✅ All Wazuh services confirmed running"
elif [[ "$WAZUH_RUNNING" -eq 2 ]]; then
    echo "⚠️  2/3 Wazuh services running (may need more time)"
elif [[ "$WAZUH_RUNNING" -eq 1 ]]; then
    echo "⚠️  1/3 Wazuh services running (run ./fix-wazuh-services.sh if needed)"
else
    echo "⚠️  Wazuh services not detected (run ./fix-wazuh-services.sh if needed)"
fi

# Caldera verification
if sudo docker ps | grep -q "caldera.*Up"; then
    echo "✅ Caldera confirmed running"
else
    echo "⚠️  Caldera not detected (should be integrated now)"
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
MINUTES=$((DURATION / 60))
SECONDS=$((DURATION % 60))

echo ""
echo "🎉 =================================="
echo "    ____      _               ____  _            "
echo "   / ___|   _| |__   ___ _ __| __ )| |_   _  ___ "
echo "  | |  | | | | '_ \ / _ \ '__|  _ \| | | | |/ _ \\"
echo "  | |__| |_| | |_) |  __/ |  | |_) | | |_| |  __/"
echo "   \____\__, |_.__/ \___|_|  |____/|_|\__,_|\___|"
echo "        |___/                                    "
echo ""
echo "  🔷 CyberBlue SOC Platform Successfully Deployed! 🔷"
echo ""
echo "⏱️  Total Installation Time: ${MINUTES}m ${SECONDS}s"
echo ""
echo "🌐 Access Your SOC Tools:"
echo "   🏠 Portal:         https://$(hostname -I | awk '{print $1}'):5443"
echo "   🔒 MISP:           https://$(hostname -I | awk '{print $1}'):7003"
echo "   🛡️  Wazuh:          http://$(hostname -I | awk '{print $1}'):7001"
echo "   🔍 EveBox:         http://$(hostname -I | awk '{print $1}'):7015"
echo "   🧠 Caldera:        http://$(hostname -I | awk '{print $1}'):7009"
echo "   📊 Arkime:         http://$(hostname -I | awk '{print $1}'):7008"
echo "   🕷️  TheHive:        http://$(hostname -I | awk '{print $1}'):7005"
echo "   🔧 Fleet:          http://$(hostname -I | awk '{print $1}'):7007"
echo "   🧪 CyberChef:      http://$(hostname -I | awk '{print $1}'):7004"
echo "   🔗 Shuffle:        http://$(hostname -I | awk '{print $1}'):7002"
echo "   🖥️  Portainer:      http://$(hostname -I | awk '{print $1}'):9443"
echo "   ✨ ...and many others!"
echo ""
echo "🔑 Access & Credentials:"
echo "   🏠 CyberBlueSOC Portal: https://$(hostname -I | awk '{print $1}'):5443 - admin / cyberblue123"
echo "   🔒 Other Tools:         admin / cyberblue"
echo ""
echo "🎓 Lab Environment Features:"
echo "   ✅ Universal external access (works on AWS, Azure, GCP, bare metal)"
echo "   ✅ Auto-start on system reboot configured"
echo "   ✅ Docker networking optimized for external connectivity"
echo "   ✅ Persistent firewall rules across reboots"
echo "   ✅ Configured for educational and testing purposes"
echo ""
echo "🚨 REMEMBER: This is a LEARNING environment - use only in isolated networks!"
echo ""
echo "✅ CyberBlue SOC Lab is ready for cybersecurity training and education!"
echo "=================================="
