# 📖 CyberBlue User Guide

This comprehensive guide covers how to effectively use all tools in the CyberBlue platform.

---

## 🎯 Quick Start Workflows

### 📊 **SIEM Operations**

#### Using Wazuh for Host Monitoring
1. **Access Wazuh Dashboard**: https://YOUR_IP:7001
2. **Default Login**: `admin` / `SecurePass123!`
3. **First Steps**:
   - Navigate to "Agents" → "Deploy new agent"
   - Configure agent for your target systems
   - Monitor alerts in "Security Events"

#### Suricata Network Monitoring
1. **Monitor Network Traffic**: Suricata runs automatically on your configured interface
2. **View Alerts**: Use EveBox at http://YOUR_IP:7015
3. **Rule Management**:
   - Rules located in `./suricata/rules/`
   - Restart Suricata after rule changes: `docker-compose restart suricata`

### 🕵️ **Digital Forensics & Incident Response**

#### Velociraptor Endpoint Analysis
1. **Access Console**: https://YOUR_IP:7000
2. **Client Deployment**:
   ```bash
   # Generate client configuration
   docker exec velociraptor velociraptor config generate
   ```
3. **Common Artifacts**:
   - `Windows.System.PowerShell` - PowerShell activity
   - `Windows.Forensics.Timeline` - System timeline
   - `Linux.Sys.LastUserLogin` - User login history

#### Arkime Packet Analysis
1. **Access Interface**: http://YOUR_IP:7008
2. **Upload PCAP Files**: Use the upload interface
3. **Search Techniques**:
   - IP filters: `ip == 192.168.1.1`
   - Protocol filters: `protocols == tls`
   - Time range searches using the calendar

### 🧠 **Threat Intelligence**

#### MISP Threat Sharing
1. **Access MISP**: https://YOUR_IP:7003
2. **Create Events**:
   - Navigate to "Event Actions" → "Add Event"
   - Add attributes (IPs, domains, hashes)
   - Tag with appropriate taxonomies
3. **Feed Management**:
   - Go to "Sync Actions" → "List Feeds"
   - Enable relevant threat feeds
   - Schedule automatic synchronization

#### MITRE ATT&CK Navigator
1. **Access Navigator**: http://YOUR_IP:7013
2. **Create Layers**:
   - Map threat actor techniques
   - Visualize detection coverage
   - Export for reporting

### ⚡ **Security Orchestration**

#### Shuffle Automation
1. **Access Shuffle**: https://YOUR_IP:7002
2. **Create Workflows**:
   - Drag and drop apps from the left panel
   - Connect apps with logical flows
   - Test workflows before activation
3. **Common Integrations**:
   - Email notifications
   - MISP event creation
   - VirusTotal lookups

#### TheHive Case Management
1. **Access TheHive**: http://YOUR_IP:7005
2. **Create Cases**:
   - Document incidents thoroughly
   - Assign tasks to team members
   - Track investigation progress

---

## 🔧 **Tool-Specific Configurations**

### Wazuh Advanced Setup

#### Custom Rules
```xml
<!-- Custom rule example -->
<group name="local,attack,">
  <rule id="100001" level="12">
    <if_sid>5716</if_sid>
    <srcip>!192.168.1.0/24</srcip>
    <description>SSH login from external IP</description>
    <mitre>
      <id>T1078</id>
    </mitre>
  </rule>
</group>
```

#### Agent Configuration
```xml
<ossec_config>
  <localfile>
    <log_format>apache</log_format>
    <location>/var/log/apache2/access.log</location>
  </localfile>
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>
</ossec_config>
```

### MISP Advanced Configuration

#### Custom Taxonomies
1. Create taxonomy file in `configs/`
2. Import via MISP web interface
3. Apply to events for better categorization

#### API Usage Examples
```python
from pymisp import PyMISP

misp = PyMISP('https://YOUR_IP:7003', 'YOUR_API_KEY', False)

# Create event
event = misp.new_event(
    distribution=1,
    threat_level_id=2,
    analysis=1,
    info="Suspicious activity detected"
)
```

