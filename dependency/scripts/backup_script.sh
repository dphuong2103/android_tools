#!/bin/bash

# Configuration
BACKUP_NAME="mission1_$(date +%Y-%m-%d_%H-%M-%S)"
TWRP_BACKUP_DIR="/sdcard/TWRP/BACKUPS"
LOCAL_DIR="$HOME/phone_backups"

# Get device serial (more reliable)
DEVICE_SERIAL=$(adb devices -l | grep -v "List of devices" | awk '{print $1}' | grep -v "^$" | head -n 1)

# Check if device is connected
if [ -z "$DEVICE_SERIAL" ]; then
    echo "[ERROR] No device connected via ADB or not in expected state!"
    adb devices -l  # Show full output for debugging
    exit 1
fi
echo "[INFO] Device detected: $DEVICE_SERIAL"

# Create local backup directory
mkdir -p "$LOCAL_DIR"
echo "[INFO] Local backup directory: $LOCAL_DIR"

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

# Create backup in TWRP (Boot, Data, EFS)
echo "[INFO] Starting backup of Boot, Data, EFS..."
adb -s "$DEVICE_SERIAL" shell "twrp backup BDE '$BACKUP_NAME' &"

# Wait for backup to complete
BACKUP_PATH="$TWRP_BACKUP_DIR/$DEVICE_SERIAL/$BACKUP_NAME"
echo "[INFO] Waiting for backup to finish..."
until adb -s "$DEVICE_SERIAL" shell "ls '$BACKUP_PATH' 2>/dev/null" | grep -q "data.*win"; do
    echo "[INFO] Backup in progress (checking $BACKUP_PATH)..."
    sleep 5
done
echo "[INFO] Backup completed."

# Pull backup to computer
echo "[INFO] Pulling backup from $BACKUP_PATH to $LOCAL_DIR..."
adb -s "$DEVICE_SERIAL" pull "$BACKUP_PATH" "$LOCAL_DIR/"
if [ $? -eq 0 ]; then
    echo "[INFO] Backup saved to $LOCAL_DIR/$BACKUP_NAME"
else
    echo "[ERROR] Failed to pull backup!"
    exit 1
fi

# Reboot to system
echo "[INFO] Rebooting to system..."
adb -s "$DEVICE_SERIAL" reboot

# Wait for system to boot
echo "[INFO] Waiting for system to boot..."
until adb -s "$DEVICE_SERIAL" get-state | grep -q "device"; do
    sleep 2
done
echo "[INFO] System booted."

echo "[INFO] Backup complete!"