# 🛡️ CyberBlueSOC Platform

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-20.10+-blue.svg)](https://www.docker.com/)
[![Docker Compose](https://img.shields.io/badge/Docker%20Compose-2.0+-blue.svg)](https://docs.docker.com/compose/)

# ⚠️ **EDUCATIONAL & TESTING ENVIRONMENT ONLY** ⚠️

> **🎓 Learning & Training Platform** - Deploy 15+ integrated security tools for cybersecurity education and testing

**CyberBlue** is a comprehensive, containerized cybersecurity **LEARNING PLATFORM** that brings together industry-leading open-source tools for **SIEM**, **DFIR**, **CTI**, **SOAR**, and **Network Analysis**. 

## 🚨 **IMPORTANT SECURITY NOTICE**

**⚠️ THIS IS A LEARNING/TESTING ENVIRONMENT ONLY ⚠️**

- **🔴 NOT FOR PRODUCTION USE** - Contains default credentials and test configurations
- **🔴 USE IN ISOLATED NETWORKS ONLY** - Never deploy on production networks
- **🔴 EDUCATIONAL PURPOSE** - Designed for cybersecurity training and research
- **🔴 NO SECURITY GUARANTEES** - Not hardened for production environments

**✅ SAFE FOR:**
- Cybersecurity training and education
- Security tool evaluation and testing
- Isolated lab environments
- Academic research and learning
- Proof-of-concept demonstrations

**❌ NEVER USE FOR:**
- Production security monitoring
- Real-world threat detection
- Processing sensitive data
- Corporate security infrastructure

---

## 🎯 Overview

CyberBlue transforms Blue Teams cybersecurity tool deployment into a **one-command solution**. Built with Docker Compose and featuring a beautiful web portal, it provides enterprise-grade security capabilities in minutes, not days.

### 🌟 Why CyberBlue?

- **🚀 Instant Deployment**: Full security lab in under 30 minutes
- **🔒 Enterprise Security**: HTTPS authentication with SSL encryption
- **🎨 Modern Interface**: Beautiful portal with secure login system
- **🎓 Lab Ready**: Pre-configured containers with sample data for learning
- **🤖 Smart Configuration**: Dynamic network interface detection
- **📊 Data Integration**: Arkime with sample traffic, Suricata with 50K+ events
- **💾 Backup System**: Complete state preservation and restoration
- **📚 Documentation**: Comprehensive guides and troubleshooting
- **🌐 Community Driven**: Open source with active development!

---

## ✨ **Latest Enhancements**

### 🔒 **Security & Authentication**
- **HTTPS Portal**: Secure SSL/TLS encrypted access on port 5443
- **Authentication System**: Login required with secure session management
- **Password Security**: bcrypt hashing with CSRF protection
- **API Security**: JWT token support for automated integrations

### 🔍 **Data Integration**
- **Arkime Enhanced**: Live traffic capture with real-time monitoring and flexible durations
- **Suricata Active**: Dynamic interface detection with 50K+ security events
- **EveBox Connected**: Real-time Suricata event visualization
- **Live Data**: Immediate analysis capabilities upon deployment

### 🤖 **Smart Configuration**
- **Dynamic Interface Detection**: Auto-detects network interfaces (ens5, eth0, etc.)
- **Environment Adaptation**: Works on AWS, VMware, bare metal automatically
- **Network Optimization**: Proper Docker networking for all tools
- **Resource Management**: Optimized container resource allocation

### 💾 **Backup & Recovery**
- **Complete State Backup**: 8.5GB comprehensive backup system
- **One-Click Restore**: Automated restoration to exact working state
- **Configuration Preservation**: All customizations and data saved
- **Disaster Recovery**: Production-grade backup procedures

---

## 🛡️ Security Tools Included

### 📊 **SIEM & Monitoring**
- **[Wazuh](https://wazuh.com/)** - Host-based intrusion detection and log analysis
- **[Suricata](https://suricata.io/)** - Network intrusion detection and prevention
- **[EveBox](https://evebox.org/)** - Suricata event and alert management

### 🕵️ **DFIR & Forensics**
- **[Velociraptor](https://docs.velociraptor.app/)** - Endpoint visibility and digital forensics
- **[Arkime](https://arkime.com/)** - Full packet capture and network analysis
- **[Wireshark](https://www.wireshark.org/)** - Network protocol analyzer

### 🧠 **Threat Intelligence**
- **[MISP](https://www.misp-project.org/)** - Threat intelligence platform
- **[MITRE ATT&CK Navigator](https://mitre-attack.github.io/attack-navigator/)** - Threat modeling and visualization

### ⚡ **SOAR & Automation**
- **[Shuffle](https://shuffler.io/)** - Security orchestration and automation
- **[TheHive](https://thehive-project.org/)** - Incident response platform
- **[Cortex](https://github.com/TheHive-Project/Cortex)** - Observable analysis engine

### 🔧 **Utilities & Management**
- **[CyberChef](https://gchq.github.io/CyberChef/)** - Cyber Swiss Army knife
- **[Portainer](https://www.portainer.io/)** - Container management interface
- **[FleetDM](https://fleetdm.com/)** - Device management and osquery fleet manager
- **[Caldera](https://caldera.mitre.org/)** - Adversary emulation platform

---

## 🚀 Quick Start

### 📋 Prerequisites & System Setup

**System Requirements:**
- **RAM**: 16+ GB recommended (8GB minimum)
- **Storage**: 100GB+ free disk space
- **OS**: Ubuntu 22.04+ LTS (tested on 22.04.5 & 24.04.2)
- **Network**: Internet connection for downloads

**Complete Prerequisites Setup (Copy & Paste):**
```bash
# ===== COMPLETE CYBERBLUE SOC PREREQUISITES SETUP =====
# Run this entire block on any Ubuntu system (AWS, VMware, VirtualBox, bare metal)

# 1. System Update and Basic Packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y ca-certificates curl gnupg lsb-release git

# 2. Docker Installation (Latest)
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# 3. Docker Compose (Latest - Important for VMware/VirtualBox)
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 4. User Permissions and Docker Setup
sudo usermod -aG docker $USER
sudo chown root:docker /var/run/docker.sock
sudo chmod 660 /var/run/docker.sock
sudo systemctl enable docker && sudo systemctl start docker

# 5. System Optimizations for Containers
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
echo '* soft nofile 65536' | sudo tee -a /etc/security/limits.conf
echo '* hard nofile 65536' | sudo tee -a /etc/security/limits.conf

# 6. Environment Variables (Prevents VMware/VirtualBox warnings)
export DOCKER_BUILDKIT=1
export COMPOSE_DOCKER_CLI_BUILD=1
echo 'export DOCKER_BUILDKIT=1' >> ~/.bashrc
echo 'export COMPOSE_DOCKER_CLI_BUILD=1' >> ~/.bashrc

# 7. Docker Networking Configuration (Prevents common networking errors)
echo "🔧 Configuring Docker networking to prevent installation errors..."

# Configure Docker daemon for better networking
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'DAEMON_EOF'
{
  "iptables": true,
  "userland-proxy": false,
  "live-restore": true,
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
DAEMON_EOF

# Reset iptables to prevent conflicts (common cause of networking errors)
sudo iptables -t nat -F 2>/dev/null || true
sudo iptables -t mangle -F 2>/dev/null || true
sudo iptables -F 2>/dev/null || true
sudo iptables -X 2>/dev/null || true

# Restart Docker with new configuration
sudo systemctl restart docker
sleep 5

# Clean any existing Docker networks that might conflict
sudo docker network prune -f 2>/dev/null || true

# 8. Port Conflict Prevention
echo "🔍 Checking for potential port conflicts..."
REQUIRED_PORTS="5443 7000 7001 7002 7003 7004 7005 7006 7007 7008 7009 7010 7011 7012 7013 7014 7015 9200 9443 1514 1515 55000"
CONFLICTS=()

for port in $REQUIRED_PORTS; do
    if sudo netstat -tulpn 2>/dev/null | grep -q ":$port "; then
        CONFLICTS+=($port)
    fi
done

if [ ${#CONFLICTS[@]} -gt 0 ]; then
    echo "⚠️ WARNING: The following ports are already in use: ${CONFLICTS[*]}"
    echo "   These may cause conflicts during CyberBlue deployment"
    echo "   Consider stopping services using these ports or rebooting if needed"
else
    echo "✅ All required ports are available"
fi

# 9. Apply Docker group and test access
newgrp docker << 'EOF'
# Test Docker access within new group context
docker --version >/dev/null 2>&1 && echo "✅ Docker access confirmed" || echo "⚠️ Docker access issue - logout/login may be required"
EOF

# 10. Verify Installation
echo "🔍 Verifying installation..."
docker --version || echo "⚠️ Docker version check failed"
docker compose version || echo "⚠️ Docker Compose version check failed"

# 11. Final Docker access and networking test
if docker ps >/dev/null 2>&1; then
    echo "✅ Docker daemon access confirmed - no logout required!"
    # Test Docker networking capability
    if docker network ls >/dev/null 2>&1; then
        echo "✅ Docker networking confirmed - ready for CyberBlue deployment!"
    else
        echo "⚠️ Docker networking issue detected - may need system reboot"
    fi
elif sudo docker ps >/dev/null 2>&1; then
    echo "⚠️ Docker requires sudo - logout/login recommended for group permissions"
else
    echo "❌ Docker daemon not accessible - check installation"
fi

echo "✅ Prerequisites setup complete!"
echo "🚀 Ready to clone and deploy CyberBlue SOC"
```

**💡 Note**: The `newgrp docker` command usually eliminates the need to logout/login. If Docker commands still require `sudo`, then logout/login is needed.

### ⚡ Simple Installation (Choose One)

**Two simple methods that work everywhere:**

#### 🎯 **Method 1: Complete Installer (Recommended)**
```bash
# Clone and install everything in one go
git clone https://github.com/CyberBlue0/CyberBlue.git
cd CyberBlue
chmod +x install-cyberblue-final.sh
./install-cyberblue-final.sh
```
**✅ Handles everything: Prerequisites, Docker, all services**
**✅ No hanging, no logout required, bulletproof**

#### 🔧 **Method 2: Manual Prerequisites (Advanced Users)**
```bash
# Clone the repository
git clone https://github.com/CyberBlue0/CyberBlue.git
cd CyberBlue

# Step 1: Install prerequisites manually (copy the prerequisites block above)
# Step 2: Run CyberBlue initialization
chmod +x cyberblue_init.sh
./cyberblue_init.sh
```
**✅ Manual control, use prerequisites block above**

**💡 Both methods work on all platforms (AWS, VMware, VirtualBox, bare metal) and deliver 15/15 services.**

### 🔍 **Enhanced Arkime Operations**

```bash
# Live network capture with real-time monitoring
./fix-arkime.sh --live                    # 1-minute capture (default)
./fix-arkime.sh --live-30s                # 30-second quick test
./fix-arkime.sh --live-5min               # 5-minute investigation

# Dedicated PCAP generation
./generate-pcap-for-arkime.sh             # Generate and process PCAP
./generate-pcap-for-arkime.sh --keep-files # Preserve PCAP files
./generate-pcap-for-arkime.sh --background -d 10min # Background capture
```

The script will automatically:
- ✅ Check system requirements and dependencies
- ✅ Configure environment variables and network settings
- ✅ Deploy all 15+ security tools with Docker Compose
- ✅ Initialize Arkime with enhanced 30-second live traffic capture
- ✅ Set up Suricata with dynamic interface detection
- ✅ Configure Caldera adversary emulation platform
- ✅ Start the secure HTTPS portal with authentication
- ✅ Generate SSL certificates and security credentials
- ✅ Create comprehensive backup for disaster recovery
- ✅ Display access URLs and login credentials

### 🌐 Access Your Security Lab

After deployment, access the **CyberBlue Portal** at:
```
🔒 HTTPS (Recommended): https://YOUR_SERVER_IP:5443
🔑 Login: admin / cyberblue123
```

Individual tools are available on ports **7000-7099**:
- **Velociraptor**: https://YOUR_SERVER_IP:7000 (admin/cyberblue)
- **Wazuh**: https://YOUR_SERVER_IP:7001 (admin/SecretPassword)
- **Shuffle**: https://YOUR_SERVER_IP:7002 (admin/password)
- **MISP**: https://YOUR_SERVER_IP:7003 (admin@admin.test/admin)
- **CyberChef**: http://YOUR_SERVER_IP:7004 (no auth)
- **TheHive**: http://YOUR_SERVER_IP:7005 (admin@thehive.local/secret)
- **Cortex**: http://YOUR_SERVER_IP:7006 (admin/cyberblue123)
- **FleetDM**: http://YOUR_SERVER_IP:7007 (setup required)
- **Arkime**: http://YOUR_SERVER_IP:7008 (admin/admin)
- **Caldera**: http://YOUR_SERVER_IP:7009 (red:cyberblue, blue:cyberblue)
- **EveBox**: http://YOUR_SERVER_IP:7015 (no auth)
- **Wireshark**: http://YOUR_SERVER_IP:7011 (admin/cyberblue)
- **MITRE Navigator**: http://YOUR_SERVER_IP:7013 (no auth)
- **OpenVAS**: http://YOUR_SERVER_IP:7014 (admin/cyberblue)
- **Portainer**: https://YOUR_SERVER_IP:9443 (admin/cyberblue123)

---

## 📖 Documentation

### 🚀 Quick Start
- **[Installation Guide](INSTALL.md)** - Detailed setup instructions
- **[Security Guide](SECURITY.md)** - Hardening and best practices

### 📚 Comprehensive Documentation
- **[📚 Documentation Hub](docs/README.md)** - Complete documentation index
- **[⚡ Quick Reference](QUICK_REFERENCE.md)** - Essential commands and access information
- **[📜 Scripts Documentation](SCRIPTS_DOCUMENTATION.md)** - Complete guide to all available scripts
- **[🔍 Arkime Setup](ARKIME_SETUP.md)** - Network analysis with sample data
- **[📊 System Verification](SYSTEM_VERIFICATION_REPORT.md)** - Current system status
- **[📖 User Guide](docs/USER_GUIDE.md)** - How to use all CyberBlue tools
- **[⚙️ Tool Configurations](docs/TOOL_CONFIGURATIONS.md)** - Advanced tool setup and customization
- **[🔌 API Reference](docs/API_REFERENCE.md)** - Portal API documentation
- **[🚀 Deployment Scenarios](docs/DEPLOYMENT_SCENARIOS.md)** - Development, staging, and production guides
- **[🔧 Maintenance Guide](docs/MAINTENANCE_GUIDE.md)** - Operational procedures and schedules
- **[💾 Backup & Recovery](docs/BACKUP_RECOVERY.md)** - Disaster recovery procedures
- **[🔧 Troubleshooting](docs/TROUBLESHOOTING.md)** - Common issues and solutions

---

## ⚙️ Configuration

### Environment Variables

Copy `.env.template` to `.env` and customize:

```bash
# Network Configuration
HOST_IP=10.0.0.40                    # Your server IP
NETWORK_SUBNET=172.18.0.0/16         # Docker network subnet

# Security Configuration
WAZUH_ADMIN_PASSWORD=SecurePass123!   # Wazuh admin password
OPENSEARCH_ADMIN_PASSWORD=SecurePass123!  # OpenSearch admin password
MISP_ADMIN_EMAIL=admin@cyberblue.local     # MISP admin email

# Portal Configuration
PORTAL_PORT=5500                      # CyberBlue portal port
```

### Advanced Configuration

For production deployments, see our [Advanced Configuration Guide](docs/ADVANCED.md).

---

## 🎨 CyberBlue Portal Features

The CyberBlue Portal provides a secure, unified interface for managing your security lab:

### 🔒 **Security Features**
- **HTTPS Encryption**: All portal traffic encrypted with SSL/TLS
- **Authentication System**: Secure login with bcrypt password hashing
- **Session Management**: Secure sessions with CSRF protection
- **JWT API Tokens**: Programmatic access with bearer tokens
- **Activity Logging**: Complete audit trail of all user actions

### 📊 **Enhanced Dashboard**
- Real-time container status monitoring (30+ containers)
- System resource utilization tracking
- Security metrics and trends visualization
- Activity logging and comprehensive changelog
- Container health indicators with status alerts

### 🔧 **Container Management**
- One-click start/stop/restart controls for all services
- Health status indicators with real-time updates
- Resource usage monitoring and alerts
- Log viewing capabilities for troubleshooting
- Automated container monitoring and recovery

### 🛡️ **Security Overview**
- Tool categorization (SIEM, DFIR, CTI, SOAR, Utilities)
- Quick access to all 15+ security tools
- Integration status monitoring across platforms
- Security posture dashboard with threat metrics
- Automated service health checking

### 🔍 **Search & Filter**
- Global tool search functionality
- Category-based filtering (SIEM, DFIR, CTI, etc.)
- Status-based filtering (Running, Stopped, Critical)
- Organized tool layout with descriptions and credentials

---

## 🐳 Architecture

CyberBlue uses a microservices architecture with Docker Compose:

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   CyberBlue     │    │   SIEM Stack    │    │   DFIR Stack    │
│     Portal      │    │                 │    │                 │
│   (Flask App)   │    │ • Wazuh         │    │ • Velociraptor  │
│                 │    │ • Suricata      │    │ • Arkime        │
│                 │    │ • EveBox        │    │ • Wireshark     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
         ┌─────────────────┐    ┌┴─────────────────┐    ┌─────────────────┐
         │   CTI Stack     │    │ Docker Network   │    │  SOAR Stack     │
         │                 │    │  (172.18.0.0/16) │    │                 │
         │ • MISP          │    │                  │    │ • Shuffle       │
         │ • MITRE ATT&CK  │    │                  │    │ • TheHive       │
         │                 │    │                  │    │ • Cortex        │
         └─────────────────┘    └──────────────────┘    └─────────────────┘
```

---


## 📋 System Requirements

### Recommended Requirements
- **CPU**: 8+ cores
- **RAM**: 16GB+
- **Storage**: 100GB+ SSD
- **Network**: Gigabit Ethernet

---

## 🔧 Troubleshooting

### Common Issues

**Portal not accessible:**
```bash
# Check portal status (HTTPS on port 5443)
sudo docker ps | grep cyber-blue-portal

# View portal logs
sudo docker logs cyber-blue-portal

# Test HTTPS access
curl -k https://localhost:5443/login

# Restart portal with authentication
sudo docker-compose restart portal
```

**Authentication issues:**
```bash
# Default credentials: admin / cyberblue123
# Reset authentication system
sudo docker-compose stop portal
sudo docker-compose build --no-cache portal
sudo docker-compose up -d portal
```

**Arkime shows no data:**
```bash
# Reinitialize Arkime with sample data
./scripts/initialize-arkime.sh --capture-live

# Check PCAP files
ls -la ./arkime/pcaps/

# Verify database connection
curl http://localhost:9200/_cluster/health
```

**Suricata/EveBox issues:**
```bash
# Update network interface dynamically
./update-network-interface.sh --restart-suricata

# Check Suricata events
tail -f ./suricata/logs/eve.json

# Verify EveBox connection
curl http://localhost:7015
```

**Tools not starting:**
```bash
# Check all containers (should show 30+ running)
sudo docker ps

# Restart specific service
sudo docker-compose restart [service-name]

# Check service logs
sudo docker logs [container-name]
```

**Resource issues:**
```bash
# Check system resources
sudo docker stats

# Free up space (careful!)
sudo docker system prune -a

# Check disk usage
df -h
```

**Network interface issues:**
```bash
# Update interface detection
./update-network-interface.sh

# Check current interface
ip route | grep default

# Manual interface setting
echo "SURICATA_INT=your_interface" >> .env
```

For comprehensive troubleshooting, see our [Troubleshooting Guide](docs/TROUBLESHOOTING.md) and [Arkime Setup Guide](ARKIME_SETUP.md).

---

## 📊 Monitoring & Metrics

CyberBlue includes built-in monitoring:

- **Container Health**: Real-time status monitoring
- **Resource Usage**: CPU, memory, disk utilization

---

## 🔒 Security Considerations

- **Network Isolation**: All tools run in isolated Docker networks
- **Access Control**: Configure authentication for LAB use
- **SSL/TLS**: Enable HTTPS for some web interfaces
- 

See our [Security Guide](SECURITY.md) for detailed hardening instructions. 

---

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- **MITRE Corporation** for the ATT&CK framework
- **Elastic** for the ELK stack foundation
- **The Hive Project** for incident response tools
- **All open-source contributors** who make this possible


---

<div align="center">

**⭐ Star this repository if you find it useful for you!**

</div>
