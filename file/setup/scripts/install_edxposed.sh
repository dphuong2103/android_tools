#!/system/bin/sh

echo "[INFO] Starting installing edxposed script..."
echo "[INFO] Installing riru..."

su -c "magisk --install-module /sdcard/edxposed/riru.zip" || echo "[ERROR] Failed to install riru."

echo "[INFO] Installing edxposed..."
su -c "magisk --install-module /sdcard/edxposed/edxposed.zip" || echo "[ERROR] Failed to install edxposed."

echo "[INFO] Set enforce..."
su -c "setenforce 0" || echo "[ERROR] Failed to set enforce."

echo "[INFO] Installing edxposed completed..."
