import 'dart:io';
import 'dart:math';

import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/features/home/domain/entity/adb_command.dart';
import 'package:android_tools/features/home/domain/entity/adb_device.dart';
import 'package:android_tools/features/home/domain/entity/device_info.dart';
import 'package:intl/intl.dart';
import 'package:process_run/shell.dart';
import 'package:android_tools/core/logging/log_cubit.dart';
import '../../../../injection_container.dart';

class AdbResult {
  final String? serialNumber;
  final bool success;
  final String message;
  final String? error;

  AdbResult({
    required this.success,
    required this.message,
    this.error,
    this.serialNumber,
  });

  @override
  String toString() {
    return success
        ? '✅ [$serialNumber] Success: $message'
        : '❌ [$serialNumber] Error: $error';
  }
}

class AdbService {
  final Shell _shell = Shell();
  final LogCubit logCubit = sl();

  Future<AdbResult> _runCommand({
    required AdbCommand command,
    String? serialNumber,
    int port = 5555,
  }) async {
    if (command is ChangeRandomDeviceInfoCommand) {
      if (serialNumber == null) throw Exception("Serial Number empty");
      return await _changeRandomDeviceInfo(serialNumber: serialNumber);
    }

    String fullCommand = _buildCommand(command, serialNumber, port);

    logCubit.log(title: "ADB Command", message: fullCommand);

    try {
      var result = await _shell.run(fullCommand);
      String output = result.outText.trim();

      if (_isConnectionError(output)) {
        return _logError(
          serialNumber,
          "Connection error detected.",
          result.errText,
        );
      }

      if (result.first.exitCode == 0) {
        return _logSuccess(serialNumber, output);
      } else {
        return _logError(serialNumber, result.outText, result.errText);
      }
    } catch (e) {
      return _logError(serialNumber, "Exception occurred", e.toString());
    }
  }

  String _buildCommand(AdbCommand command, String? serialNumber, int port) {
    return switch (command) {
      ListDevicesCommand() => _withSerial('devices', serialNumber),
      ConnectCommand(address: var address) => 'adb connect $address',
      DisconnectCommand() => _withSerial('disconnect $serialNumber', null),
      TcpIpCommand(port: var p) => _withSerial('tcpip $p', serialNumber),
      ShellCommand(command: var cmd) => _withSerial('shell $cmd', serialNumber),
      OpenPackageCommand(packageName: var pkg) => _withSerial(
        'shell monkey -p $pkg -c android.intent.category.LAUNCHER 1',
        serialNumber,
      ),
      ClosePackageCommand(packageName: var pkg) => _withSerial(
        'shell am force-stop $pkg',
        serialNumber,
      ),
      WithoutShellCommand(command: var cmd) => _withSerial(cmd, serialNumber),
      TapCommand(x: var x, y: var y) => _withSerial(
        'shell input tap $x $y',
        serialNumber,
      ),
      SwipeCommand(
        startX: var sx,
        startY: var sy,
        endX: var ex,
        endY: var ey,
        duration: var dur,
      ) =>
        _withSerial('shell input swipe $sx $sy $ex $ey $dur', serialNumber),
      InstallApkCommand(apkPath: var path) => _withSerial(
        "install \"$path\"",
        serialNumber,
      ),
      UninstallAppsCommand(packages: var packages) => packages
          .map((package) => _withSerial("uninstall $package", serialNumber))
          .join(" && "),
      RebootCommand() => _withSerial("shell reboot", serialNumber),
      RebootBootLoaderCommand() => _withSerial(
        "reboot bootloader",
        serialNumber,
      ),
      KeyCommand(key: var key) => _withSerial(
        'shell input keyevent $key',
        serialNumber,
      ),
      GetTimeZoneCommand() => _withSerial(
        "shell getprop persist.sys.timezone",
        serialNumber,
      ),
      SetProxyCommand(port: var port, ip: var ip) => _withSerial(
        "shell settings put global http_proxy $ip:$port",
        serialNumber,
      ),
      // setprop persist.sys.timezone "America/Chicago"
      ChangeTimeZoneCommand(timeZone: var timeZone) => _withSerial(
        "shell service call alarm 3 s16 $timeZone",
        serialNumber,
      ),
      RemoveProxyCommand() => _withSerial(
        "shell settings put global http_proxy :0",
        serialNumber,
      ),
      VerifyProxyCommand() => _withSerial(
        "shell settings get global http_proxy",
        serialNumber,
      ),
      SetAlwaysOnCommand(value: var value) => _withSerial(
        "shell settings put secure doze_always_on $value",
        serialNumber,
      ),
      GetPackagesCommand() => _withSerial(
        "shell cmd package list packages",
        serialNumber,
      ),
      RecoveryCommand() => _withSerial("reboot recovery", serialNumber),
      _ => throw UnsupportedError('Unknown command'),
    };
  }

