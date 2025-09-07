# 🚀 CyberBlueSOC Quick Reference Guide

**Current System Status**: ✅ **Production Ready with 30+ Containers**

---

## 🔑 **Access Information**

### **Primary Portal (HTTPS)**
- **URL**: `https://YOUR_IP:5443`
- **Login**: `admin` / `cyberblue123`
- **Features**: Secure authentication, SSL encryption, real-time monitoring

### **Service Access Matrix**

| Tool | URL | Credentials | Status | Purpose |
|------|-----|-------------|--------|---------|
| **CyberBlue Portal** | `https://YOUR_IP:5443` | admin/cyberblue123 | ✅ HTTPS Auth | Central Management |
| **Velociraptor** | `https://YOUR_IP:7000` | admin/cyberblue | ✅ HTTPS | Endpoint Forensics |
| **Wazuh** | `https://YOUR_IP:7001` | admin/SecretPassword | ✅ HTTPS | SIEM Dashboard |
| **Shuffle** | `https://YOUR_IP:7002` | admin/password | ✅ HTTPS | Security Automation |
| **MISP** | `https://YOUR_IP:7003` | admin@admin.test/admin | ✅ HTTPS | Threat Intelligence |
| **CyberChef** | `http://YOUR_IP:7004` | No Auth | ✅ HTTP | Data Analysis |
| **TheHive** | `http://YOUR_IP:7005` | admin@thehive.local/secret | ✅ HTTP | Case Management |
| **Cortex** | `http://YOUR_IP:7006` | admin/cyberblue123 | ✅ HTTP | Observable Analysis |
| **FleetDM** | `http://YOUR_IP:7007` | Setup Required | ✅ HTTP | Endpoint Management |
| **Arkime** | `http://YOUR_IP:7008` | admin/admin | ✅ HTTP + Data | Network Analysis |
| **Caldera** | `http://YOUR_IP:7009` | red:cyberblue, blue:cyberblue | ✅ HTTP | Adversary Emulation |
| **EveBox** | `http://YOUR_IP:7015` | No Auth | ✅ HTTP + Events | Suricata Events |
| **Wireshark** | `http://YOUR_IP:7011` | admin/cyberblue | ⚠️ GUI | Protocol Analysis |
| **MITRE Navigator** | `http://YOUR_IP:7013` | No Auth | ✅ HTTP | ATT&CK Visualization |
| **OpenVAS** | `http://YOUR_IP:7014` | admin/cyberblue | ✅ HTTP | Vulnerability Scanning |
| **Portainer** | `https://YOUR_IP:9443` | admin/cyberblue123 | ✅ HTTPS | Container Management |

---

## 🔧 **Common Commands**

### **Container Management**
```bash
# Check all containers
sudo docker ps

# Restart all services
sudo docker-compose restart

# Restart specific service
sudo docker-compose restart [service-name]

# View logs
sudo docker logs [container-name]

# Check resource usage
sudo docker stats
```

### **Portal Management**
```bash
# Restart secure portal
sudo docker-compose restart portal

# Rebuild portal (after changes)
sudo docker-compose build --no-cache portal
sudo docker-compose up -d portal
```

### **Enhanced Arkime Operations**
```bash
# Quick Arkime setup with live capture
./fix-arkime.sh --live                    # 1-minute capture (default)
./fix-arkime.sh --live-30s                # 30-second quick test
./fix-arkime.sh --live-5min               # 5-minute investigation

# Custom duration captures
./fix-arkime.sh -t 2min                   # 2-minute capture
./fix-arkime.sh -t 45s                    # 45-second capture

# Force database reinitialization
./fix-arkime.sh --force --live

# Generate PCAP files for analysis (same as fix-arkime.sh)
./generate-pcap-for-arkime.sh --live      # Default 1-minute
./generate-pcap-for-arkime.sh --live-5min # 5-minute capture
./generate-pcap-for-arkime.sh -t 30s      # 30-second capture
```

