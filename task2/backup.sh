#!/bin/bash

# Get directory to backup from argument or prompt
if [ -z "$1" ]; then
  read -p "Enter the directory to backup: " SRC_DIR
else
  SRC_DIR=$1
fi

if [ ! -d "$SRC_DIR" ]; then
  echo "Error: Directory '$SRC_DIR' does not exist."
  exit 1
fi

# Ask for backup location
read -p "Enter backup destination directory: " BACKUP_DIR

if [ ! -d "$BACKUP_DIR" ]; then
  echo "Backup directory doesn't exist. Creating it..."
  mkdir -p "$BACKUP_DIR"
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="$(basename "$SRC_DIR")_backup_$TIMESTAMP.tar.gz"

tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$(dirname "$SRC_DIR")" "$(basename "$SRC_DIR")"

echo "Backup created successfully at $BACKUP_DIR/$ARCHIVE_NAME"
