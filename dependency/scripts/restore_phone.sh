#!/system/bin/sh

# Check if a backup directory was provided as an argument
if [ -z "$1" ]; then
    echo "Error: No backup directory provided. Usage: $0 <backup_dir>"
    exit 1
fi

# Use the first argument as the backup directory
BACKUP_DIR="$1"

# Ensure script runs as root
echo "Starting farm restore from $BACKUP_DIR..."

# Check if the backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    echo "Error: Backup directory $BACKUP_DIR not found!"
    exit 1
fi

# Restore APKs
echo "Restoring APKs..."
for apk in "$BACKUP_DIR/apks/"*.apk; do
    if [ -f "$apk" ]; then
        pm install -r "$apk" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Installed: $(basename "$apk")"
        else
            echo "Failed to install: $(basename "$apk")"
        fi
    fi
done

# Restore app data
echo "Restoring app data..."
for tarball in "$BACKUP_DIR/data/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        tar -xzf "$tarball" -C /data/data 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Restored data: $(basename "$tarball" .tar.gz)"
        else
            echo "Failed to restore data: $(basename "$tarball" .tar.gz)"
        fi
    fi
done

# Restore external data
echo "Restoring external data..."
for tarball in "$BACKUP_DIR/external/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        tar -xzf "$tarball" -C /sdcard/Android/data 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Restored external data: $(basename "$tarball" .tar.gz)"
        else
            echo "Failed to restore external data: $(basename "$tarball" .tar.gz)"
        fi
    fi
done

# Restore OBB files
echo "Restoring OBB files..."
for tarball in "$BACKUP_DIR/obb/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        tar -xzf "$tarball" -C /sdcard/Android/obb 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Restored OBB: $(basename "$tarball" .tar.gz)"
        else
            echo "Failed to restore OBB: $(basename "$tarball" .tar.gz)"
        fi
    fi
done

# Restore /data/local/tmp/spoof/
echo "Restoring spoof folder..."
if [ -f "$BACKUP_DIR/spoof/spoof.tar.gz" ]; then
    # Ensure the target directory exists
    mkdir -p /data/local/tmp
    tar -xzf "$BACKUP_DIR/spoof/spoof.tar.gz" -C /data/local/tmp 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "Restored /data/local/tmp/spoof"
    else
        echo "Failed to restore /data/local/tmp/spoof"
    fi
else
    echo "Spoof backup not found in $BACKUP_DIR/spoof/"
fi

echo "Farm restore completed from $BACKUP_DIR"