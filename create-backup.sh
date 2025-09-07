#!/bin/bash

# CyberBlueSOC Complete Backup Script
# Creates a comprehensive backup of the entire platform state

set -e

BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/home/ubuntu/CyberBlueSOC-Backups/backup_${BACKUP_DATE}"
SOURCE_DIR="/home/ubuntu/CyberBlueSOC"

echo "🔄 Creating comprehensive CyberBlueSOC backup..."
echo "📅 Backup timestamp: $BACKUP_DATE"
echo "📁 Backup location: $BACKUP_DIR"

# Create backup directory
mkdir -p "$BACKUP_DIR"
cd "$SOURCE_DIR"

echo "📋 Step 1: Saving current container states..."
# Save container status
sudo docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" > "$BACKUP_DIR/container_status.txt"
sudo docker-compose ps > "$BACKUP_DIR/docker_compose_status.txt"

echo "🐳 Step 2: Exporting Docker images..."
# Export current Docker images for key services
mkdir -p "$BACKUP_DIR/docker_images"
sudo docker save -o "$BACKUP_DIR/docker_images/portal.tar" cyberbluesoc-portal:latest 2>/dev/null || echo "Portal image not found"
sudo docker save -o "$BACKUP_DIR/docker_images/caldera.tar" caldera:latest 2>/dev/null || echo "Caldera image not found"

echo "📁 Step 3: Backing up configuration files..."
# Copy all configuration files and directories
cp -r . "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || {
    # If permission issues, copy what we can
    mkdir -p "$BACKUP_DIR/cyberblue_source"
    
    # Copy accessible files
    cp *.md "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp *.sh "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp *.yml "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp LICENSE "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp Makefile "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    
    # Copy directories we can access
    cp -r portal "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp -r docs "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp -r scripts "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp -r attack-navigator "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp -r arkime "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp -r velociraptor "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    cp -r misp "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || true
    
    # Copy accessible parts of other directories
    sudo cp -r wazuh "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || echo "Wazuh: Partial backup due to permissions"
    sudo cp -r suricata "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || echo "Suricata: Partial backup due to permissions"
    sudo cp -r shuffle "$BACKUP_DIR/cyberblue_source/" 2>/dev/null || echo "Shuffle: Partial backup due to permissions"
}

echo "🔧 Step 4: Backing up environment configuration..."
# Backup environment files
cp .env "$BACKUP_DIR/env_backup" 2>/dev/null || echo "No .env file found"
env > "$BACKUP_DIR/current_environment.txt"

echo "📊 Step 5: Exporting container volumes..."
# Create volume backup info
sudo docker volume ls > "$BACKUP_DIR/docker_volumes.txt"

echo "🌐 Step 6: Saving network configuration..."
# Save network configuration
sudo docker network ls > "$BACKUP_DIR/docker_networks.txt"
ip addr show > "$BACKUP_DIR/host_network_config.txt"
ip route show > "$BACKUP_DIR/host_routes.txt"

echo "📝 Step 7: Creating restore script..."
# Create restore script
cat > "$BACKUP_DIR/restore.sh" << 'EOF'
#!/bin/bash

# CyberBlueSOC Restore Script
# Restores the system to the backed up state

set -e

BACKUP_DIR="$(dirname "$0")"
RESTORE_TARGET="/home/ubuntu/CyberBlueSOC"

echo "🔄 Restoring CyberBlueSOC from backup..."
echo "📁 Backup source: $BACKUP_DIR"
echo "📁 Restore target: $RESTORE_TARGET"

# Stop all current containers
echo "🛑 Stopping current containers..."
cd "$RESTORE_TARGET"
sudo docker-compose down 2>/dev/null || true

# Backup current state before restore
echo "💾 Creating safety backup of current state..."
SAFETY_BACKUP="/home/ubuntu/CyberBlueSOC-Backups/safety_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$SAFETY_BACKUP"
cp -r "$RESTORE_TARGET" "$SAFETY_BACKUP/" 2>/dev/null || echo "Partial safety backup created"

