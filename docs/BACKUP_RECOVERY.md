# 💾 CyberBlue Backup & Disaster Recovery Guide

Comprehensive backup strategies and disaster recovery procedures for CyberBlue deployments.

---

## 🎯 Overview

A robust backup and disaster recovery strategy is essential for maintaining business continuity and protecting critical security data. This guide covers backup strategies, automated procedures, and step-by-step recovery processes.

---

## 📋 **Backup Strategy**

### Backup Types

#### 1. **Configuration Backups** (Daily)
- Docker Compose files
- Environment configurations
- SSL certificates
- Custom configurations

#### 2. **Database Backups** (Daily)
- MISP database
- Wazuh indices
- Application databases
- User configurations

#### 3. **Log Backups** (Weekly)
- Security event logs
- Application logs
- System logs
- Audit trails

#### 4. **System Snapshots** (Weekly)
- Complete container snapshots
- Volume snapshots
- VM/Infrastructure snapshots

### Retention Policy
- **Daily Backups**: 30 days
- **Weekly Backups**: 12 weeks
- **Monthly Backups**: 12 months
- **Yearly Backups**: 7 years (compliance)

---

## 🔄 **Automated Backup Scripts**

### Complete System Backup Script
```bash
#!/bin/bash
# scripts/backup-system.sh

set -e

# Configuration
BACKUP_BASE_DIR="/backup/cyberblue"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_BASE_DIR/$DATE"
LOG_FILE="$BACKUP_DIR/backup.log"
RETENTION_DAYS=30

# Create backup directory
mkdir -p "$BACKUP_DIR"
exec > >(tee -a "$LOG_FILE") 2>&1

echo "=== CyberBlue System Backup Started: $(date) ==="

# Function to log with timestamp
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Creating backup directory: $BACKUP_DIR"

# 1. Configuration Backup
log "Backing up configurations..."
mkdir -p "$BACKUP_DIR/configs"

# Copy configuration files
cp -r /opt/cyberblue/.env* "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r /opt/cyberblue/docker-compose.yml "$BACKUP_DIR/configs/"
cp -r /opt/cyberblue/ssl "$BACKUP_DIR/configs/" 2>/dev/null || true
cp -r /opt/cyberblue/configs "$BACKUP_DIR/configs/" 2>/dev/null || true

log "Configuration backup completed"

# 2. Database Backups
log "Backing up databases..."
mkdir -p "$BACKUP_DIR/databases"

# MISP Database
if docker ps | grep -q misp-db; then
    log "Backing up MISP database..."
    docker exec misp-db mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" --all-databases | gzip > "$BACKUP_DIR/databases/misp-$(date +%Y%m%d).sql.gz"
fi

# Wazuh Indexer
if docker ps | grep -q wazuh-indexer; then
    log "Backing up Wazuh indices..."
    curl -X GET "localhost:9200/_snapshot/cyberblue_backup/_all" | jq . > "$BACKUP_DIR/databases/wazuh-indices-$(date +%Y%m%d).json" 2>/dev/null || true
fi

# Fleet Database
if docker ps | grep -q fleet-mysql; then
    log "Backing up Fleet database..."
    docker exec fleet-mysql mysqldump -u fleet -pfleetpass fleet | gzip > "$BACKUP_DIR/databases/fleet-$(date +%Y%m%d).sql.gz"
fi

log "Database backup completed"

# 3. Volume Backups
log "Backing up Docker volumes..."
mkdir -p "$BACKUP_DIR/volumes"

for volume in $(docker volume ls -q | grep cyberblue); do
    log "Backing up volume: $volume"
    docker run --rm -v "$volume":/data -v "$BACKUP_DIR/volumes":/backup alpine tar czf "/backup/$volume-$(date +%Y%m%d).tar.gz" -C /data .
done

log "Volume backup completed"

# 4. Container Images
log "Backing up container images..."
mkdir -p "$BACKUP_DIR/images"

# Save custom images
for image in $(docker images --format "{{.Repository}}:{{.Tag}}" | grep -E "(cyberblue|local)"); do
    log "Saving image: $image"
    image_name=$(echo "$image" | tr '/:' '_')
    docker save "$image" | gzip > "$BACKUP_DIR/images/$image_name.tar.gz"
done

log "Container image backup completed"

# 5. SSL Certificates
log "Backing up SSL certificates..."
mkdir -p "$BACKUP_DIR/ssl"
cp -r /opt/cyberblue/ssl/* "$BACKUP_DIR/ssl/" 2>/dev/null || true

# 6. System Information
log "Collecting system information..."
mkdir -p "$BACKUP_DIR/system"

# System info
uname -a > "$BACKUP_DIR/system/system_info.txt"
docker version > "$BACKUP_DIR/system/docker_version.txt"
docker-compose version > "$BACKUP_DIR/system/docker_compose_version.txt"
docker ps -a > "$BACKUP_DIR/system/container_status.txt"
docker images > "$BACKUP_DIR/system/image_list.txt"
docker volume ls > "$BACKUP_DIR/system/volume_list.txt"
df -h > "$BACKUP_DIR/system/disk_usage.txt"
free -h > "$BACKUP_DIR/system/memory_usage.txt"

# 7. Generate backup manifest
log "Generating backup manifest..."
cat > "$BACKUP_DIR/MANIFEST.txt" << EOF
CyberBlue System Backup
======================
Backup Date: $(date)
Backup ID: $DATE
System: $(hostname)
CyberBlue Version: $(cd /opt/cyberblue && git describe --tags 2>/dev/null || echo "unknown")

Contents:
- configs/          Configuration files and environment
- databases/        Database dumps and snapshots  
- volumes/          Docker volume backups
- images/           Container image exports
- ssl/              SSL certificates and keys
- system/           System information and status
- backup.log        This backup log file

Verification:
$(find "$BACKUP_DIR" -type f -exec ls -lh {} \; | wc -l) files backed up
Total size: $(du -sh "$BACKUP_DIR" | cut -f1)
EOF

# 8. Create checksums
log "Creating checksums..."
find "$BACKUP_DIR" -type f -not -name "checksums.md5" -exec md5sum {} \; > "$BACKUP_DIR/checksums.md5"

# 9. Compress backup (optional)
if [ "${COMPRESS_BACKUP:-false}" = "true" ]; then
    log "Compressing backup..."
    cd "$BACKUP_BASE_DIR"
    tar czf "$DATE.tar.gz" "$DATE"
    rm -rf "$DATE"
    BACKUP_DIR="$BACKUP_BASE_DIR/$DATE.tar.gz"
fi

# 10. Upload to remote storage (if configured)
if [ -n "${BACKUP_REMOTE_PATH:-}" ]; then
    log "Uploading to remote storage..."
    case "${BACKUP_REMOTE_TYPE:-}" in
        "s3")
            aws s3 sync "$BACKUP_DIR" "$BACKUP_REMOTE_PATH/$DATE/"
            ;;
        "rsync")
            rsync -av "$BACKUP_DIR/" "$BACKUP_REMOTE_PATH/$DATE/"
            ;;
        "scp")
            scp -r "$BACKUP_DIR" "$BACKUP_REMOTE_PATH/$DATE"
            ;;
    esac
fi

# 11. Cleanup old backups
log "Cleaning up old backups..."
find "$BACKUP_BASE_DIR" -maxdepth 1 -type d -name "20*" -mtime +$RETENTION_DAYS -exec rm -rf {} \;

# 12. Verify backup integrity
log "Verifying backup integrity..."
if cd "$BACKUP_DIR" && md5sum -c checksums.md5 >/dev/null 2>&1; then
    log "✅ Backup integrity verified"
    BACKUP_STATUS="SUCCESS"
else
    log "❌ Backup integrity check failed"
    BACKUP_STATUS="FAILED"
fi

# 13. Send notification
if [ -n "${BACKUP_EMAIL:-}" ]; then
    echo "CyberBlue backup completed: $BACKUP_STATUS at $(date)" | \
    mail -s "CyberBlue Backup Report - $BACKUP_STATUS" "$BACKUP_EMAIL"
fi

log "=== CyberBlue System Backup Completed: $(date) ==="
log "Backup location: $BACKUP_DIR"
log "Status: $BACKUP_STATUS"

exit 0
```

