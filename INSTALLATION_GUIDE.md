# 🚀 CyberBlue Installation Guide

## ⚡ One-Command Installation

**Use ONLY this method for installation:**

### 🎯 **Main Installation Script**

```bash
# Clone and install everything with the main script
git clone https://github.com/CyberBlue0/CyberBlue.git
cd CyberBlue
chmod +x cyberblue_init.sh
./cyberblue_init.sh --install-prerequisites
```

**✅ This single script handles:**
- Prerequisites installation (Docker, Docker Compose)
- System optimizations and configuration
- All 15+ security tools deployment
- Network interface detection and configuration
- SSL certificate generation
- Portal authentication setup
- Complete system initialization

## 📋 Script Information

### **Main Script**: `cyberblue_init.sh`
- **Purpose**: Complete CyberBlue installation and initialization
- **Features**: Handles prerequisites, deployment, and configuration
- **Platform Support**: AWS, VMware, VirtualBox, bare metal
- **Size**: ~45KB with comprehensive error handling

### **Legacy Scripts** (Do NOT use these)
These scripts exist for development/testing purposes only:
- `install-cyberblue-final.sh` - Legacy installer
- `cyberblue_complete_install.sh` - Development script
- `cyberblue_simple_install.sh` - Simplified version
- `install-cyberblue.sh` - Old installer
- `install-prerequisites.sh` - Standalone prerequisites

**⚠️ Important**: Use only `cyberblue_init.sh` for installation to avoid conflicts.

## 🔧 Installation Options

### **Option 1: Full Automatic (Recommended)**
```bash
./cyberblue_init.sh --install-prerequisites
```
- Installs everything automatically
- No user interaction required
- Complete setup in one command

### **Option 2: Manual Prerequisites**
```bash
# Install prerequisites manually first
./install-prerequisites.sh
# Then run main initialization
./cyberblue_init.sh
```
- More control over prerequisite installation
- Useful for custom environments

## ✅ After Installation

Access your CyberBlue Portal at:
```
🔒 HTTPS: https://YOUR_SERVER_IP:5443
🔑 Login: admin / cyberblue123
```

## 🆘 Support

If you encounter issues:
1. Check the [Troubleshooting Guide](docs/TROUBLESHOOTING.md)
2. Review logs: `sudo docker logs cyber-blue-portal`
3. Verify all containers: `sudo docker ps`

**Remember**: Use only `cyberblue_init.sh` for installation!
