#!/system/bin/sh

echo "[INFO] Installing systemize..."
su -c "magisk --install-module /sdcard/systemize/systemize.zip" || echo "[ERROR] Failed to install systemize."

echo "[INFO] Installing edxposed completed..."