---

## 🔍 **Workflow Examples**

### Incident Response Workflow

1. **Alert Detection** (Wazuh/Suricata)
   - Monitor dashboards for alerts
   - Triage based on severity

2. **Initial Analysis** (EveBox/Arkime)
   - Examine network traffic
   - Identify affected systems

3. **Deep Investigation** (Velociraptor)
   - Deploy artifacts to affected endpoints
   - Collect forensic evidence

4. **Threat Intelligence** (MISP)
   - Check IOCs against threat feeds
   - Create new events for novel threats

5. **Case Management** (TheHive)
   - Document findings
   - Track remediation actions

6. **Automation** (Shuffle)
   - Automate repetitive tasks
   - Orchestrate response actions

### Threat Hunting Workflow

1. **Hypothesis Development**
   - Use MITRE ATT&CK Navigator
   - Identify techniques to hunt for

2. **Data Collection** (Velociraptor)
   - Deploy hunting artifacts
   - Collect system artifacts

3. **Analysis** (CyberChef/Arkime)
   - Process collected data
   - Decode/decrypt artifacts

4. **Correlation** (Wazuh)
   - Create custom rules
   - Monitor for patterns

5. **Documentation** (MISP)
   - Share findings with community
   - Update threat intelligence

---

## 📊 **Dashboard Customization**

### Wazuh Dashboard Widgets

1. **Security Events Overview**
   - Top agents by alerts
   - Alert trend analysis
   - MITRE ATT&CK coverage

2. **Compliance Monitoring**
   - PCI DSS compliance status
   - GDPR monitoring
   - Custom compliance checks

### Custom Suricata Rules

```
# Detect suspicious PowerShell
alert tcp any any -> any 80 (msg:"Suspicious PowerShell Download"; content:"powershell"; content:"downloadstring"; sid:1000001; rev:1;)

# Detect DNS tunneling
alert udp any any -> any 53 (msg:"Possible DNS Tunneling"; content:"|00 01 00 00 00 01|"; byte_test:1,>,30,12; sid:1000002; rev:1;)
```

---

## 🔒 **Security Best Practices**

### Access Control
- Implement strong passwords for all services
- Use multi-factor authentication where possible
- Regularly rotate API keys and certificates

### Network Security
- Configure firewall rules to restrict access
- Use VPN for remote access
- Implement network segmentation

### Data Protection
- Encrypt sensitive data at rest
- Use TLS for all communications
- Implement data retention policies

---

## 📈 **Performance Optimization**

### Resource Allocation
```yaml
# docker-compose.yml resource limits example
services:
  wazuh-indexer:
    deploy:
      resources:
        limits:
          memory: 4G
        reservations:
          memory: 2G
```

### Storage Management
- Monitor disk usage regularly
- Implement log rotation
- Use SSD storage for databases

---

## 📱 **Mobile Access**

All CyberBlue tools are web-based and mobile-responsive:
- Portal: Optimized for mobile devices
- Dashboards: Touch-friendly interfaces
- Alerts: Real-time notifications

---

## 🤝 **Integration Examples**

### SIEM to SOAR Integration
- Configure Wazuh to send alerts to Shuffle
- Create automated response workflows
- Implement custom alerting logic

### Threat Intelligence Sharing
- Configure MISP feeds
- Share IOCs between organizations
- Automate threat intelligence workflows

---

## 📞 **Getting Help**

- **Community Forums**: [GitHub Discussions](https://github.com/m7siri/cyber-blue-project/discussions)
- **Documentation**: This guide and tool-specific docs
- **Issue Reporting**: [GitHub Issues](https://github.com/m7siri/cyber-blue-project/issues)
- **Security Contacts**: See SECURITY.md for vulnerability reporting

---

*This guide is continuously updated. Check the GitHub repository for the latest version.*
