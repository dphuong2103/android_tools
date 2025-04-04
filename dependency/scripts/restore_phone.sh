#!/system/bin/sh

# Check if a backup directory was provided as an argument
if [ -z "$1" ]; then
    echo "Error: No backup directory provided. Usage: $0 <backup_dir>"
    exit 1
fi

# Use the first argument as the backup directory
BACKUP_DIR="$1"

# Ensure script runs as root
if [ "$(whoami)" != "root" ]; then
    echo "Error: This script must run as root. Use 'su' or ensure root privileges."
    exit 1
fi

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
        if [ ! -r "$apk" ]; then
            echo "Error: Cannot read $apk. Check permissions."
            ls -l "$apk"
            continue
        fi
        echo "Preparing to install: $(basename "$apk")"
        cp "$apk" /data/local/tmp/temp.apk
        if [ $? -eq 0 ]; then
            chmod 644 /data/local/tmp/temp.apk
            pm install -r /data/local/tmp/temp.apk 2>&1
            if [ $? -eq 0 ]; then
                echo "Installed successfully: $(basename "$apk")"
            else
                echo "Failed to install: $(basename "$apk")"
                pm install -r /data/local/tmp/temp.apk
            fi
            rm -f /data/local/tmp/temp.apk
        else
            echo "Failed to copy $apk to /data/local/tmp"
            ls -l "$apk"
        fi
    else
        echo "No APKs found in $BACKUP_DIR/apks/"
        break
    fi
done

# Restore app data
echo "Restoring app data..."
for tarball in "$BACKUP_DIR/data/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        pkg=$(basename "$tarball" .tar.gz)
        echo "Restoring data for: $pkg"
        # Extract data
        tar -xzf "$tarball" -C /data/data 2>/dev/null
        if [ $? -eq 0 ]; then
            # Get the app's UID after installation
            uid=$(pm list packages -U | grep "$pkg" | cut -d: -f3)
            if [ -n "$uid" ]; then
                # Set ownership to the app's UID and group
                chown -R "$uid":"$uid" /data/data/"$pkg"
                # Set permissions (700 for directory, 600 for files)
                chmod 700 /data/data/"$pkg"
                find /data/data/"$pkg" -type f -exec chmod 600 {} \;
                # Restore SELinux context
                chcon -R u:object_r:app_data_file:s0 /data/data/"$pkg"
                echo "Restored data: $pkg (UID: $uid)"
                ls -lZ /data/data/"$pkg"  # Debug output
            else
                echo "Warning: Could not determine UID for $pkg, data restored but ownership not set"
            fi
        else
            echo "Failed to restore data: $pkg"
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