  bool _isConnectionError(String output) {
    return output.contains('cannot resolve host') ||
        output.contains('no such host is known') ||
        output.contains('failed to respond') ||
        output.contains('cannot connect');
  }

  AdbResult _logError(String? serialNumber, String message, String? error) {
    logCubit.log(
      title: "ADB Error",
      message: "$message\n$error",
      type: LogType.ERROR,
    );
    return AdbResult(
      success: false,
      message: message,
      error: error,
      serialNumber: serialNumber,
    );
  }

  AdbResult _logSuccess(String? serialNumber, String message) {
    logCubit.log(title: "ADB Success", message: message);
    return AdbResult(
      success: true,
      message: message,
      serialNumber: serialNumber,
    );
  }

  String _withSerial(String command, String? serialNumber) {
    return serialNumber != null
        ? 'adb -s $serialNumber $command'
        : 'adb $command';
  }

  Future<AdbResult> listDevices() async {
    return await _runCommand(command: ListDevicesCommand());
  }

  Future<AdbResult> runShellCommand(
    String command, {
    String? serialNumber,
  }) async {
    return await _runCommand(
      command: ShellCommand(command),
      serialNumber: serialNumber,
    );
  }

  Future<List<AdbResult>> runCommandOnMultipleDevices({
    required List<String> deviceSerials,
    required AdbCommand command,
  }) async {
    logCubit.log(
      title: "Running on multiple devices",
      message: "$deviceSerials -> $command",
    );

    List<Future<AdbResult>> tasks =
        deviceSerials.map((serial) async {
          return await _runCommand(command: command, serialNumber: serial);
        }).toList();

    return await Future.wait(tasks);
  }

  Future<AdbResult> connectOverTcpIp(String serialNumber) async {
    return await _runCommand(
      command: ConnectCommand(serialNumber),
      serialNumber: serialNumber,
    );
  }

  Future<AdbResult> disconnectOverTcpIp(String serialNumber) async {
    return await _runCommand(
      command: DisconnectCommand(),
      serialNumber: serialNumber,
    );
  }

  Future<AdbResult> openPackage(
    String packageName, {
    String? serialNumber,
  }) async {
    return await _runCommand(
      command: OpenPackageCommand(packageName),
      serialNumber: serialNumber,
    );
  }

  Future<AdbResult> closePackage(
    String packageName, {
    String? serialNumber,
  }) async {
    return await _runCommand(
      command: ClosePackageCommand(packageName),
      serialNumber: serialNumber,
    );
  }

  Future<List<AdbDevice>> deviceList() async {
    List<AdbDevice> devices = [];
    final adbOutput = await listDevices();

    for (var line in adbOutput.message.split('\n')) {
      if (line.contains('\t')) {
        final parts = line.split('\t');
        if (parts.length == 2) {
          final serialNumber = parts[0].split(":")[0];
          final status = parts[1];

          devices.add(
            AdbDevice(
              serialNumber: serialNumber,
              status:
                  status == "device"
                      ? AdbDeviceStatus.connected
                      : AdbDeviceStatus.unAuthorized,
            ),
          );
        }
      }
    }

    logCubit.log(
      title: "Device List",
      message: "Found ${devices.length} devices",
    );
    return devices;
  }

