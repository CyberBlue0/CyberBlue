#!/bin/bash

# Quick Restore Script for CyberBlueSOC
# Usage: ./restore-from-backup.sh

BACKUP_DIR="/home/ubuntu/CyberBlueSOC-Backups/backup_20250830_015717"

if [ ! -d "$BACKUP_DIR" ]; then
    echo "❌ Backup directory not found: $BACKUP_DIR"
    exit 1
fi

echo "🔄 Restoring CyberBlueSOC from backup..."
echo "📁 Using backup: $BACKUP_DIR"

# Execute the restore script from the backup
cd "$BACKUP_DIR"
./restore.sh

echo "✅ Restore completed!"
echo "🌐 Portal should be available at: http://$(hostname -I | awk '{print $1}'):5500"
