# 🔧 CyberBlue Maintenance Guide

Comprehensive operational procedures for maintaining a healthy CyberBlue environment.

---

## 🎯 Overview

Regular maintenance is crucial for optimal performance, security, and reliability of your CyberBlue deployment. This guide provides schedules, procedures, and automation scripts for all maintenance tasks.

---

## 📅 **Maintenance Schedule**

### Daily Tasks (Automated)
- ✅ Health checks and monitoring
- ✅ Log rotation and cleanup
- ✅ Security event analysis
- ✅ Resource usage monitoring

### Weekly Tasks
- 🔍 Container performance review
- 🔄 Minor updates and patches
- 🧹 Cleanup unused Docker resources
- 📊 Review security dashboards

### Monthly Tasks
- 🔄 Major updates and upgrades
- 🗄️ Database maintenance
- 🔐 Security certificate renewal
- 📋 Compliance reporting

### Quarterly Tasks
- 🏗️ Infrastructure review
- 🔒 Security audit
- 📚 Documentation updates
- 🧪 Disaster recovery testing

---

## 🤖 **Automated Maintenance Scripts**

### Daily Health Check Script
```bash
#!/bin/bash
# scripts/daily-health-check.sh

LOG_FILE="/var/log/cyberblue/health-check-$(date +%Y%m%d).log"
ALERT_EMAIL="admin@company.com"

echo "=== CyberBlue Daily Health Check - $(date) ===" | tee -a "$LOG_FILE"

# Container Health Check
echo "Checking container health..." | tee -a "$LOG_FILE"
UNHEALTHY=$(docker ps --filter "health=unhealthy" --format "{{.Names}}" | wc -l)
if [ "$UNHEALTHY" -gt 0 ]; then
    echo "WARNING: $UNHEALTHY unhealthy containers found!" | tee -a "$LOG_FILE"
    docker ps --filter "health=unhealthy" --format "table {{.Names}}\t{{.Status}}\t{{.Health}}" | tee -a "$LOG_FILE"
    # Send alert
    echo "Unhealthy containers detected in CyberBlue" | mail -s "CyberBlue Health Alert" "$ALERT_EMAIL"
fi

# Disk Space Check
echo "Checking disk space..." | tee -a "$LOG_FILE"
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
if [ "$DISK_USAGE" -gt 80 ]; then
    echo "WARNING: Disk usage is ${DISK_USAGE}%!" | tee -a "$LOG_FILE"
    echo "High disk usage detected: ${DISK_USAGE}%" | mail -s "CyberBlue Disk Alert" "$ALERT_EMAIL"
fi

# Memory Check
echo "Checking memory usage..." | tee -a "$LOG_FILE"
MEMORY_USAGE=$(free | grep Mem | awk '{print ($3/$2) * 100.0}')
if (( $(echo "$MEMORY_USAGE > 90" | bc -l) )); then
    echo "WARNING: Memory usage is ${MEMORY_USAGE}%!" | tee -a "$LOG_FILE"
    echo "High memory usage detected: ${MEMORY_USAGE}%" | mail -s "CyberBlue Memory Alert" "$ALERT_EMAIL"
fi

# Service Accessibility Check
echo "Checking service accessibility..." | tee -a "$LOG_FILE"
SERVICES=("5500:Portal" "7001:Wazuh" "7002:Shuffle" "7003:MISP")

for service in "${SERVICES[@]}"; do
    PORT=$(echo "$service" | cut -d: -f1)
    NAME=$(echo "$service" | cut -d: -f2)
    
    if nc -z localhost "$PORT"; then
        echo "✅ $NAME ($PORT) - OK" | tee -a "$LOG_FILE"
    else
        echo "❌ $NAME ($PORT) - FAILED" | tee -a "$LOG_FILE"
        echo "$NAME service is not accessible on port $PORT" | mail -s "CyberBlue Service Alert" "$ALERT_EMAIL"
    fi
done

# Log file cleanup (keep last 30 days)
find /var/log/cyberblue/ -name "health-check-*.log" -mtime +30 -delete

echo "Health check completed at $(date)" | tee -a "$LOG_FILE"
```