### Database-Specific Backup Scripts

#### MISP Database Backup
```bash
#!/bin/bash
# scripts/backup-misp.sh

BACKUP_DIR="/backup/misp/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Database backup
docker exec misp-db mysqldump -u root -p"$MYSQL_ROOT_PASSWORD" misp | gzip > "$BACKUP_DIR/misp-db.sql.gz"

# Files backup
docker cp misp-core:/var/www/MISP/app/files "$BACKUP_DIR/"
docker cp misp-core:/var/www/MISP/app/Config "$BACKUP_DIR/"

# Create manifest
echo "MISP Backup - $(date)" > "$BACKUP_DIR/MANIFEST.txt"
echo "Database: misp-db.sql.gz" >> "$BACKUP_DIR/MANIFEST.txt"
echo "Files: files/" >> "$BACKUP_DIR/MANIFEST.txt"
echo "Config: Config/" >> "$BACKUP_DIR/MANIFEST.txt"

echo "MISP backup completed: $BACKUP_DIR"
```

#### Wazuh Backup
```bash
#!/bin/bash
# scripts/backup-wazuh.sh

BACKUP_DIR="/backup/wazuh/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Create index snapshot
curl -X PUT "localhost:9200/_snapshot/cyberblue_backup" -H 'Content-Type: application/json' -d'
{
  "type": "fs",
  "settings": {
    "location": "/backup/elasticsearch",
    "compress": true
  }
}'

# Snapshot all indices
curl -X PUT "localhost:9200/_snapshot/cyberblue_backup/snapshot_$(date +%Y%m%d)" -H 'Content-Type: application/json' -d'
{
  "indices": "wazuh-*",
  "ignore_unavailable": true,
  "include_global_state": false
}'

# Export configuration
docker cp wazuh.manager:/var/ossec/etc "$BACKUP_DIR/"
docker cp wazuh.dashboard:/usr/share/wazuh-dashboard/data/wazuh/config "$BACKUP_DIR/"

echo "Wazuh backup completed: $BACKUP_DIR"
```

