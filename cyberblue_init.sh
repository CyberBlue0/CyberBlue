#!/bin/bash

set -e  # Exit on error

# Record start time
START_TIME=$(date +%s)

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

# ----------------------------
# Cleanup: Remove existing directories if they exist
# ----------------------------
echo "🧹 Cleaning up any existing build directories..."
if [ -d "attack-navigator" ]; then
    echo "   Removing existing attack-navigator/ directory..."
    rm -rf attack-navigator/
fi
if [ -d "wireshark" ]; then
    echo "   Removing existing wireshark/ directory..."
    rm -rf wireshark/
fi

# Clone MITRE ATTACK Nav.
echo "📥 Cloning MITRE ATT&CK Navigator..."
git clone https://github.com/mitre-attack/attack-navigator.git

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

# Show result
echo "✅ .env updated with:"
grep "^MISP_BASE_URL=" .env

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
    sudo curl -s -O https://rules.emergingthreats.net/open/suricata-6.0/emerging.rules.tar.gz
    sudo tar -xzf emerging.rules.tar.gz -C ./suricata/rules --strip-components=1
    sudo rm emerging.rules.tar.gz
else
    echo "ℹ️ Suricata rules archive already downloaded. Skipping."
fi

# Download config files
sudo curl -s -o ./suricata/classification.config https://raw.githubusercontent.com/OISF/suricata/master/etc/classification.config
sudo curl -s -o ./suricata/reference.config https://raw.githubusercontent.com/OISF/suricata/master/etc/reference.config

# ----------------------------
# Launching Services
# ----------------------------
echo "🚀 Running Docker initialization commands..."
sudo docker-compose run --rm generator
sudo docker-compose up --build -d

# ----------------------------
# Docker External Access Fix (Universal)
# ----------------------------
echo "🌐 Configuring Docker external access for all platforms..."

# Function to detect primary network interface (reuse existing logic)
detect_primary_interface_for_docker() {
    # Use the same interface detection logic as Suricata
    DOCKER_PRIMARY_INTERFACE="$SURICATA_IFACE"
    echo "✅ Using detected interface for Docker networking: $DOCKER_PRIMARY_INTERFACE"
}

# Function to apply Docker networking fixes
apply_docker_networking_fixes() {
    echo "🔧 Applying Docker external access fixes..."
    
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
                sudo apt update >/dev/null 2>&1
                DEBIAN_FRONTEND=noninteractive sudo apt install -y iptables-persistent >/dev/null 2>&1 || true
            fi
            
            if dpkg -l | grep -q iptables-persistent; then
                sudo mkdir -p /etc/iptables
                sudo iptables-save | sudo tee /etc/iptables/rules.v4 >/dev/null 2>&1 || true
                echo "✅ Docker networking rules made persistent"
            fi
        fi
        
        echo "✅ Docker external access configuration complete!"
    else
        echo "⚠️  No Docker bridges found - rules will be applied when containers start"
    fi
}

# Apply the fixes
detect_primary_interface_for_docker
apply_docker_networking_fixes

sudo docker run --rm \
  --network=cyber-blue \
  -e FLEET_MYSQL_ADDRESS=fleet-mysql:3306 \
  -e FLEET_MYSQL_USERNAME=fleet \
  -e FLEET_MYSQL_PASSWORD=fleetpass \
  -e FLEET_MYSQL_DATABASE=fleet \
  fleetdm/fleet:latest fleet prepare db
sudo docker-compose up -d fleet-server

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