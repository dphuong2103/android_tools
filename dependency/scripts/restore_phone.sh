#!/system/bin/sh

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script requires root privileges"
    exit 1
fi

# Check if backup directory is provided
if [ -z "$1" ]; then
    echo "Error: No backup directory provided. Usage: $0 <backup_dir>"
    exit 1
fi

# Sanitize and set backup directory
BACKUP_DIR="$1"
case "$BACKUP_DIR" in
    /*) ;; # Absolute path is fine
    *) BACKUP_DIR="/sdcard/$BACKUP_DIR" ;; # Default to /sdcard if relative
esac

# Prevent dangerous paths (basic security check)
if echo "$BACKUP_DIR" | grep -qE "^/($|bin|system|data|root)"; then
    echo "Error: Backup directory '$BACKUP_DIR' is in a restricted system area"
    exit 1
fi

# Check if backup directory exists and is readable
if [ ! -d "$BACKUP_DIR" ] || [ ! -r "$BACKUP_DIR" ]; then
    echo "Error: Backup directory '$BACKUP_DIR' not found or not readable"
    exit 1
fi

# Initialize counters for feedback summary
SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILURES=""

echo "Starting restore from $BACKUP_DIR..."

# Function to log success or failure
log_result() {
    if [ $1 -eq 0 ]; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
        echo "Success: $2"
    else
        FAILURE_COUNT=$((FAILURE_COUNT + 1))
        FAILURES="$FAILURES\n  - $2"
        echo "Error: $2"
    fi
}

# Restore APKs
echo "Restoring APKs..."
APK_FOUND=0
for apk in "$BACKUP_DIR/apks/"*.apk; do
    if [ -f "$apk" ]; then
        APK_FOUND=1
        if [ ! -r "$apk" ]; then
            log_result 1 "Cannot read $apk (check permissions)"
            continue
        fi
        pkg_name=$(basename "$apk" .apk)
        echo "Installing: $pkg_name"
        cp "$apk" /data/local/tmp/temp.apk 2>/dev/null
        if [ $? -eq 0 ]; then
            chmod 644 /data/local/tmp/temp.apk 2>/dev/null
            pm install -r /data/local/tmp/temp.apk 2>/dev/null
            log_result $? "Installed $pkg_name"
            rm -f /data/local/tmp/temp.apk 2>/dev/null
        else
            log_result 1 "Failed to copy $apk to /data/local/tmp"
        fi
    fi
done
[ $APK_FOUND -eq 0 ] && echo "No APKs found in $BACKUP_DIR/apks/"

# Restore app data (includes Shared Preferences)
echo "Restoring app data..."
DATA_FOUND=0
for tarball in "$BACKUP_DIR/data/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        DATA_FOUND=1
        pkg=$(basename "$tarball" .tar.gz)
        echo "Restoring data for: $pkg"
        tar -xzf "$tarball" -C /data/data 2>/dev/null
        if [ $? -eq 0 ]; then
            # Get UID after installation
            uid=$(pm list packages -U | grep "$pkg" | cut -d: -f3)
            if [ -n "$uid" ]; then
                chown -R "$uid":"$uid" "/data/data/$pkg" 2>/dev/null
                chmod 700 "/data/data/$pkg" 2>/dev/null
                find "/data/data/$pkg" -type f -exec chmod 600 {} \; 2>/dev/null
                chcon -R u:object_r:app_data_file:s0 "/data/data/$pkg" 2>/dev/null
                log_result 0 "Restored data for $pkg (includes Shared Preferences, UID: $uid)"
            else
                log_result 0 "Restored data for $pkg (UID not found, ownership not set)"
            fi
        else
            log_result 1 "Failed to extract data for $pkg"
        fi
    fi
done
[ $DATA_FOUND -eq 0 ] && echo "No app data found in $BACKUP_DIR/data/"

# Restore external data
echo "Restoring external data..."
EXT_FOUND=0
for tarball in "$BACKUP_DIR/external/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        EXT_FOUND=1
        pkg=$(basename "$tarball" .tar.gz)
        tar -xzf "$tarball" -C /sdcard/Android/data 2>/dev/null
        log_result $? "Restored external data for $pkg"
    fi
done
[ $EXT_FOUND -eq 0 ] && echo "No external data found in $BACKUP_DIR/external/"

# Restore OBB files
echo "Restoring OBB files..."
OBB_FOUND=0
for tarball in "$BACKUP_DIR/obb/"*.tar.gz; do
    if [ -f "$tarball" ]; then
        OBB_FOUND=1
        pkg=$(basename "$tarball" .tar.gz)
        tar -xzf "$tarball" -C /sdcard/Android/obb 2>/dev/null
        log_result $? "Restored OBB for $pkg"
    fi
done
[ $OBB_FOUND -eq 0 ] && echo "No OBB files found in $BACKUP_DIR/obb/"

# Restore spoof folder
echo "Restoring spoof folder..."
if [ -f "$BACKUP_DIR/spoof/spoof.tar.gz" ]; then
    mkdir -p /data/local/tmp 2>/dev/null || log_result 1 "Failed to create /data/local/tmp"
    tar -xzf "$BACKUP_DIR/spoof/spoof.tar.gz" -C /data/local/tmp 2>/dev/null
    log_result $? "Restored /data/local/tmp/spoof"
else
    echo "Spoof backup not found in $BACKUP_DIR/spoof/"
fi

# Provide summary
echo "----------------------------------------"
echo "Restore completed from $BACKUP_DIR"
echo "Summary:"
echo "  - Successful operations: $SUCCESS_COUNT"
echo "  - Failed operations: $FAILURE_COUNT"
if [ $FAILURE_COUNT -gt 0 ]; then
    echo "Failures:$FAILURES"
fi
echo "----------------------------------------"

# Exit with appropriate status
[ $FAILURE_COUNT -eq 0 ] && exit 0 || exit 1