---

## 🔧 **Automated Backup Scheduling**

### Cron Configuration
```bash
# /etc/cron.d/cyberblue-backup

# Daily full backup at 2 AM
0 2 * * * root /opt/cyberblue/scripts/backup-system.sh

# Database backups every 6 hours
0 */6 * * * root /opt/cyberblue/scripts/backup-databases.sh

# Weekly system snapshot on Sundays at 1 AM
0 1 * * 0 root /opt/cyberblue/scripts/create-snapshots.sh

# Monthly verification on first day at 3 AM
0 3 1 * * root /opt/cyberblue/scripts/verify-backups.sh
```

### Systemd Timer (Alternative)
```ini
# /etc/systemd/system/cyberblue-backup.timer
[Unit]
Description=CyberBlue Daily Backup
Requires=cyberblue-backup.service

[Timer]
OnCalendar=daily
Persistent=true

[Install]
WantedBy=timers.target
```

```ini
# /etc/systemd/system/cyberblue-backup.service
[Unit]
Description=CyberBlue Backup Service
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/opt/cyberblue/scripts/backup-system.sh
User=root
```

---

## 🚨 **Disaster Recovery Procedures**

### Complete System Recovery

#### Step 1: Infrastructure Preparation
```bash
#!/bin/bash
# scripts/prepare-recovery.sh

# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh

# Install Docker Compose
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Create CyberBlue directory
mkdir -p /opt/cyberblue
cd /opt/cyberblue

echo "Infrastructure preparation completed"
```