### Weekly Maintenance Script
```bash
#!/bin/bash
# scripts/weekly-maintenance.sh

LOG_FILE="/var/log/cyberblue/weekly-maintenance-$(date +%Y%m%d).log"

echo "=== CyberBlue Weekly Maintenance - $(date) ===" | tee -a "$LOG_FILE"

# Docker cleanup
echo "Cleaning up Docker resources..." | tee -a "$LOG_FILE"
docker system prune -f | tee -a "$LOG_FILE"
docker image prune -f | tee -a "$LOG_FILE"
docker volume prune -f | tee -a "$LOG_FILE"

# Log rotation for containers
echo "Rotating container logs..." | tee -a "$LOG_FILE"
for container in $(docker ps --format "{{.Names}}"); do
    docker logs --tail 1000 "$container" > "/var/log/cyberblue/containers/${container}-$(date +%Y%m%d).log" 2>&1
done

# Update container images (pull latest)
echo "Pulling latest container images..." | tee -a "$LOG_FILE"
cd /opt/cyberblue
docker-compose pull | tee -a "$LOG_FILE"

# Generate weekly report
echo "Generating weekly report..." | tee -a "$LOG_FILE"
./scripts/generate-weekly-report.sh | tee -a "$LOG_FILE"

echo "Weekly maintenance completed at $(date)" | tee -a "$LOG_FILE"
```

### Monthly Update Script
```bash
#!/bin/bash
# scripts/monthly-updates.sh

LOG_FILE="/var/log/cyberblue/monthly-updates-$(date +%Y%m%d).log"
BACKUP_DIR="/backup/cyberblue-$(date +%Y%m%d)"

echo "=== CyberBlue Monthly Updates - $(date) ===" | tee -a "$LOG_FILE"

# Create backup before updates
echo "Creating backup..." | tee -a "$LOG_FILE"
mkdir -p "$BACKUP_DIR"
./scripts/backup-system.sh "$BACKUP_DIR" | tee -a "$LOG_FILE"

# System updates
echo "Updating system packages..." | tee -a "$LOG_FILE"
sudo apt update && sudo apt upgrade -y | tee -a "$LOG_FILE"

# Docker updates
echo "Updating Docker..." | tee -a "$LOG_FILE"
sudo apt update docker-ce docker-ce-cli containerd.io | tee -a "$LOG_FILE"

# CyberBlue updates
echo "Updating CyberBlue..." | tee -a "$LOG_FILE"
cd /opt/cyberblue
git fetch origin | tee -a "$LOG_FILE"
git merge origin/main | tee -a "$LOG_FILE"

# Restart services with new images
echo "Restarting services..." | tee -a "$LOG_FILE"
docker-compose down | tee -a "$LOG_FILE"
docker-compose up -d | tee -a "$LOG_FILE"

# Verify all services are running
echo "Verifying services..." | tee -a "$LOG_FILE"
sleep 60
./scripts/daily-health-check.sh | tee -a "$LOG_FILE"

echo "Monthly updates completed at $(date)" | tee -a "$LOG_FILE"
```

---

## 📊 **Performance Monitoring**

### Resource Monitoring Script
```bash
#!/bin/bash
# scripts/performance-monitor.sh

METRICS_FILE="/var/log/cyberblue/metrics-$(date +%Y%m%d-%H%M).json"

# Collect system metrics
{
    echo "{"
    echo "  \"timestamp\": \"$(date -Iseconds)\","
    echo "  \"system\": {"
    echo "    \"cpu_usage\": $(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1),"
    echo "    \"memory_usage\": $(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}'),"
    echo "    \"disk_usage\": $(df / | tail -1 | awk '{print $5}' | sed 's/%//'),"
    echo "    \"load_average\": \"$(uptime | awk -F'load average:' '{print $2}')\""
    echo "  },"
    echo "  \"containers\": ["
    
    # Container metrics
    first=true
    docker stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemUsage}},{{.NetIO}},{{.BlockIO}}" | while read line; do
        IFS=',' read -r name cpu mem net block <<< "$line"
        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi
        echo "    {"
        echo "      \"name\": \"$name\","
        echo "      \"cpu_percent\": \"$cpu\","
        echo "      \"memory_usage\": \"$mem\","
        echo "      \"network_io\": \"$net\","
        echo "      \"block_io\": \"$block\""
        echo "    }"
    done
    
    echo "  ]"
    echo "}"
} > "$METRICS_FILE"

# Send metrics to monitoring system (if configured)
if [ -n "$PROMETHEUS_PUSHGATEWAY" ]; then
    curl -X POST "$PROMETHEUS_PUSHGATEWAY/metrics/job/cyberblue" --data-binary @"$METRICS_FILE"
fi
```