  Future<String?> _buildAndPushChangeInfoScript(String serialNumber) async {
    var randomDevice = _generateRandomDeviceInfo();
    logCubit.log(title: "Device Info",message: randomDevice.toString());
    var newMac = "00:11:22:33:44:${randomDevice.macSuffix}";
    var content = """#!/system/bin/sh

echo "[INFO] Starting spoof script..."

# Ensure root permissions for all commands
echo "[INFO] Creating Magisk module directory..."
su -c "mkdir -p /data/adb/modules/update_device_info" || echo "[ERROR] Failed to create module directory."

# Write system properties to the Magisk module
echo "[INFO] Writing system properties..."
su -c "echo 'ro.product.model=${randomDevice.model}' > /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to write model."
su -c "echo 'ro.product.brand=${randomDevice.brand}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.manufacturer=${randomDevice.manufacturer}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.serialno=${randomDevice.serialNo}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.device=${randomDevice.device}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.product.name=${randomDevice.productName}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.fingerprint=${randomDevice.fingerprint}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.release=${randomDevice.fingerprint}' >> /data/adb/modules/update_device_info/system.prop"
su -c "echo 'ro.build.version.sdk=${randomDevice.sdkVersion}' >> /data/adb/modules/update_device_info/system.prop"

# Set correct permissions
echo "[INFO] Setting permissions..."
su -c "chmod 644 /data/adb/modules/update_device_info/system.prop" || echo "[ERROR] Failed to set permissions."

# Spoof Android ID
echo "[INFO] Changing Android ID to ${randomDevice.androidId}..."
su -c "settings put secure android_id "${randomDevice.androidId}"" || echo "[ERROR] Failed to change Android ID."

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
echo "[INFO] Spoofing script finished!"

    """;
    var scriptName =
        "${DateFormat("yyyyMMddHHmmss").format(DateTime.now())}_script_change_info_${serialNumber}.sh";
    final scriptFile = File(scriptName);
    await scriptFile.writeAsString(content);

    // Push script to device
    final pushCmd = _withSerial(
      'push ${scriptFile.path} /data/local/tmp/$scriptName',
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
      return null;
    }

  }

  Future<AdbResult> _changeRandomDeviceInfo({
    required String serialNumber,
  }) async {
    var changeScriptPath = await _buildAndPushChangeInfoScript(serialNumber);
    try {
      var result = await _shell.run(
        """adb shell su -c "chmod +x $changeScriptPath && $changeScriptPath\"""",
      );
      String output = result.outText.trim();

      if (_isConnectionError(output)) {
        return _logError(
          serialNumber,
          "Connection error detected.",
          result.errText,
        );
      }

      if (result.first.exitCode == 0) {
        return await _runCommand(command: RebootCommand(), serialNumber: serialNumber);
      } else {
        return _logError(serialNumber, result.outText, result.errText);
      }
    } catch (e) {
      return _logError(serialNumber, "Exception occurred", e.toString());
    }
  }

  DeviceInfo _generateRandomDeviceInfo() {
    final randomDevice =
        deviceInfoList[Random().nextInt(deviceInfoList.length)];
    final model = randomDevice.model;
    final brand = randomDevice.brand;
    final manufacturer = randomDevice.manufacturer;
    final device = randomDevice.device;
    final productName = randomDevice.productName;
    final releaseVersion = randomDevice.releaseVersion;
    final sdkVersion = randomDevice.sdkVersion;

    final random = Random();
    final serial =
        'XYZ${random.nextInt(10000)}${random.nextInt(10000)}${random.nextInt(10000)}';
    final randStr1 = _generateRandomHex(4);
    final randStr2 = _generateRandomHex(4);
    final randStr3 = _generateRandomHex(4);
    final fingerprint =
        '$brand/$productName/$device:$releaseVersion/$randStr1.$randStr2/$randStr3:user/release-keys';
    final randomId = _generateRandomHex(8);
    final macSuffix = _generateRandomHex(1);
    return DeviceInfo(
      model: model,
      brand: brand,
      manufacturer: manufacturer,
      serialNo: serial,
      device: device,
      productName: productName,
      fingerprint: fingerprint,
      releaseVersion: releaseVersion,
      sdkVersion: sdkVersion,
      macSuffix: macSuffix,
      androidId: randomId,
    );
  }

  String _generateRandomHex(int length) {
    final random = Random();
    return List.generate(
      length,
      (_) => random.nextInt(16).toRadixString(16),
    ).join().toUpperCase();
  }
}