# Check portal logs
sudo docker logs cyber-blue-portal

# Test HTTPS access
curl -k https://localhost:5443/login
```

### **Arkime Operations**
```bash
# Reinitialize with fresh data
./scripts/initialize-arkime.sh --capture-live

# Check PCAP files
ls -la ./arkime/pcaps/

# Process new PCAP files
sudo docker exec arkime /opt/arkime/bin/capture -c /opt/arkime/etc/config.ini -r /data/pcap/your_file.pcap

# Check database status
curl http://localhost:9200/_cat/indices/arkime*
```

### **Suricata & EveBox**
```bash
# Update network interface dynamically
./update-network-interface.sh --restart-suricata

# Check current interface
ip route | grep default

# Monitor live events
tail -f ./suricata/logs/eve.json

# Check event count
wc -l ./suricata/logs/eve.json
```

### **Backup & Recovery**
```bash
# Create comprehensive backup
./create-backup.sh

# Quick restore to working state
./restore-from-backup.sh

# List available backups
ls -la /home/ubuntu/CyberBlueSOC-Backups/
```

---

## 🚨 **Emergency Procedures**

### **Complete System Reset**
```bash
# 1. Stop all services
sudo docker-compose down

# 2. Restore from backup
./restore-from-backup.sh

# 3. Verify restoration
sudo docker ps
curl -k https://localhost:5443/login
```

### **Individual Service Recovery**
```bash
# Portal issues
sudo docker-compose stop portal
sudo docker-compose build --no-cache portal
sudo docker-compose up -d portal

# Arkime issues
./scripts/initialize-arkime.sh --force --capture-live

# Suricata issues
./update-network-interface.sh --restart-suricata

# Caldera issues
./install_caldera.sh
```

### **Network Issues**
```bash
# Check interface
ip route | grep default

# Update interface detection
./update-network-interface.sh

# Restart network-dependent services
sudo docker-compose restart suricata evebox arkime
```

---

## 📊 **System Health Checks**

### **Quick Health Verification**
```bash
# Container count (should be 30+)
sudo docker ps | wc -l

# Portal HTTPS test
curl -k -s -o /dev/null -w '%{http_code}' https://localhost:5443/login

# Arkime data check
ls ./arkime/pcaps/*.pcap | wc -l

# Suricata events check
wc -l ./suricata/logs/eve.json

# All services test
for port in 5443 7000 7001 7002 7003 7004 7005 7006 7007 7008 7009 7010 7013 7014 7015 9443; do
  nc -z localhost $port && echo "Port $port: ✅" || echo "Port $port: ❌"
done
```

### **Performance Monitoring**
```bash
# Resource usage
sudo docker stats --no-stream

# Disk usage
df -h

# Memory usage
free -h

# Network interfaces
ip addr show
```

---

## 🎯 **Key Features Status**

- ✅ **HTTPS Portal**: Secure authentication on port 5443
- ✅ **30+ Containers**: All security tools operational
- ✅ **Arkime Data**: Sample network traffic ready for analysis
- ✅ **Suricata Events**: 50K+ security events captured
- ✅ **Dynamic Config**: Auto-detects network interfaces
- ✅ **Backup System**: Complete state preservation
- ✅ **SSL Encryption**: Automatic certificate generation
- ✅ **Authentication**: Secure login with session management

---

## 📞 **Support Resources**

- **Documentation**: [README.md](README.md)
- **Installation Guide**: [INSTALL.md](INSTALL.md)
- **Security Guide**: [SECURITY.md](SECURITY.md)
- **Arkime Setup**: [ARKIME_SETUP.md](ARKIME_SETUP.md)
- **Troubleshooting**: [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)
- **System Verification**: [SYSTEM_VERIFICATION_REPORT.md](SYSTEM_VERIFICATION_REPORT.md)

---

*Last Updated: August 30, 2025 | Version: Enhanced Production Ready*