#### Step 2: Restore from Backup
```bash
#!/bin/bash
# scripts/restore-system.sh

if [ $# -ne 1 ]; then
    echo "Usage: $0 <backup_directory>"
    exit 1
fi

BACKUP_DIR="$1"
LOG_FILE="/var/log/cyberblue-restore-$(date +%Y%m%d_%H%M%S).log"

exec > >(tee -a "$LOG_FILE") 2>&1

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "=== CyberBlue System Restore Started ==="
log "Restoring from: $BACKUP_DIR"

# Verify backup integrity
if [ -f "$BACKUP_DIR/checksums.md5" ]; then
    log "Verifying backup integrity..."
    cd "$BACKUP_DIR"
    if md5sum -c checksums.md5; then
        log "✅ Backup integrity verified"
    else
        log "❌ Backup integrity check failed"
        exit 1
    fi
fi

# 1. Restore configurations
log "Restoring configurations..."
cp -r "$BACKUP_DIR/configs/"* /opt/cyberblue/

# 2. Restore SSL certificates
log "Restoring SSL certificates..."
mkdir -p /opt/cyberblue/ssl
cp -r "$BACKUP_DIR/ssl/"* /opt/cyberblue/ssl/

# 3. Load container images
log "Loading container images..."
if [ -d "$BACKUP_DIR/images" ]; then
    for image in "$BACKUP_DIR/images/"*.tar.gz; do
        if [ -f "$image" ]; then
            log "Loading image: $(basename "$image")"
            gunzip -c "$image" | docker load
        fi
    done
fi

# 4. Start core services
log "Starting core services..."
cd /opt/cyberblue
docker-compose up -d db redis opensearch

# Wait for databases to be ready
log "Waiting for databases to initialize..."
sleep 60

# 5. Restore databases
log "Restoring databases..."

# MISP database
if [ -f "$BACKUP_DIR/databases/misp-"*".sql.gz" ]; then
    log "Restoring MISP database..."
    gunzip -c "$BACKUP_DIR/databases/misp-"*".sql.gz" | docker exec -i misp-db mysql -u root -p"$MYSQL_ROOT_PASSWORD"
fi

# Fleet database  
if [ -f "$BACKUP_DIR/databases/fleet-"*".sql.gz" ]; then
    log "Restoring Fleet database..."
    gunzip -c "$BACKUP_DIR/databases/fleet-"*".sql.gz" | docker exec -i fleet-mysql mysql -u fleet -pfleetpass fleet
fi

# 6. Restore volumes
log "Restoring Docker volumes..."
if [ -d "$BACKUP_DIR/volumes" ]; then
    for volume_backup in "$BACKUP_DIR/volumes/"*.tar.gz; do
        if [ -f "$volume_backup" ]; then
            volume_name=$(basename "$volume_backup" .tar.gz | sed 's/-[0-9]*$//')
            log "Restoring volume: $volume_name"
            
            # Create volume if it doesn't exist
            docker volume create "$volume_name" >/dev/null 2>&1 || true
            
            # Restore data
            docker run --rm -v "$volume_name":/data -v "$BACKUP_DIR/volumes":/backup alpine \
                sh -c "cd /data && tar xzf /backup/$(basename "$volume_backup")"
        fi
    done
fi

# 7. Start all services
log "Starting all services..."
docker-compose up -d

# 8. Wait for services to be healthy
log "Waiting for services to be healthy..."
sleep 120

# 9. Verify restoration
log "Verifying restoration..."
./scripts/verify-restore.sh

log "=== CyberBlue System Restore Completed ==="
```

