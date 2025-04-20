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

echo "Restoring APKs..."
APK_FOUND=0
for pkg_dir in "$BACKUP_DIR/apks/"*/; do
    if [ -d "$pkg_dir" ] && [ "$(basename "$pkg_dir")" != "*" ]; then
        pkg=$(basename "$pkg_dir")
        if pm path "$pkg" | grep -q "/system/"; then
            echo "Skipping: $pkg (system app)"
            log_result 0 "Skipped $pkg (already installed as system app)"
            continue
        fi
        echo "Installing: $pkg"
        apk_files=$(ls "$pkg_dir"*.apk 2>/dev/null)
        if [ -z "$apk_files" ]; then
            log_result 1 "No APK files found for $pkg"
            continue
        fi
        if [ $(df -k /data | tail -1 | awk '{print $4}') -lt 1000000 ]; then
            log_result 1 "Insufficient space in /data for $pkg"
            continue
        fi
        mkdir -p "/data/local/tmp/$pkg" 2>/dev/null
        cp $apk_files "/data/local/tmp/$pkg/" 2>/dev/null
        if [ $? -ne 0 ]; then
            log_result 1 "Failed to copy APKs for $pkg to /data/local/tmp"
            rm -rf "/data/local/tmp/$pkg" 2>/dev/null
            continue
        fi
        chmod 644 "/data/local/tmp/$pkg/"*.apk 2>/dev/null
        for apk in "/data/local/tmp/$pkg/"*.apk; do
            apk_name=$(basename "$apk")
            if [ -f "$pkg_dir/$apk_name.sha256" ]; then
                sha256sum -c "$pkg_dir/$apk_name.sha256" || {
                    log_result 1 "Integrity check failed for $apk"
                    rm -rf "/data/local/tmp/$pkg" 2>/dev/null
                    continue take 2
                }
            fi
        done
        # Run pm install-create and capture output
        pm_create_output=$(pm install-create 2>&1)
        echo "pm install-create output for $pkg: '$pm_create_output'"
        # Extract session ID with a more robust regex
        session_id=$(echo "$pm_create_output" | grep -oE 'session \[[0-9]+\]' | grep -oE '[0-9]+' || true)
        if [ -z "$session_id" ]; then
            log_result 1 "Failed to create install session for $pkg (output: $pm_create_output)"
            rm -rf "/data/local/tmp/$pkg" 2>/dev/null
            continue
        fi
        for apk in "/data/local/tmp/$pkg/"*.apk; do
            pm install-write "$session_id" "$(basename "$apk")" "$apk" 2>/dev/null
            if [ $? -ne 0 ]; then
                log_result 1 "Failed to write APK $(basename "$apk") for $pkg"
                rm -rf "/data/local/tmp/$pkg" 2>/dev/null
                continue take 2
            fi
        done
        install_output=$(pm install-commit "$session_id" 2>&1)
        log_result $? "Installed $pkg: $install_output"
        rm -rf "/data/local/tmp/$pkg" 2>/dev/null
        APK_FOUND=1
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
am force-stop com.google.android.gms
am force-stop com.android.vending
pm disable com.google.android.gms
# Restore account sessions
echo "Restoring account sessions..."
SESSION_FOUND=0
ACCOUNT_PACKAGES="com.google.android.gms com.google.android.gsf com.android.vending"
for pkg in $ACCOUNT_PACKAGES; do
    tarball="$BACKUP_DIR/sessions/$pkg.tar.gz"
    if [ -f "$tarball" ]; then
        SESSION_FOUND=1
        echo "Restoring session data for: $pkg"
        # Check GSF ID before restoring com.google.android.gsf
        if [ "$pkg" = "com.google.android.gsf" ] && [ -f "$BACKUP_DIR/sessions/gsf_id.txt" ]; then
            BACKUP_GSF_ID=$(cat "$BACKUP_DIR/sessions/gsf_id.txt")
            CURRENT_GSF_ID=$(settings get secure android_id)
            if [ "$BACKUP_GSF_ID" != "$CURRENT_GSF_ID" ]; then
                echo "Warning: GSF ID mismatch. Accounts may not restore correctly."
                log_result 1 "GSF ID mismatch (Backup: $BACKUP_GSF_ID, Current: $CURRENT_GSF_ID)"
            fi
        fi
        tar -xzf "$tarball" -C /data/data 2>/dev/null
        if [ $? -eq 0 ]; then
            # Get UID after installation
            uid=$(pm list packages -U | grep "$pkg" | cut -d: -f3)
            if [ -n "$uid" ]; then
                chown -R "$uid":"$uid" "/data/data/$pkg" 2>/dev/null
                chmod 700 "/data/data/$pkg" 2>/dev/null
                find "/data/data/$pkg" -type f -exec chmod 600 {} \; 2>/dev/null
                chcon -R u:object_r:app_data_file:s0 "/data/data/$pkg" 2>/dev/null
                log_result 0 "Restored session data for $pkg (UID: $uid)"
            else
                log_result 0 "Restored session data for $pkg (UID not found, ownership not set)"
            fi
        else
            log_result 1 "Failed to extract session data for $pkg"
        fi
    fi
done

# Restore additional account databases
for db in accounts.db accounts_ce.db accounts_de.db; do
    if [ -f "$BACKUP_DIR/sessions/$db" ]; then
        dest_dir="/data/system/users/0"
        [ "$db" = "accounts_ce.db" ] && dest_dir="/data/system_ce/0"
        [ "$db" = "accounts_de.db" ] && dest_dir="/data/system_de/0"
        mkdir -p "$dest_dir" 2>/dev/null
        cp "$BACKUP_DIR/sessions/$db" "$dest_dir/$db" 2>/dev/null
        chown system:system "$dest_dir/$db" 2>/dev/null
        chmod 660 "$dest_dir/$db" 2>/dev/null
        chcon u:object_r:system_data_file:s0 "$dest_dir/$db" 2>/dev/null
        log_result $? "Restored $dest_dir/$db"
    else
        echo "$db not found in backup"
    fi
done

# Restore sync and credential data
for dir in sync backup misc/backup misc/credentials misc/keychain; do
    if [ -f "$BACKUP_DIR/sessions/$dir.tar.gz" ]; then
        mkdir -p "/data/$dir" 2>/dev/null
        tar -xzf "$BACKUP_DIR/sessions/$dir.tar.gz" -C "/data/$dir/.." 2>/dev/null
        log_result $? "Restored /data/$dir"
    else
        echo "/data/$dir not found in backup"
    fi
done

pm enable com.google.android.gms
pm enable com.google.android.gsf
pm enable com.android.vending

# Apply SELinux contexts
restorecon -R /data/data /data/system /data/system_ce /data/system_de /data/system/sync /data/backup /data/misc 2>/dev/null
log_result $? "Applied SELinux contexts"

# Initialize Google services
for pkg in com.google.android.gms com.google.android.gsf com.android.vending; do
    pm enable "$pkg" 2>/dev/null
    am start -n "$pkg/.MainActivity" 2>/dev/null
    log_result $? "Initialized $pkg"
done

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