#!/system/bin/sh

echo "[INFO] Starting spoof script..."

# Ensure root permissions for all commands
echo "[INFO] Creating Magisk module directory..."
su -c "mkdir -p /data/adb/modules/update_device_info" || echo "[ERROR] Failed to create module directory."

# Write system properties to the Magisk module
echo "[INFO] Writing system properties..."
su -c "echo 'ro.product.model=P30 Lite' > /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to write model."
su -c "echo 'ro.product.brand=Huawei' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.manufacturer=Huawei' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.serialno=HUAHBXCRYRI3HAJ3' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.device=marie' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.name=marie' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.fingerprint=huawei/marie/marie:10/HUAWEIMAR-LX1M/10.0.0.195(C432E5R1P1):user/release-keys' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.release=10' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.sdk=29' >> /data/adb/modules/update_device_info/system.prop"

# Set correct permissions
echo "[INFO] Setting permissions..."
su -c "chmod 644 /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to set permissions."

# Spoof Android ID
echo "[INFO] Changing Android ID to cbb5ff1b61be2e60..."
su -c "settings put secure android_id "cbb5ff1b61be2e60"" || echo "[ERROR] Failed to change Android ID."

# Reset Advertising ID
echo "[INFO] Resetting Advertising ID..."
su -c "rm -rf /data/user_de/0/com.google.android.gms/files/adid_key" || echo "[ERROR] Failed to reset Advertising ID."
su -c "pm clear com.google.android.gms" || echo "[ERROR] Failed to clear Google Play Services."

# Spoof Wi-Fi MAC Address using native commands
echo "[INFO] Spoofing MAC address..."
su -c "ip link set wlan0 down" || echo "[ERROR] Failed to bring down wlan0."
su -c "ip link set wlan0 address 00:11:22:33:44:P30L:JK" && echo "[INFO] MAC address changed to 00:11:22:33:44:P30L:JK" || echo "[ERROR] MAC spoofing failed, skipping..."
su -c "ip link set wlan0 up" || echo "[ERROR] Failed to bring up wlan0."

exit
exit
echo "[INFO] Spoofing script finished!"

    