#### Step 3: Verify Recovery
```bash
#!/bin/bash
# scripts/verify-restore.sh

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting restoration verification..."

# Check container status
FAILED_CONTAINERS=0
for container in $(docker-compose ps --services); do
    if docker-compose ps "$container" | grep -q "Up"; then
        log "✅ $container is running"
    else
        log "❌ $container is not running"
        ((FAILED_CONTAINERS++))
    fi
done

# Check service accessibility
FAILED_SERVICES=0
services=("5500:Portal" "7001:Wazuh" "7003:MISP" "7002:Shuffle")

for service in "${services[@]}"; do
    port=$(echo "$service" | cut -d: -f1)
    name=$(echo "$service" | cut -d: -f2)
    
    if nc -z localhost "$port"; then
        log "✅ $name is accessible on port $port"
    else
        log "❌ $name is not accessible on port $port"
        ((FAILED_SERVICES++))
    fi
done

# Check database connectivity
log "Testing database connectivity..."
if docker exec misp-db mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES;" >/dev/null 2>&1; then
    log "✅ MISP database is accessible"
else
    log "❌ MISP database connection failed"
    ((FAILED_SERVICES++))
fi

# Generate verification report
cat > "/var/log/cyberblue-verification-$(date +%Y%m%d_%H%M%S).txt" << EOF
CyberBlue Recovery Verification Report
=====================================
Date: $(date)
Hostname: $(hostname)

Container Status: $FAILED_CONTAINERS failures
Service Status: $FAILED_SERVICES failures

$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}")

Overall Status: $( [ $((FAILED_CONTAINERS + FAILED_SERVICES)) -eq 0 ] && echo "SUCCESS" || echo "FAILED" )
EOF

if [ $((FAILED_CONTAINERS + FAILED_SERVICES)) -eq 0 ]; then
    log "✅ Recovery verification successful"
    return 0
else
    log "❌ Recovery verification failed"
    return 1
fi
```

---

## 📦 **Backup Storage Options**

### Local Storage
```bash
# Local backup configuration
BACKUP_BASE_DIR="/backup/cyberblue"
RETENTION_DAYS=30
COMPRESS_BACKUP=true
```

### AWS S3 Storage
```bash
# AWS S3 backup configuration
BACKUP_REMOTE_TYPE="s3"
BACKUP_REMOTE_PATH="s3://company-backups/cyberblue"
AWS_ACCESS_KEY_ID="your_access_key"
AWS_SECRET_ACCESS_KEY="your_secret_key"
AWS_DEFAULT_REGION="us-west-2"

# Upload function
upload_to_s3() {
    local backup_dir="$1"
    local date_stamp="$2"
    
    aws s3 sync "$backup_dir" "$BACKUP_REMOTE_PATH/$date_stamp/" --delete
    aws s3api put-object-lifecycle-configuration --bucket company-backups --lifecycle-configuration file://s3-lifecycle.json
}
```

### Azure Blob Storage
```bash
# Azure backup configuration
BACKUP_REMOTE_TYPE="azure"
AZURE_STORAGE_ACCOUNT="companystorage"
AZURE_STORAGE_KEY="your_storage_key"
CONTAINER_NAME="cyberblue-backups"

# Upload function
upload_to_azure() {
    local backup_dir="$1"
    local date_stamp="$2"
    
    az storage blob upload-batch --destination "$CONTAINER_NAME/$date_stamp" --source "$backup_dir"
}
```

### Network Storage (NFS/CIFS)
```bash
# Network storage mount
mount -t nfs storage.company.com:/backups/cyberblue /mnt/backup-storage

# Or for CIFS
mount -t cifs //storage.company.com/backups /mnt/backup-storage -o username=backup,password=secret
```

---

## 🔄 **Backup Testing & Validation**

### Monthly Backup Test Script
```bash
#!/bin/bash
# scripts/test-backup-restore.sh

TEST_DIR="/tmp/cyberblue-test-$(date +%Y%m%d_%H%M%S)"
LATEST_BACKUP=$(ls -1t /backup/cyberblue/ | head -1)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting backup restoration test..."
log "Using backup: $LATEST_BACKUP"

# Create test environment
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Extract backup
if [[ "$LATEST_BACKUP" == *.tar.gz ]]; then
    tar xzf "/backup/cyberblue/$LATEST_BACKUP"
    BACKUP_DIR="$TEST_DIR/$(tar tzf "/backup/cyberblue/$LATEST_BACKUP" | head -1 | cut -d/ -f1)"
else
    cp -r "/backup/cyberblue/$LATEST_BACKUP" "$TEST_DIR/"
    BACKUP_DIR="$TEST_DIR/$LATEST_BACKUP"
fi

# Verify backup integrity
if [ -f "$BACKUP_DIR/checksums.md5" ]; then
    cd "$BACKUP_DIR"
    if md5sum -c checksums.md5 >/dev/null 2>&1; then
        log "✅ Backup integrity verified"
    else
        log "❌ Backup integrity check failed"
        exit 1
    fi
fi

# Test database restoration (dry run)
if [ -f "$BACKUP_DIR/databases/misp-"*".sql.gz" ]; then
    log "Testing MISP database restoration..."
    if gunzip -t "$BACKUP_DIR/databases/misp-"*".sql.gz"; then
        log "✅ MISP database backup is valid"
    else
        log "❌ MISP database backup is corrupted"
    fi
fi

# Test configuration files
if [ -f "$BACKUP_DIR/configs/.env" ]; then
    log "✅ Configuration files present"
else
    log "❌ Configuration files missing"
fi

# Cleanup
rm -rf "$TEST_DIR"

log "Backup test completed"
```

