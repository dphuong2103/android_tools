#!/system/bin/sh

# Check for root privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: This script requires root privileges"
    exit 1
fi

# Check if backup directory is provided
if [ -z "$1" ]; then
    echo "Error: No backup directory provided. Usage: $0 <backup_dir> [<exclude_list>]"
    exit 1
fi

# Sanitize and set backup directory
BACKUP_DIR="$1"
shift
EXCLUDE_LIST="$@"
case "$BACKUP_DIR" in
    /*) ;; # Absolute path is fine
    *) BACKUP_DIR="/sdcard/$BACKUP_DIR" ;; # Default to /sdcard if relative
esac

# Prevent dangerous paths (basic security check)
if echo "$BACKUP_DIR" | grep -qE "^/($|bin|system|data|root)"; then
    echo "Error: Backup directory '$BACKUP_DIR' is in a restricted system area"
    exit 1
fi

# Initialize counters for feedback summary
SUCCESS_COUNT=0
FAILURE_COUNT=0
FAILURES=""

# Create backup subdirectories
echo "Preparing backup directory: $BACKUP_DIR..."
for dir in apks data obb external spoof; do
    if ! mkdir -p "$BACKUP_DIR/$dir" 2>/dev/null; then
        echo "Error: Failed to create $BACKUP_DIR/$dir"
        exit 1
    fi
    chmod 700 "$BACKUP_DIR/$dir" 2>/dev/null # Restrict permissions
done

echo "Starting backup to $BACKUP_DIR..."
[ -n "$EXCLUDE_LIST" ] && echo "Excluding packages: $EXCLUDE_LIST"

# Get package list once for efficiency
PACKAGES=$(pm list packages -3 | cut -d: -f2)
[ -z "$PACKAGES" ] && echo "Warning: No user-installed packages found"

# Function to check if a package is in the exclude list
is_excluded() {
    pkg="$1"
    for excluded in $EXCLUDE_LIST; do
        [ "$pkg" = "$excluded" ] && return 0
    done
    return 1
}

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

# Backup APKs
echo "Backing up APKs..."
for pkg in $PACKAGES; do
    if is_excluded "$pkg"; then
        echo "Skipping APK: $pkg (excluded)"
        continue
    fi
    apk_path=$(pm path "$pkg" | cut -d: -f2)
    if [ -f "$apk_path" ]; then
        cp "$apk_path" "$BACKUP_DIR/apks/$pkg.apk" 2>/dev/null
        log_result $? "Backed up APK for $pkg"
    else
        log_result 1 "APK not found for $pkg"
    fi
done

# Backup app data (includes Shared Preferences)
echo "Backing up app data..."
for pkg in $PACKAGES; do
    if is_excluded "$pkg"; then
        echo "Skipping data: $pkg (excluded)"
        continue
    fi
    if [ -d "/data/data/$pkg" ]; then
        tar -czf "$BACKUP_DIR/data/$pkg.tar.gz" -C /data/data "$pkg" 2>/dev/null
        log_result $? "Backed up data for $pkg (includes Shared Preferences)"
    else
        echo "No data directory found for $pkg"
    fi
done

# Backup external data
echo "Backing up external data..."
for pkg in $PACKAGES; do
    if is_excluded "$pkg"; then
        echo "Skipping external data: $pkg (excluded)"
        continue
    fi
    if [ -d "/sdcard/Android/data/$pkg" ]; then
        tar -czf "$BACKUP_DIR/external/$pkg.tar.gz" -C /sdcard/Android/data "$pkg" 2>/dev/null
        log_result $? "Backed up external data for $pkg"
    fi
done

# Backup OBB files
echo "Backing up OBB files..."
for pkg in $PACKAGES; do
    if is_excluded "$pkg"; then
        echo "Skipping OBB: $pkg (excluded)"
        continue
    fi
    if [ -d "/sdcard/Android/obb/$pkg" ]; then
        tar -czf "$BACKUP_DIR/obb/$pkg.tar.gz" -C /sdcard/Android/obb "$pkg" 2>/dev/null
        log_result $? "Backed up OBB for $pkg"
    fi
done

# Backup spoof folder
echo "Backing up spoof folder..."
if [ -d "/data/local/tmp/spoof" ]; then
    tar -czf "$BACKUP_DIR/spoof/spoof.tar.gz" -C /data/local/tmp spoof 2>/dev/null
    log_result $? "Backed up /data/local/tmp/spoof"
else
    echo "Spoof folder not found at /data/local/tmp/spoof"
fi

# Provide summary
echo "----------------------------------------"
echo "Backup completed at $BACKUP_DIR"
echo "Summary:"
echo "  - Successful operations: $SUCCESS_COUNT"
echo "  - Failed operations: $FAILURE_COUNT"
if [ $FAILURE_COUNT -gt 0 ]; then
    echo "Failures:$FAILURES"
fi
echo "----------------------------------------"

# Exit with appropriate status
[ $FAILURE_COUNT -eq 0 ] && exit 0 || exit 1