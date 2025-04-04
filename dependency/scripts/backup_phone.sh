#!/system/bin/sh

# Check if a backup directory was provided as an argument
if [ -z "$1" ]; then
    echo "Error: No backup directory provided. Usage: $0 <backup_dir> [<exclude_list>]"
    exit 1
fi

# Use the first argument as the backup directory
BACKUP_DIR="$1"

# Shift past the first argument to get the exclude list
shift
EXCLUDE_LIST="$@"

# Create subdirectories for the backup
mkdir -p "$BACKUP_DIR/apks" "$BACKUP_DIR/data" "$BACKUP_DIR/obb" "$BACKUP_DIR/external" "$BACKUP_DIR/spoof"

# Ensure script runs as root
echo "Starting farm backup to $BACKUP_DIR..."
if [ -n "$EXCLUDE_LIST" ]; then
    echo "Raw exclude list: '$EXCLUDE_LIST'"
fi

# Directly assign the remaining arguments to EXCLUDE_ARRAY
EXCLUDE_ARRAY=("$@")

# Function to check if a package is in the exclude list
is_excluded() {
    pkg="$1"
    for excluded in "${EXCLUDE_ARRAY[@]}"; do
        if [ "$pkg" = "$excluded" ]; then
            return 0  # True, package is excluded
        fi
    done
    return 1  # False, package is not excluded
}

# Backup APKs for user-installed apps, excluding specified packages
echo "Backing up APKs..."
for pkg in $(pm list packages -3 | cut -d: -f2); do
    if is_excluded "$pkg"; then
        echo "Skipping APK: $pkg (excluded)"
        continue
    fi
    apk_path=$(pm path "$pkg" | cut -d: -f2)
    if [ -f "$apk_path" ]; then
        cp "$apk_path" "$BACKUP_DIR/apks/$pkg.apk"
        echo "Backed up APK: $pkg"
    fi
done

# Backup app data, excluding specified packages
echo "Backing up app data..."
for pkg in $(pm list packages -3 | cut -d: -f2); do
    if is_excluded "$pkg"; then
        echo "Skipping data: $pkg (excluded)"
        continue
    fi
    if [ -d "/data/data/$pkg" ]; then
        tar -czf "$BACKUP_DIR/data/$pkg.tar.gz" -C /data/data "$pkg" 2>/dev/null
        if [ $? -eq 0 ]; then
            echo "Backed up data for: $pkg"
        else
            echo "Failed to back up data for: $pkg"
        fi
    fi
done

# Backup external data, excluding specified packages
echo "Backing up external data..."
for pkg in $(pm list packages -3 | cut -d: -f2); do
    if is_excluded "$pkg"; then
        echo "Skipping external data: $pkg (excluded)"
        continue
    fi
    if [ -d "/sdcard/Android/data/$pkg" ]; then
        tar -czf "$BACKUP_DIR/external/$pkg.tar.gz" -C /sdcard/Android/data "$pkg" 2>/dev/null
        echo "Backed up external data for: $pkg"
    fi
done

# Backup OBB files, excluding specified packages
echo "Backing up OBB files..."
for pkg in $(pm list packages -3 | cut -d: -f2); do
    if is_excluded "$pkg"; then
        echo "Skipping OBB: $pkg (excluded)"
        continue
    fi
    if [ -d "/sdcard/Android/obb/$pkg" ]; then
        tar -czf "$BACKUP_DIR/obb/$pkg.tar.gz" -C /sdcard/Android/obb "$pkg" 2>/dev/null
        echo "Backed up OBB for: $pkg"
    fi
done

# Backup /data/local/tmp/spoof/
echo "Backing up spoof folder..."
if [ -d "/data/local/tmp/spoof" ]; then
    tar -czf "$BACKUP_DIR/spoof/spoof.tar.gz" -C /data/local/tmp spoof 2>/dev/null
    echo "Backed up /data/local/tmp/spoof"
else
    echo "Spoof folder not found at /data/local/tmp/spoof"
fi

echo "Farm backup completed at $BACKUP_DIR"