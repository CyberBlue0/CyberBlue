# 📚 CyberBlue Documentation

Welcome to the comprehensive documentation for the CyberBlue cybersecurity platform. This documentation covers everything from basic installation to advanced enterprise deployment and maintenance.

---

## 🎯 Quick Navigation

### 🚀 **Getting Started**
- [Main README](../README.md) - Project overview and quick start
- [Installation Guide](../INSTALL.md) - Step-by-step installation instructions
- [Security Guide](../SECURITY.md) - Security hardening and best practices

### 📖 **User Documentation**
- [**User Guide**](USER_GUIDE.md) - Comprehensive guide for using all CyberBlue tools
- [**Tool Configurations**](TOOL_CONFIGURATIONS.md) - Detailed configuration for each security tool
- [**API Reference**](API_REFERENCE.md) - Complete portal API documentation

### 🚀 **Deployment & Operations**
- [**Deployment Scenarios**](DEPLOYMENT_SCENARIOS.md) - Development, staging, and production deployment guides
- [**Maintenance Guide**](MAINTENANCE_GUIDE.md) - Operational procedures and maintenance schedules
- [**Backup & Recovery**](BACKUP_RECOVERY.md) - Comprehensive backup and disaster recovery procedures

### 🔧 **Troubleshooting & Support**
- [**Troubleshooting Guide**](TROUBLESHOOTING.md) - Common issues and solutions
- [**Performance Optimization**](TROUBLESHOOTING.md#performance-issues) - System performance tuning
- [**Emergency Procedures**](TROUBLESHOOTING.md#emergency-procedures) - Crisis response protocols

---

## 📋 **Documentation Overview**

| Document | Purpose | Audience | Complexity |
|----------|---------|----------|------------|
| [User Guide](USER_GUIDE.md) | How to use CyberBlue tools effectively | SOC Analysts, Security Engineers | Beginner to Intermediate |
| [Tool Configurations](TOOL_CONFIGURATIONS.md) | Advanced tool setup and customization | System Administrators, Security Architects | Intermediate to Advanced |
| [API Reference](API_REFERENCE.md) | Portal API integration and automation | Developers, DevOps Engineers | Intermediate |
| [Deployment Scenarios](DEPLOYMENT_SCENARIOS.md) | Environment-specific deployment guides | Infrastructure Teams, DevOps | Intermediate to Advanced |
| [Maintenance Guide](MAINTENANCE_GUIDE.md) | Operational procedures and schedules | System Administrators, Operations Teams | Intermediate |
| [Backup & Recovery](BACKUP_RECOVERY.md) | Data protection and disaster recovery | Operations Teams, Risk Management | Advanced |
| [Troubleshooting Guide](TROUBLESHOOTING.md) | Problem diagnosis and resolution | Support Teams, Administrators | All Levels |

---

## 🛡️ **Security Tools Covered**

### SIEM & Monitoring
- **[Wazuh](USER_GUIDE.md#using-wazuh-for-host-monitoring)** - Host-based intrusion detection and log analysis
- **[Suricata](USER_GUIDE.md#suricata-network-monitoring)** - Network intrusion detection and prevention
- **[EveBox](USER_GUIDE.md#suricata-network-monitoring)** - Suricata event and alert management

### DFIR & Forensics
- **[Velociraptor](USER_GUIDE.md#velociraptor-endpoint-analysis)** - Endpoint visibility and digital forensics
- **[Arkime](USER_GUIDE.md#arkime-packet-analysis)** - Full packet capture and network analysis
- **[Wireshark](TOOL_CONFIGURATIONS.md#wireshark-configuration)** - Network protocol analyzer

### Threat Intelligence
- **[MISP](USER_GUIDE.md#misp-threat-sharing)** - Threat intelligence platform
- **[MITRE ATT&CK Navigator](USER_GUIDE.md#mitre-attck-navigator)** - Threat modeling and visualization

### SOAR & Automation
- **[Shuffle](USER_GUIDE.md#shuffle-automation)** - Security orchestration and automation
- **[TheHive](USER_GUIDE.md#thehive-case-management)** - Incident response platform
- **[Cortex](TOOL_CONFIGURATIONS.md#cortex-configuration)** - Observable analysis engine

### Utilities & Management
- **[CyberChef](TOOL_CONFIGURATIONS.md#cyberchef-custom-operations)** - Cyber Swiss Army knife
- **[Portainer](TOOL_CONFIGURATIONS.md#portainer-configuration)** - Container management interface
- **[FleetDM](TOOL_CONFIGURATIONS.md#fleet-configuration)** - Device management and osquery fleet manager

---

## 🎓 **Learning Paths**

### For SOC Analysts
1. Start with [User Guide](USER_GUIDE.md) - Basic tool usage
2. Review [Incident Response Workflow](USER_GUIDE.md#incident-response-workflow)
3. Practice with [Workflow Examples](USER_GUIDE.md#workflow-examples)
4. Reference [Troubleshooting Guide](TROUBLESHOOTING.md) for common issues

### For System Administrators
1. Begin with [Installation Guide](../INSTALL.md)
2. Study [Tool Configurations](TOOL_CONFIGURATIONS.md) for advanced setup
3. Implement [Maintenance Guide](MAINTENANCE_GUIDE.md) procedures
4. Master [Backup & Recovery](BACKUP_RECOVERY.md) processes

### For Security Engineers
1. Review [Security Guide](../SECURITY.md) for hardening
2. Explore [API Reference](API_REFERENCE.md) for automation
3. Study [Deployment Scenarios](DEPLOYMENT_SCENARIOS.md) for architecture
4. Implement [Tool Configurations](TOOL_CONFIGURATIONS.md) best practices

### For DevOps Teams
1. Focus on [Deployment Scenarios](DEPLOYMENT_SCENARIOS.md)
2. Implement [API Reference](API_REFERENCE.md) for CI/CD integration
3. Automate with [Maintenance Guide](MAINTENANCE_GUIDE.md) scripts
4. Ensure [Backup & Recovery](BACKUP_RECOVERY.md) procedures

---

## 🔧 **Configuration Quick Reference**

### Essential Configuration Files
```
CyberBlue/
├── .env                          # Environment variables
├── docker-compose.yml            # Main orchestration
├── configs/                      # Tool-specific configs
│   ├── wazuh/
│   ├── misp/
│   └── suricata/
├── ssl/                          # SSL certificates
└── docs/                         # This documentation
```

### Key Environment Variables
- `HOST_IP` - Server IP address
- `PORTAL_PORT` - Portal access port (default: 5500)
- `WAZUH_ADMIN_PASSWORD` - Wazuh dashboard password
- `MISP_ADMIN_PASSWORD` - MISP admin password
- `OPENSEARCH_ADMIN_PASSWORD` - OpenSearch admin password

### Service Access Ports
- **Portal**: 5500
- **Wazuh**: 7001
- **Shuffle**: 7002
- **MISP**: 7003
- **CyberChef**: 7004
- **TheHive**: 7005
- **Cortex**: 7006
- **FleetDM**: 7007
- **Arkime**: 7008
- **EveBox**: 7015
- **Wireshark**: 7011

---

## 📞 **Support & Community**

### Getting Help
1. **Search Documentation**: Use Ctrl+F to search within documents
2. **Check Troubleshooting**: Review [Troubleshooting Guide](TROUBLESHOOTING.md)
3. **Community Support**: [GitHub Discussions](https://github.com/m7siri/cyber-blue-project/discussions)
4. **Issue Reporting**: [GitHub Issues](https://github.com/m7siri/cyber-blue-project/issues)

### Contributing to Documentation
We welcome contributions to improve this documentation:

1. **Report Issues**: Found a problem? [Report it here](https://github.com/m7siri/cyber-blue-project/issues)
2. **Suggest Improvements**: Have ideas? Start a [discussion](https://github.com/m7siri/cyber-blue-project/discussions)
3. **Submit Changes**: Fork, edit, and submit a pull request

### Documentation Standards
- Use clear, concise language
- Include practical examples
- Test all procedures before documenting
- Update version information when tools change
- Maintain consistent formatting and structure

---

## 🆕 **What's New**

### Recent Documentation Updates
- ✅ **Complete User Guide** - Comprehensive tool usage instructions
- ✅ **API Reference** - Full portal API documentation
- ✅ **Advanced Configurations** - Detailed tool setup guides
- ✅ **Deployment Scenarios** - Multi-environment deployment guides
- ✅ **Maintenance Procedures** - Operational best practices
- ✅ **Backup & Recovery** - Comprehensive disaster recovery procedures
- ✅ **Enhanced Troubleshooting** - Expanded problem resolution guide

### Planned Documentation
- 🔄 Video tutorials for common workflows
- 🔄 Integration guides for external tools
- 🔄 Performance benchmarking documentation
- 🔄 Compliance framework mappings
- 🔄 Advanced threat hunting guides

---

## 📊 **Documentation Metrics**

| Metric | Value |
|--------|-------|
| Total Pages | 8 |
| Total Words | ~50,000 |
| Configuration Examples | 100+ |
| Code Snippets | 200+ |
| Troubleshooting Scenarios | 50+ |
| API Endpoints Documented | 30+ |

---

## 🏷️ **Version Information**

- **Documentation Version**: 2.0.0
- **CyberBlue Version**: Latest
- **Last Updated**: January 2024
- **Next Review**: March 2024

---

## 📝 **Feedback**

Your feedback helps improve this documentation. Please:

- ⭐ Star the repository if you find it useful
- 💬 Share your experience in [Discussions](https://github.com/m7siri/cyber-blue-project/discussions)
- 📝 Report documentation issues
- 🤝 Contribute improvements

---

*This documentation is continuously updated. Check the [GitHub repository](https://github.com/m7siri/cyber-blue-project) for the latest version.*

**Made with ❤️ for the cybersecurity community**
