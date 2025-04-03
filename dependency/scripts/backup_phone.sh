#!/system/bin/sh

# Check if a backup name was provided as an argument
if [ -z "$1" ]; then
    echo "Error: No backup name provided. Usage: $0 <backup_name>"
    exit 1
fi

# Use the provided argument as the backup name
BACKUP_NAME="$1"

# Define backup destination with the custom name and timestamp
BACKUP_DIR="/sdcard/FarmBackups/${BACKUP_NAME}"
mkdir -p "$BACKUP_DIR/apks" "$BACKUP_DIR/data"

# Ensure script runs as root
echo "Starting farm backup for $BACKUP_NAME..."

# Backup APKs for user-installed apps
echo "Backing up APKs..."
for pkg in $(pm list packages -3 | cut -d: -f2); do
    apk_path=$(pm path "$pkg" | cut -d: -f2)
    if [ -f "$apk_path" ]; then
        cp "$apk_path" "$BACKUP_DIR/apks/$pkg.apk"
        echo "Backed up APK: $pkg"
    fi
done

# Backup app data
echo "Backing up app data..."
for pkg in $(pm list packages -3 | cut -d: -f2); do
    tar -czf "$BACKUP_DIR/data/$pkg.tar.gz" -C /data/data "$pkg" 2>/dev/null
    echo "Backed up data for: $pkg"
done

echo "Farm backup completed at $BACKUP_DIR"