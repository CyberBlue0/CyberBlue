# 📜 CyberBlue SOC - Scripts Documentation

This document provides comprehensive documentation for all available scripts in the CyberBlue SOC platform.

## 🗂️ Table of Contents

- [🚀 Main Installation & Management Scripts](#-main-installation--management-scripts)
- [🔧 System Maintenance Scripts](#-system-maintenance-scripts)
- [🌐 Network & Interface Scripts](#-network--interface-scripts)
- [📊 Arkime & Analysis Scripts](#-arkime--analysis-scripts)
- [💾 Backup & Recovery Scripts](#-backup--recovery-scripts)
- [🐳 Docker & Platform Scripts](#-docker--platform-scripts)
- [🔍 Helper & Utility Scripts](#-helper--utility-scripts)

---

## 🚀 Main Installation & Management Scripts

### `cyberblue_init.sh` ⭐
**Primary installation script for CyberBlue SOC platform**

```bash
./cyberblue_init.sh
```

**Purpose:** Complete initialization and deployment of all CyberBlue SOC tools
**Features:**
- ✅ Deploys 15+ security tools (MISP, Wazuh, Arkime, etc.)
- ✅ Configures Docker networking and external access
- ✅ Sets up SSL certificates and authentication
- ✅ Initializes Arkime with sample data
- ✅ Configures auto-start services
- ✅ Creates system backups

**Prerequisites:** Docker and Docker Compose installed
**Runtime:** ~15-20 minutes
**Output:** Complete SOC lab ready for use

---

### `cleanup-fresh-install.sh` 🧹
**Complete cleanup script for fresh installation**

```bash
./cleanup-fresh-install.sh [OPTIONS]
```

**Options:**
- `--keep-docker` - Keep Docker installed (only remove containers/images)
- `--keep-data` - Keep persistent data volumes
- `--force` - Skip confirmation prompts
- `--help` - Show help message

**Purpose:** Completely removes CyberBlue components for fresh start
**Features:**
- 🗑️ Removes all containers, images, volumes
- 🌐 Cleans Docker networks and build cache
- 🔥 Resets iptables rules
- 📁 Cleans generated directories
- 🚫 Removes systemd services
- 🐳 Optionally uninstalls Docker completely

**Examples:**
```bash
./cleanup-fresh-install.sh                    # Complete cleanup with confirmation
./cleanup-fresh-install.sh --force            # Complete cleanup without confirmation
./cleanup-fresh-install.sh --keep-docker      # Keep Docker, remove everything else
```

---

### `quick-start.sh`
**Simplified quick start script**

```bash
./quick-start.sh
```

**Purpose:** Rapid deployment with minimal configuration
**Features:**
- ⚡ Fast deployment (fewer checks)
- 🎯 Essential services only
- 📋 Basic configuration

---

## 🔧 System Maintenance Scripts

### `verify-post-reboot.sh`
**System verification after reboot**

```bash
./verify-post-reboot.sh
```

**Purpose:** Verifies all services are running correctly after system restart
**Features:**
- ✅ Checks Docker daemon status
- 📊 Verifies container health
- 🌐 Tests network connectivity
- 📋 Generates status report

---

### `update-network-interface.sh`
**Network interface detection and update**

```bash
./update-network-interface.sh [--restart-suricata]
```

**Purpose:** Updates network interface configuration for Suricata
**Features:**
- 🔍 Auto-detects primary network interface
- 🔄 Updates Suricata configuration
- 🔧 Optionally restarts Suricata service

---

## 🌐 Network & Interface Scripts

### `fix-docker-external-access.sh`
**Docker external access configuration**

```bash
./fix-docker-external-access.sh
```

**Purpose:** Fixes Docker networking for external access
**Features:**
- 🔧 Configures iptables rules
- 🌐 Enables external connectivity
- 🔒 Makes rules persistent

---

### `fix-vmware-compatibility.sh`
**VMware/VirtualBox compatibility fixes**

```bash
./fix-vmware-compatibility.sh
```

**Purpose:** Applies compatibility fixes for virtualized environments
**Features:**
- 🖥️ VMware/VirtualBox optimizations
- 🌐 Network adapter fixes
- ⚙️ Performance tuning

---

### `scripts/detect-interface.sh`
**Network interface detection utility**

```bash
./scripts/detect-interface.sh
```

**Purpose:** Detects and returns primary network interface
**Output:** Interface name (e.g., eth0, ens5)

---

## 📊 Arkime & Analysis Scripts

### `fix-arkime.sh` ⭐
**Enhanced Arkime setup and management**

```bash
./fix-arkime.sh [OPTIONS]
```

**Options:**
- `--live` - 1-minute live capture (default)
- `--live-30s` - 30-second quick test
- `--live-5min` - 5-minute investigation
- `--force` - Force database reinitialization
- `--help` - Show help message

**Purpose:** Initializes and manages Arkime with live traffic capture
**Features:**
- 🔍 Live network traffic capture
- 📊 Real-time processing
- 🗄️ Database initialization
- 📈 Progress monitoring

**Examples:**
```bash
./fix-arkime.sh --live                    # 1-minute capture
./fix-arkime.sh --live-30s                # Quick 30-second test
./fix-arkime.sh --live-5min               # Extended 5-minute capture
```

---

### `generate-pcap-for-arkime.sh`
**PCAP generation and processing**

```bash
./generate-pcap-for-arkime.sh [OPTIONS]
```

**Options:**
- `--keep-files` - Preserve PCAP files after processing
- `--background` - Run capture in background
- `-d DURATION` - Capture duration (e.g., 10min, 30s)

**Purpose:** Generates and processes PCAP files for Arkime
**Features:**
- 📦 Network traffic capture
- 🔄 Automatic processing
- 🧹 Optional cleanup

---

### `scripts/initialize-arkime.sh`
**Arkime initialization helper**

```bash
./scripts/initialize-arkime.sh [--capture-live]
```

**Purpose:** Core Arkime initialization logic
**Features:**
- 🗄️ Database setup
- ⚙️ Configuration validation
- 📊 Sample data loading

---

## 💾 Backup & Recovery Scripts

### `create-backup.sh`
**System backup creation**

```bash
./create-backup.sh
```

**Purpose:** Creates comprehensive backup of CyberBlue system
**Features:**
- 💾 Complete state backup (~8.5GB)
- 📁 Configuration preservation
- 🗄️ Data volume backup
- 🔒 Compressed archive creation

---

### `restore-from-backup.sh`
**System restoration from backup**

```bash
./restore-from-backup.sh [backup-file.tar.gz]
```

**Purpose:** Restores CyberBlue system from backup
**Features:**
- 🔄 Complete state restoration
- ⚙️ Configuration recovery
- 📊 Data restoration
- 🚀 Service restart

---

## 🐳 Docker & Platform Scripts

### `install_docker.sh`
**Docker installation script**

```bash
./install_docker.sh
```

**Purpose:** Installs Docker and Docker Compose
**Features:**
- 🐳 Latest Docker CE installation
- 📦 Docker Compose installation
- 👥 User permissions setup
- ⚙️ System optimization

---

### `install_caldera.sh`
**Caldera adversary emulation platform setup**

```bash
./install_caldera.sh
```

**Purpose:** Installs and configures Caldera
**Features:**
- 🧠 Caldera platform deployment
- 🔧 Custom configuration
- 🚀 Auto-start service setup
- 🔑 Default credentials setup

---

## 🔍 Helper & Utility Scripts

### `scripts/start-suricata.sh`
**Suricata service management**

```bash
./scripts/start-suricata.sh
```

**Purpose:** Starts and configures Suricata IDS
**Features:**
- 🛡️ Suricata initialization
- 📋 Rule loading
- 🌐 Interface configuration

---

### `portal/start_portal.sh`
**CyberBlue portal startup**

```bash
./portal/start_portal.sh
```

**Purpose:** Starts the CyberBlue web portal
**Features:**
- 🌐 Flask application startup
- 🔒 HTTPS configuration
- 🔑 Authentication setup

---

### `velociraptor/entrypoint.sh`
**Velociraptor container entrypoint**

```bash
# Automatically executed in Velociraptor container
```

**Purpose:** Velociraptor service initialization
**Features:**
- 🕵️ Velociraptor server startup
- ⚙️ Configuration loading
- 🔑 Authentication setup

---

## 📋 Script Usage Examples

### Fresh Installation
```bash
# Complete fresh installation
./cleanup-fresh-install.sh --force
./cyberblue_init.sh
```

### Quick Restart
```bash
# Restart all services
sudo docker-compose restart
./verify-post-reboot.sh
```

### Arkime Analysis
```bash
# Quick network analysis
./fix-arkime.sh --live-30s

# Extended investigation
./fix-arkime.sh --live-5min
```

### Backup & Recovery
```bash
# Create backup
./create-backup.sh

# Restore from backup
./restore-from-backup.sh cyberblue-backup-20250909.tar.gz
```

### Network Troubleshooting
```bash
# Fix external access
./fix-docker-external-access.sh

# Update network interface
./update-network-interface.sh --restart-suricata

# VMware compatibility
./fix-vmware-compatibility.sh
```

---

## 🔧 Script Maintenance

### Making Scripts Executable
```bash
# Make all scripts executable
find . -name "*.sh" -exec chmod +x {} \;
```

### Script Locations
- **Main scripts:** Root directory (`/`)
- **Helper scripts:** `./scripts/` directory
- **Service scripts:** Component directories (`./portal/`, `./velociraptor/`)

### Script Dependencies
- **Docker & Docker Compose:** Required for most scripts
- **sudo privileges:** Required for system modifications
- **Network access:** Required for downloads and updates

---

## 📞 Support & Troubleshooting

### Common Issues
1. **Permission denied:** Ensure scripts are executable (`chmod +x script.sh`)
2. **Docker not found:** Run prerequisites setup first
3. **Network issues:** Check firewall and iptables rules
4. **Service failures:** Check Docker daemon status

### Getting Help
```bash
# Show script help
./script-name.sh --help

# Check system status
./verify-post-reboot.sh

# View logs
sudo docker logs [container-name]
```

---

**📝 Note:** This documentation covers all available scripts in the CyberBlue SOC platform. For the most up-to-date information, check individual script help messages using the `--help` flag.