### Performance Alert Script
```bash
#!/bin/bash
# scripts/performance-alerts.sh

# Thresholds
CPU_THRESHOLD=80
MEMORY_THRESHOLD=85
DISK_THRESHOLD=90

# Get current metrics
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEMORY_USAGE=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100.0}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

# Check thresholds and alert
if (( $(echo "$CPU_USAGE > $CPU_THRESHOLD" | bc -l) )); then
    echo "High CPU usage: ${CPU_USAGE}%" | mail -s "CyberBlue Performance Alert" admin@company.com
fi

if [ "$MEMORY_USAGE" -gt "$MEMORY_THRESHOLD" ]; then
    echo "High memory usage: ${MEMORY_USAGE}%" | mail -s "CyberBlue Performance Alert" admin@company.com
fi

if [ "$DISK_USAGE" -gt "$DISK_THRESHOLD" ]; then
    echo "High disk usage: ${DISK_USAGE}%" | mail -s "CyberBlue Performance Alert" admin@company.com
fi
```

---

## 🗄️ **Database Maintenance**

### MISP Database Maintenance
```bash
#!/bin/bash
# scripts/misp-db-maintenance.sh

echo "Starting MISP database maintenance..."

# Optimize database tables
docker exec misp-db mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "
USE misp;
OPTIMIZE TABLE attributes;
OPTIMIZE TABLE events;
OPTIMIZE TABLE objects;
OPTIMIZE TABLE object_references;
ANALYZE TABLE attributes;
ANALYZE TABLE events;
"

# Clean old sessions
docker exec misp-core php /var/www/MISP/app/Console/cake Admin clearUserSessions

# Update feeds
docker exec misp-core php /var/www/MISP/app/Console/cake Server pullAll 1

echo "MISP database maintenance completed."
```

### Wazuh Index Maintenance
```bash
#!/bin/bash
# scripts/wazuh-index-maintenance.sh

echo "Starting Wazuh index maintenance..."

# Delete old indices (older than 90 days)
curl -X DELETE "localhost:9200/wazuh-alerts-$(date -d '90 days ago' +%Y.%m.%d)"

# Optimize current indices
curl -X POST "localhost:9200/wazuh-alerts-*/_forcemerge?max_num_segments=1"

# Update index templates
docker exec wazuh-indexer /usr/share/wazuh-indexer/bin/indexer-ism-policy -a create-policy

echo "Wazuh index maintenance completed."
```

---

## 🔐 **Security Maintenance**

### Certificate Renewal Script
```bash
#!/bin/bash
# scripts/renew-certificates.sh

CERT_DIR="/opt/cyberblue/ssl"
DAYS_BEFORE_EXPIRY=30

echo "Checking certificate expiration..."

for cert in "$CERT_DIR"/*.pem; do
    if [ -f "$cert" ]; then
        expiry_date=$(openssl x509 -in "$cert" -noout -enddate | cut -d= -f2)
        expiry_timestamp=$(date -d "$expiry_date" +%s)
        current_timestamp=$(date +%s)
        days_until_expiry=$(( (expiry_timestamp - current_timestamp) / 86400 ))
        
        if [ "$days_until_expiry" -lt "$DAYS_BEFORE_EXPIRY" ]; then
            echo "Certificate $cert expires in $days_until_expiry days!"
            
            # Generate new certificate
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
              -keyout "${cert%.*}-new.key" \
              -out "${cert%.*}-new.pem" \
              -subj "/C=US/ST=State/L=City/O=CyberBlue/CN=$(hostname)"
            
            # Backup old certificate
            mv "$cert" "${cert}.backup.$(date +%Y%m%d)"
            mv "${cert%.*}-new.pem" "$cert"
            
            echo "Certificate renewed: $cert"
        fi
    fi
done

# Restart services to use new certificates
docker-compose restart
```

