#!/system/bin/sh

echo "[INFO] Starting spoof script..."

# Ensure root permissions for all commands
echo "[INFO] Creating Magisk module directory..."
su -c "mkdir -p /data/adb/modules/update_device_info" || echo "[ERROR] Failed to create module directory."

# Write system properties to the Magisk module
echo "[INFO] Writing system properties..."
su -c "echo 'ro.product.model=SM-G960Q' > /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to write model."
su -c "echo 'ro.product.brand=samsung' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.manufacturer=samsung' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.serialno=S9$RANDOM$RANDOM' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.device=starlte' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.name=starltexx' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.fingerprint=samsung/starltexx/starlte:10/QP1A.190711.020/G960FXXUHFVG4:user/release-keys' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.release=10' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.sdk=29' >> /data/adb/modules/update_device_info/system.prop"

# Set correct permissions
echo "[INFO] Setting permissions..."
su -c "chmod 644 /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to set permissions."

# Spoof Android ID
RANDOM_ID=$(od -An -N8 -tx8 /dev/urandom | tr -d ' \n')
echo "[INFO] Changing Android ID to $RANDOM_ID..."
su -c "settings put secure android_id \"$RANDOM_ID\"" || echo "[ERROR] Failed to change Android ID."

# Reset Advertising ID
echo "[INFO] Resetting Advertising ID..."
su -c "rm -rf /data/user_de/0/com.google.android.gms/files/adid_key" || echo "[ERROR] Failed to reset Advertising ID."
su -c "pm clear com.google.android.gms" || echo "[ERROR] Failed to clear Google Play Services."

# Spoof Wi-Fi MAC Address using native commands
echo "[INFO] Spoofing MAC address..."
su -c "ip link set wlan0 down" || echo "[ERROR] Failed to bring down wlan0."
NEW_MAC="00:11:22:33:44:$(od -An -N1 -tx1 /dev/urandom | tr -d ' \n')"
su -c "ip link set wlan0 address $NEW_MAC" && echo "[INFO] MAC address changed to $NEW_MAC" || echo "[ERROR] MAC spoofing failed, skipping..."
su -c "ip link set wlan0 up" || echo "[ERROR] Failed to bring up wlan0."


echo "[INFO] Spoofing script finished!"


 Future<String?> _buildAndPushChangeInfoScript({
    required String serialNumber,
    required DeviceInfo deviceInfo,
  }) async {
    logCubit.log(title: "Device Info", message: deviceInfo.toString());
    var newMac = deviceInfo.macAddress;
    var content = """#!/system/bin/sh

echo "[INFO] Starting spoof script..."

# Ensure root permissions for all commands
echo "[INFO] Creating Magisk module directory..."
su -c "mkdir -p /data/adb/modules/update_device_info" || echo "[ERROR] Failed to create module directory."

# Write system properties to the Magisk module
echo "[INFO] Writing system properties..."
su -c "echo 'ro.product.model=${deviceInfo.model}' > /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to write model."
su -c "echo 'ro.product.brand=${deviceInfo.brand}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.manufacturer=${deviceInfo.manufacturer}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.serialno=${deviceInfo.serialNo}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.device=${deviceInfo.device}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.name=${deviceInfo.productName}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.fingerprint=${deviceInfo.fingerprint}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.release=${deviceInfo.releaseVersion}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.sdk=${deviceInfo.sdkVersion}' >> /data/adb/modules/update_device_info/system.prop"

# Set correct permissions
echo "[INFO] Setting permissions..."
su -c "chmod 644 /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to set permissions."

# Spoof Android ID
echo "[INFO] Changing Android ID to ${deviceInfo.androidId}..."
su -c "settings put secure android_id "${deviceInfo.androidId}"" || echo "[ERROR] Failed to change Android ID."

# Reset Advertising ID
echo "[INFO] Resetting Advertising ID..."
su -c "rm -rf /data/user_de/0/com.google.android.gms/files/adid_key" || echo "[ERROR] Failed to reset Advertising ID."
su -c "pm clear com.google.android.gms" || echo "[ERROR] Failed to clear Google Play Services."

# Spoof Wi-Fi MAC Address using native commands
echo "[INFO] Spoofing MAC address..."
su -c "ip link set wlan0 down" || echo "[ERROR] Failed to bring down wlan0."
su -c "ip link set wlan0 address $newMac" && echo "[INFO] MAC address changed to $newMac" || echo "[ERROR] MAC spoofing failed, skipping..."
su -c "ip link set wlan0 up" || echo "[ERROR] Failed to bring up wlan0."

exit
exit
echo "[INFO] Spoofing script finished!"

    """;
    var scriptName =
        "${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}_script_change_info_$serialNumber.sh";
    final scriptFile = File(scriptName);
    await scriptFile.writeAsString(content);

    // Push script to device
    final pushCmd = _adbCommandWithSerial(
      'push ./${scriptFile.path} /data/local/tmp/$scriptName',
      serialNumber,
    );
    try {
      var result = await _shell.run(pushCmd);
      // await scriptFile.delete();

      String output = result.outText.trim();

      if (_isConnectionError(output)) {
        _logError(serialNumber, "Connection error detected.", result.errText);
        return null;
      }

      if (result.first.exitCode == 0) {
        return '/data/local/tmp/$scriptName';
      } else {
        return null;
      }
    } catch (e) {
      logCubit.log(
        title: "Error pushing file",
        message: e.toString(),
        type: LogType.ERROR,
      );
      return null;
    }
  }