#!/bin/bash

# Configuration
BACKUP_NAME="$1"
LOCAL_DIR="$HOME/phone_backups"
TWRP_BACKUP_DIR="/sdcard/TWRP/BACKUPS"

# Get device serial (more reliable)
DEVICE_SERIAL=$(adb devices -l | grep -v "List of devices" | awk '{print $1}' | grep -v "^$" | head -n 1)

# Check if backup name is provided
if [ -z "$BACKUP_NAME" ]; then
    echo "[ERROR] Please provide a backup name! Usage: $0 <backup_name>"
    exit 1
fi

# Check if backup exists locally
if [ ! -d "$LOCAL_DIR/$BACKUP_NAME" ]; then
    echo "[ERROR] Backup $LOCAL_DIR/$BACKUP_NAME not found!"
    exit 1
fi
echo "[INFO] Restoring from $LOCAL_DIR/$BACKUP_NAME"

# Check if device is connected
if [ -z "$DEVICE_SERIAL" ]; then
    echo "[ERROR] No device connected via ADB or not in expected state!"
    adb devices -l  # Show full output for debugging
    exit 1
fi
echo "[INFO] Device detected: $DEVICE_SERIAL"

# Reboot into TWRP
echo "[INFO] Rebooting into TWRP..."
adb -s "$DEVICE_SERIAL" reboot recovery

# Wait for TWRP to boot
echo "[INFO] Waiting for TWRP to start..."
until adb -s "$DEVICE_SERIAL" shell "ls /sbin 2>/dev/null" | grep -q twrp; do
    echo "[INFO] Still waiting for TWRP (device state: $(adb -s "$DEVICE_SERIAL" get-state))..."
    sleep 2
done
echo "[INFO] TWRP detected."

# Push backup to phone
echo "[INFO] Pushing backup to $TWRP_BACKUP_DIR/$DEVICE_SERIAL/$BACKUP_NAME..."
adb -s "$DEVICE_SERIAL" push "$LOCAL_DIR/$BACKUP_NAME" "$TWRP_BACKUP_DIR/$DEVICE_SERIAL/"
if [ $? -eq 0 ]; then
    echo "[INFO] Backup pushed successfully."
else
    echo "[ERROR] Failed to push backup!"
    exit 1
fi

# Restore backup in TWRP
echo "[INFO] Restoring Boot, Data, EFS..."
adb -s "$DEVICE_SERIAL" shell "twrp restore '$BACKUP_NAME' &"

# Wait for restore to complete
echo "[INFO] Waiting for restore to finish..."
until adb -s "$DEVICE_SERIAL" shell "cat /tmp/recovery.log 2>/dev/null" | grep -q "Restore completed successfully"; do
    if adb -s "$DEVICE_SERIAL" shell "cat /tmp/recovery.log 2>/dev/null" | grep -q "Restore failed"; then
        echo "[ERROR] Restore failed according to TWRP log!"
        exit 1
    fi
    echo "[INFO] Restore in progress..."
    sleep 5
done
echo "[INFO] Restore completed."

# Reboot to system
echo "[INFO] Rebooting to system..."
adb -s "$DEVICE_SERIAL" reboot

# Wait for system to boot
echo "[INFO] Waiting for system to boot..."
until adb -s "$DEVICE_SERIAL" get-state | grep -q "device"; do
    sleep 2
done
echo "[INFO] System booted."

echo "[INFO] Restore complete!"