### Security Update Script
```bash
#!/bin/bash
# scripts/security-updates.sh

echo "Applying security updates..."

# Update base system
sudo apt update
sudo apt list --upgradable | grep -i security
sudo apt upgrade -y

# Update Docker images
cd /opt/cyberblue
docker-compose pull

# Check for vulnerabilities in images
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image --exit-code 1 \
  $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -v "<none>")

# Update CyberBlue codebase
git fetch origin
git merge origin/main

echo "Security updates completed."
```

---

## 📈 **Log Management**

### Log Rotation Configuration
```bash
# /etc/logrotate.d/cyberblue
/var/log/cyberblue/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    copytruncate
    postrotate
        /usr/bin/docker kill -s USR1 $(docker ps -q --filter name=cyber-blue-portal) 2>/dev/null || true
    endscript
}
```

### Log Analysis Script
```bash
#!/bin/bash
# scripts/analyze-logs.sh

LOG_ANALYSIS_DIR="/var/log/cyberblue/analysis"
mkdir -p "$LOG_ANALYSIS_DIR"

# Analyze container logs for errors
echo "Analyzing container logs for errors..."
for container in $(docker ps --format "{{.Names}}"); do
    error_count=$(docker logs "$container" --since 24h 2>&1 | grep -i error | wc -l)
    warning_count=$(docker logs "$container" --since 24h 2>&1 | grep -i warning | wc -l)
    
    echo "$container: $error_count errors, $warning_count warnings" >> "$LOG_ANALYSIS_DIR/daily-summary-$(date +%Y%m%d).txt"
    
    if [ "$error_count" -gt 10 ]; then
        echo "High error count in $container: $error_count errors" | mail -s "CyberBlue Log Alert" admin@company.com
    fi
done

# Generate log statistics
echo "Generating log statistics..."
{
    echo "=== CyberBlue Log Analysis - $(date) ==="
    echo
    echo "Container Error Summary:"
    cat "$LOG_ANALYSIS_DIR/daily-summary-$(date +%Y%m%d).txt"
    echo
    echo "Top Error Messages:"
    docker logs $(docker ps -q) --since 24h 2>&1 | grep -i error | sort | uniq -c | sort -nr | head -10
} > "$LOG_ANALYSIS_DIR/detailed-analysis-$(date +%Y%m%d).txt"
```

---

## 🔄 **Service Management**

### Service Health Monitoring
```bash
#!/bin/bash
# scripts/service-health.sh

check_service_health() {
    local service_name=$1
    local health_endpoint=$2
    
    echo "Checking $service_name..."
    
    if curl -f -s "$health_endpoint" > /dev/null; then
        echo "✅ $service_name is healthy"
        return 0
    else
        echo "❌ $service_name is unhealthy"
        return 1
    fi
}

# Check all services
FAILED_SERVICES=0

check_service_health "Portal" "http://localhost:5500/api/health" || ((FAILED_SERVICES++))
check_service_health "Wazuh" "https://localhost:7001" || ((FAILED_SERVICES++))
check_service_health "MISP" "https://localhost:7003/users/heartbeat" || ((FAILED_SERVICES++))
check_service_health "Shuffle" "http://localhost:7002" || ((FAILED_SERVICES++))

if [ "$FAILED_SERVICES" -gt 0 ]; then
    echo "$FAILED_SERVICES services are unhealthy" | mail -s "CyberBlue Service Health Alert" admin@company.com
    exit 1
fi

echo "All services are healthy"
```

