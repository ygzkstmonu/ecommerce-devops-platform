#!/bin/bash

# Project backup script
# Yagiz Kastamonu
# 2025-12-10

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="project_backup_$DATE.tar.gz"

echo "====================================="
echo "Project Backup Script"
echo "====================================="
echo "Starting backup at: $(date)"
echo "Project directory: $PROJECT_DIR"
echo ""

if [ ! -d "$BACKUP_DIR" ]; then
	echo "Cannot find backup folder, creating..."
	mkdir -p "$BACKUP_DIR"
fi

echo "Backup creating..."
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
	--exclude='backups' \
	--exclude='node_modules' \
	--exclude='.git' \
	-C "$(dirname "$PROJECT_DIR")" "$(basename "$PROJECT_DIR")"

if [ $? -eq 0 ]; then

	echo "✓ Backup successful!"
	echo "Location: $BACKUP_DIR/$BACKUP_FILE"
	echo "Size: $(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)"

else
	echo "✗ Backup failed!"
	exit 1
fi

echo ""
echo "All backups:"
ls -lh "$BACKUP_DIR"
echo ""
echo "Backup finished at: $(date)"