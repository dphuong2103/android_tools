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
for dir in apks data obb external spoof sessions; do
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

echo "Backing up APKs..."
TEMP_DIR="$BACKUP_DIR/tmp"
mkdir -p "$TEMP_DIR" 2>/dev/null
APK_FOUND=0
for pkg in $PACKAGES; do
    if is_excluded "$pkg"; then
        echo "Skipping APK: $pkg (excluded)"
        continue
    fi
    apk_base=$(pm path "$pkg" | grep base.apk | cut -d: -f2)
    if [ -z "$apk_base" ]; then
        log_result 1 "No base APK path found for $pkg"
        continue
    fi
    apk_dir=$(dirname "$apk_base")
    apk_paths=$(find "$apk_dir" -maxdepth 1 -name "*.apk" 2>/dev/null)
    if [ -z "$apk_paths" ]; then
        log_result 1 "No APK files found in $apk_dir for $pkg"
        continue
    fi
    if [ $(df -k "$BACKUP_DIR" | tail -1 | awk '{print $4}') -lt 1000000 ]; then
        log_result 1 "Insufficient storage in $BACKUP_DIR for $pkg"
        continue
    fi
    mkdir -p "$BACKUP_DIR/apks/$pkg" 2>/dev/null
    success=0
    for apk_path in $apk_paths; do
        if [ -f "$apk_path" ]; then
            apk_name=$(basename "$apk_path")
            retry_count=0
            max_retries=3
            while [ $retry_count -lt $max_retries ]; do
                cp "$apk_path" "$BACKUP_DIR/apks/$pkg/$apk_name" 2>/dev/null
                if [ $? -eq 0 ]; then
                    sha256sum "$apk_path" | cut -d' ' -f1 > "$TEMP_DIR/$apk_name.sha256"
                    sha256sum "$BACKUP_DIR/apks/$pkg/$apk_name" | cut -d' ' -f1 | cmp -s "$TEMP_DIR/$apk_name.sha256" -
                    if [ $? -eq 0 ]; then
                        sha256sum "$BACKUP_DIR/apks/$pkg/$apk_name" > "$BACKUP_DIR/apks/$pkg/$apk_name.sha256"
                        success=1
                        break
                    else
                        log_result 1 "Integrity check failed for $apk_name (pkg: $pkg)"
                        rm -f "$BACKUP_DIR/apks/$pkg/$apk_name" 2>/dev/null
                    fi
                fi
                retry_count=$((retry_count + 1))
                [ $retry_count -lt $max_retries ] && sleep 1
            done
            rm -f "$TEMP_DIR/$apk_name.sha256" 2>/dev/null
            if [ $retry_count -eq $max_retries ]; then
                log_result 1 "Failed to copy APK $apk_name for $pkg after $max_retries retries"
            fi
        else
            log_result 1 "APK file not found at $apk_path for $pkg"
        fi
    done
    [ $success -eq 1 ] && {
        APK_FOUND=1
        log_result 0 "Backed up APK(s) for $pkg"
    }
done
[ $APK_FOUND -eq 0 ] && echo "No APKs backed up"
rm -rf "$TEMP_DIR" 2>/dev/null

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

# Backup account sessions (Google and other system accounts)
echo "Backing up account sessions..."
ACCOUNT_PACKAGES="com.google.android.gms com.google.android.gsf com.android.vending"
for pkg in $ACCOUNT_PACKAGES; do
    if [ -d "/data/data/$pkg" ]; then
        tar -czf "$BACKUP_DIR/sessions/$pkg.tar.gz" -C /data/data "$pkg" 2>/dev/null
        log_result $? "Backed up session data for $pkg"
    else
        echo "No session data directory found for $pkg"
    fi
done

# Backup additional account databases
for db in /data/system/users/0/accounts.db /data/system_ce/0/accounts_ce.db /data/system_de/0/accounts_de.db; do
    if [ -f "$db" ]; then
        cp "$db" "$BACKUP_DIR/sessions/$(basename "$db")" 2>/dev/null
        log_result $? "Backed up $db"
    else
        echo "$db not found"
    fi
done

# Backup sync and credential data
for dir in /data/system/sync /data/backup /data/misc/backup /data/misc/credentials /data/misc/keychain; do
    if [ -d "$dir" ]; then
        tar -czf "$BACKUP_DIR/sessions/$(basename "$dir").tar.gz" -C "$(dirname "$dir")" "$(basename "$dir")" 2>/dev/null
        log_result $? "Backed up $dir"
    else
        echo "$dir not found"
    fi
done

# Backup GSF ID
GSF_ID=$(settings get secure android_id) # Approximate GSF ID
if [ -n "$GSF_ID" ]; then
    echo "$GSF_ID" > "$BACKUP_DIR/sessions/gsf_id.txt" 2>/dev/null
    log_result $? "Backed up GSF ID"
else
    echo "GSF ID not found"
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