### Automatic Service Recovery
```bash
#!/bin/bash
# scripts/auto-recovery.sh

RECOVERY_LOG="/var/log/cyberblue/recovery.log"

recover_service() {
    local service_name=$1
    
    echo "$(date): Attempting to recover $service_name" >> "$RECOVERY_LOG"
    
    # Try restart first
    docker-compose restart "$service_name"
    sleep 30
    
    # Check if service is healthy
    if docker ps --filter "name=$service_name" --filter "status=running" | grep -q "$service_name"; then
        echo "$(date): $service_name recovered successfully" >> "$RECOVERY_LOG"
        return 0
    else
        # Force recreate if restart failed
        echo "$(date): Restart failed, recreating $service_name" >> "$RECOVERY_LOG"
        docker-compose up -d --force-recreate "$service_name"
        sleep 60
        
        if docker ps --filter "name=$service_name" --filter "status=running" | grep -q "$service_name"; then
            echo "$(date): $service_name recreated successfully" >> "$RECOVERY_LOG"
            return 0
        else
            echo "$(date): Failed to recover $service_name" >> "$RECOVERY_LOG"
            echo "Failed to recover $service_name automatically" | mail -s "CyberBlue Recovery Alert" admin@company.com
            return 1
        fi
    fi
}

# Check for failed containers and attempt recovery
for container in $(docker ps -a --filter "status=exited" --format "{{.Names}}" | grep -E "(wazuh|misp|shuffle|portal)"); do
    recover_service "$container"
done
```

---

## 📋 **Maintenance Checklists**

### Weekly Maintenance Checklist
- [ ] Review container health status
- [ ] Check disk space and cleanup if needed
- [ ] Review security alerts and incidents
- [ ] Update threat intelligence feeds
- [ ] Verify backup completion
- [ ] Review performance metrics
- [ ] Check for available updates

### Monthly Maintenance Checklist
- [ ] Apply security updates
- [ ] Renew expiring certificates
- [ ] Review and update configurations
- [ ] Perform database maintenance
- [ ] Test disaster recovery procedures
- [ ] Review access logs and user activity
- [ ] Update documentation
- [ ] Generate compliance reports

### Quarterly Maintenance Checklist
- [ ] Conduct security audit
- [ ] Review system architecture
- [ ] Update incident response procedures
- [ ] Capacity planning review
- [ ] Staff training updates
- [ ] Vendor relationship review
- [ ] Contract and license renewals

---

## 🚨 **Emergency Procedures**

### Service Outage Response
```bash
#!/bin/bash
# scripts/emergency-response.sh

INCIDENT_ID="INC-$(date +%Y%m%d-%H%M%S)"
INCIDENT_LOG="/var/log/cyberblue/incidents/$INCIDENT_ID.log"

mkdir -p "/var/log/cyberblue/incidents"

echo "=== EMERGENCY RESPONSE - $INCIDENT_ID ===" | tee "$INCIDENT_LOG"
echo "Started at: $(date)" | tee -a "$INCIDENT_LOG"

# Immediate assessment
echo "Performing immediate assessment..." | tee -a "$INCIDENT_LOG"
docker ps -a | tee -a "$INCIDENT_LOG"
docker stats --no-stream | tee -a "$INCIDENT_LOG"

# Attempt automatic recovery
echo "Attempting automatic recovery..." | tee -a "$INCIDENT_LOG"
./scripts/auto-recovery.sh | tee -a "$INCIDENT_LOG"

# Create snapshot for forensics
echo "Creating system snapshot..." | tee -a "$INCIDENT_LOG"
docker commit $(docker ps -aq) emergency-snapshot-$INCIDENT_ID

# Notify stakeholders
echo "Service outage detected - Incident $INCIDENT_ID" | mail -s "CyberBlue Emergency Alert" admin@company.com

echo "Emergency response completed at: $(date)" | tee -a "$INCIDENT_LOG"
```

---

## 📞 **Maintenance Contacts**

### Internal Team
- **Primary Admin**: admin@company.com
- **Secondary Admin**: backup-admin@company.com
- **Security Team**: security@company.com

### Vendor Support
- **Docker Support**: [Docker Support Portal](https://support.docker.com)
- **OS Vendor**: Support specific to your OS distribution
- **Cloud Provider**: AWS/Azure/GCP support as applicable

---

*This maintenance guide should be customized for your specific environment and integrated with your existing operational procedures.*