---

## 📊 **Backup Monitoring & Alerting**

### Backup Status Monitoring
```bash
#!/bin/bash
# scripts/monitor-backups.sh

BACKUP_DIR="/backup/cyberblue"
ALERT_EMAIL="admin@company.com"
MAX_AGE_HOURS=26  # Alert if no backup in 26 hours

# Find latest backup
LATEST_BACKUP=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "20*" | sort | tail -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "No backups found!" | mail -s "CyberBlue Backup Alert" "$ALERT_EMAIL"
    exit 1
fi

# Check backup age
BACKUP_TIME=$(stat -c %Y "$LATEST_BACKUP")
CURRENT_TIME=$(date +%s)
AGE_HOURS=$(( (CURRENT_TIME - BACKUP_TIME) / 3600 ))

if [ "$AGE_HOURS" -gt "$MAX_AGE_HOURS" ]; then
    echo "Latest backup is $AGE_HOURS hours old (threshold: $MAX_AGE_HOURS hours)" | \
    mail -s "CyberBlue Backup Age Alert" "$ALERT_EMAIL"
fi

# Check backup size (should be reasonable)
BACKUP_SIZE=$(du -s "$LATEST_BACKUP" | cut -f1)
MIN_SIZE=1000000  # 1GB in KB

if [ "$BACKUP_SIZE" -lt "$MIN_SIZE" ]; then
    echo "Latest backup size is suspiciously small: $(du -sh "$LATEST_BACKUP" | cut -f1)" | \
    mail -s "CyberBlue Backup Size Alert" "$ALERT_EMAIL"
fi
```

---

## 📋 **Recovery Testing Schedule**

### Testing Matrix

| Test Type | Frequency | Scope | Duration | RTO Target |
|-----------|-----------|-------|-----------|------------|
| Configuration Recovery | Monthly | Configs only | 30 minutes | 15 minutes |
| Database Recovery | Quarterly | Single database | 1 hour | 30 minutes |
| Partial System Recovery | Semi-annually | Core services | 2 hours | 1 hour |
| Full Disaster Recovery | Annually | Complete system | 4 hours | 2 hours |

### Test Documentation Template
```markdown
# Recovery Test Report

**Date:** [DATE]
**Test Type:** [TYPE]
**Tester:** [NAME]
**Environment:** [PROD/STAGING/TEST]

## Test Objectives
- [ ] Verify backup integrity
- [ ] Test recovery procedures
- [ ] Validate service functionality
- [ ] Measure recovery time

## Test Results
**Start Time:** [TIME]
**End Time:** [TIME]
**Total Duration:** [DURATION]
**RTO Met:** [YES/NO]

## Issues Identified
1. [ISSUE 1]
2. [ISSUE 2]

## Recommendations
1. [RECOMMENDATION 1]
2. [RECOMMENDATION 2]

## Sign-off
**Tester:** [SIGNATURE]
**Date:** [DATE]
```

---

## 🔧 **Recovery Time Objectives (RTO)**

### Service Priority Matrix

| Priority | Services | RTO | RPO |
|----------|----------|-----|-----|
| Critical | Portal, Wazuh Manager | 15 minutes | 1 hour |
| High | MISP, Shuffle | 30 minutes | 4 hours |
| Medium | Velociraptor, TheHive | 1 hour | 12 hours |
| Low | CyberChef, Portainer | 2 hours | 24 hours |

---

*This backup and recovery guide should be tested regularly and updated based on lessons learned from recovery tests and actual incidents.*