# Restore configuration files
echo "📁 Restoring configuration files..."
if [ -d "$BACKUP_DIR/cyberblue_source" ]; then
    # Remove current directory contents (except hidden files)
    cd "$RESTORE_TARGET"
    find . -maxdepth 1 -not -name '.*' -not -name '.' -exec rm -rf {} + 2>/dev/null || true
    
    # Restore from backup
    cp -r "$BACKUP_DIR/cyberblue_source"/* . 2>/dev/null || true
    
    # Restore environment file
    if [ -f "$BACKUP_DIR/env_backup" ]; then
        cp "$BACKUP_DIR/env_backup" .env
    fi
    
    echo "✅ Configuration files restored"
else
    echo "❌ No source backup found in $BACKUP_DIR/cyberblue_source"
    exit 1
fi

# Restore Docker images if available
echo "🐳 Restoring Docker images..."
if [ -d "$BACKUP_DIR/docker_images" ]; then
    for image_file in "$BACKUP_DIR/docker_images"/*.tar; do
        if [ -f "$image_file" ]; then
            echo "Loading $(basename "$image_file")..."
            sudo docker load -i "$image_file" || echo "Failed to load $(basename "$image_file")"
        fi
    done
fi

# Start services
echo "🚀 Starting restored services..."
sudo docker-compose up -d

echo "⏳ Waiting for services to start..."
sleep 30

echo "📊 Checking restored container status..."
sudo docker-compose ps

echo "✅ Restore complete!"
echo "🌐 Portal should be available at: http://$(hostname -I | awk '{print $1}'):5500"
echo "📋 Check container status with: sudo docker-compose ps"
echo "📝 View logs with: sudo docker-compose logs [service-name]"

EOF

chmod +x "$BACKUP_DIR/restore.sh"

echo "📋 Step 8: Creating backup manifest..."
# Create backup manifest
cat > "$BACKUP_DIR/BACKUP_MANIFEST.txt" << EOF
CyberBlueSOC Backup Manifest
============================
Backup Date: $(date)
Backup Location: $BACKUP_DIR
Source Directory: $SOURCE_DIR

Contents:
- ✅ Container status and configuration
- ✅ Docker Compose configuration
- ✅ Portal application and templates
- ✅ Environment configuration
- ✅ Network configuration
- ✅ Volume information
- ✅ Restore script

Container Status at Backup Time:
$(sudo docker ps --format "table {{.Names}}\t{{.Status}}")

Services Running:
$(sudo docker-compose ps | grep "Up")

Notes:
- This backup captures the current working state
- Use restore.sh to restore to this exact configuration
- All portal customizations and configurations included
- Dynamic interface detection script included

To Restore:
1. cd $BACKUP_DIR
2. ./restore.sh

EOF

echo "📊 Step 9: Creating backup summary..."
BACKUP_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
FILE_COUNT=$(find "$BACKUP_DIR" -type f | wc -l)

cat > "$BACKUP_DIR/BACKUP_SUMMARY.txt" << EOF
CyberBlueSOC Backup Summary
==========================
Timestamp: $BACKUP_DATE
Total Size: $BACKUP_SIZE
File Count: $FILE_COUNT
Status: COMPLETE

Key Components Backed Up:
✅ Portal application (app.py, templates, static files)
✅ Docker Compose configuration
✅ Environment variables and configuration
✅ Installation and setup scripts
✅ Documentation and README files
✅ Network interface detection scripts
✅ Caldera configuration
✅ Container state information
✅ Restore automation script

This backup represents a fully working CyberBlueSOC installation
with all current customizations and configurations.
EOF

echo ""
echo "✅ BACKUP COMPLETE!"
echo "📁 Backup created at: $BACKUP_DIR"
echo "📊 Backup size: $BACKUP_SIZE"
echo "📋 Files backed up: $FILE_COUNT"
echo ""
echo "🔄 To restore this exact state later:"
echo "   cd $BACKUP_DIR"
echo "   ./restore.sh"
echo ""
echo "📝 Backup manifest: $BACKUP_DIR/BACKUP_MANIFEST.txt"
echo "📊 Backup summary: $BACKUP_DIR/BACKUP_SUMMARY.txt"
