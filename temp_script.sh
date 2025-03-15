#!/system/bin/sh
# Check and create directories
[ -d /data/adb/modules ] || mkdir -p /data/adb/modules
mkdir -p /data/adb/modules/update_device_info

# Write system.prop
echo 'ro.product.model=OnePlus 7' > /data/adb/modules/update_device_info/system.prop
echo 'ro.product.brand=oneplus' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.product.manufacturer=oneplus' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.serialno=XYZ100493765415' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.product.device=oneplus7' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.product.name=oneplus7_global' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.build.fingerprint=oneplus/oneplus7_global/oneplus7:11/9b37a184.ebf9b5c1/f0b84234:user/release-keys' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.build.version.release=11' >> /data/adb/modules/update_device_info/system.prop
echo 'ro.build.version.sdk=30' >> /data/adb/modules/update_device_info/system.prop
chmod 644 /data/adb/modules/update_device_info/system.prop

# Update Android ID and clear ad ID
settings put secure android_id '4b6fa6c35f0fd4aa'
rm -rf /data/user_de/0/com.google.android.gms/files/adid_key
pm clear com.google.android.gms

# Try to spoof MAC address
WLAN=$(ip link | grep -o "wlan[0-1]" | head -n 1)
if [ -n "$WLAN" ]; then
  ifconfig $WLAN down 2>/dev/null || echo "wlan down failed"
  ip link set $WLAN address 00:11:22:33:44:07 2>/dev/null || echo "MAC spoofing failed"
  ifconfig $WLAN up 2>/dev/null || echo "wlan up failed"
else
  echo "No wlan interface found"
fi

echo "Script completed"
