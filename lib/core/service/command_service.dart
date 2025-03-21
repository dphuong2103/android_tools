import 'dart:io';
import 'dart:math';

import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/domain/entity/adb_device.dart';
import 'package:android_tools/features/home/domain/entity/device_info.dart';
import 'package:intl/intl.dart';
import 'package:process_run/shell.dart';
import 'package:android_tools/core/logging/log_cubit.dart';
import '../../../../injection_container.dart';

class CommandResult {
  final String? serialNumber;
  final bool success;
  final String message;
  final String? error;

  CommandResult({
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

class CommandService {
  final Shell _shell = Shell();
  final LogCubit logCubit = sl();

  Future<CommandResult> runCommand({
    required Command command,
    String? serialNumber,
    int port = 5555,
  }) async {
    if (command is ChangeRandomDeviceInfoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      var deviceInfo = _generateRandomDeviceInfo();
      return await _changeDeviceInfo(
        deviceInfo: deviceInfo,
        serialNumber: serialNumber,
        packagesToClear: command.packagesToClear,
      );
    }

    if (command is ChangeDeviceInfoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return await _changeDeviceInfo(
        deviceInfo: command.deviceInfo,
        serialNumber: serialNumber,
        packagesToClear: command.packagesToClear,
      );
    }

    String fullCommand = _buildCommand(command, serialNumber, port);

    logCubit.log(
      title: "ADB Command",
      message: fullCommand,
      type: LogType.DEBUG,
    );

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

  String _buildCommand(Command command, String? serialNumber, int port) {
    return switch (command) {
      ListDevicesCommand() => _adbCommandWithSerial('devices', serialNumber),
      ConnectCommand(address: var address) => 'adb connect $address',
      DisconnectCommand() => _adbCommandWithSerial(
        'disconnect $serialNumber',
        null,
      ),
      TcpIpCommand(port: var p) => _adbCommandWithSerial(
        'tcpip $p',
        serialNumber,
      ),
      ShellCommand(command: var cmd) => _adbCommandWithSerial(
        'shell $cmd',
        serialNumber,
      ),
      OpenPackageCommand(packageName: var pkg) => _adbCommandWithSerial(
        'shell monkey -p $pkg -c android.intent.category.LAUNCHER 1',
        serialNumber,
      ),
      ClosePackageCommand(packageName: var pkg) => _adbCommandWithSerial(
        'shell am force-stop $pkg',
        serialNumber,
      ),
      WithoutShellCommand(command: var cmd) => _adbCommandWithSerial(
        cmd,
        serialNumber,
      ),
      TapCommand(x: var x, y: var y) => _adbCommandWithSerial(
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
        _adbCommandWithSerial(
          'shell input swipe $sx $sy $ex $ey $dur',
          serialNumber,
        ),
      InstallApkCommand(apkPath: var path) => _adbCommandWithSerial(
        "install \"$path\"",
        serialNumber,
      ),
      UninstallAppsCommand(packages: var packages) => packages
          .map(
            (package) =>
                _adbCommandWithSerial("uninstall $package", serialNumber),
          )
          .join(" && "),
      RebootCommand() => _adbCommandWithSerial("reboot", serialNumber),
      RebootBootLoaderCommand() => _adbCommandWithSerial(
        "reboot bootloader",
        serialNumber,
      ),
      KeyCommand(key: var key) => _adbCommandWithSerial(
        'shell input keyevent $key',
        serialNumber,
      ),
      GetTimeZoneCommand() => _adbCommandWithSerial(
        "shell getprop persist.sys.timezone",
        serialNumber,
      ),
      SetProxyCommand(port: var port, ip: var ip) => _adbCommandWithSerial(
        "shell settings put global http_proxy $ip:$port",
        serialNumber,
      ),
      // setprop persist.sys.timezone "America/Chicago"
      ChangeTimeZoneCommand(timeZone: var timeZone) => _adbCommandWithSerial(
        "shell service call alarm 3 s16 $timeZone",
        serialNumber,
      ),
      RemoveProxyCommand() => _adbCommandWithSerial(
        "shell settings put global http_proxy :0",
        serialNumber,
      ),
      VerifyProxyCommand() => _adbCommandWithSerial(
        "shell settings get global http_proxy",
        serialNumber,
      ),
      SetAlwaysOnCommand(value: var value) => _adbCommandWithSerial(
        "shell settings put secure doze_always_on $value",
        serialNumber,
      ),
      GetPackagesCommand() => _adbCommandWithSerial(
        "shell cmd package list packages",
        serialNumber,
      ),
      RemoveFilesCommand(filePaths: var filePaths) => _adbCommandWithSerial(
        'shell "su -c \'${filePaths.map((path) => 'rm -rf $path').join(' && ')}\'"',
        serialNumber,
      ),
      PushFileCommand(sourcePath: var source, targetPath: var target) =>
        _adbCommandWithSerial("push $source $target", serialNumber),
      SetOnGpsCommand(isOn: var isOn) => _adbCommandWithSerial(
        "shell settings put secure location_mode ${isOn ? 3 : 0}",
        serialNumber,
      ),
      RecoveryCommand() => _adbCommandWithSerial(
        "reboot recovery",
        serialNumber,
      ),

      SetMockLocationPackageCommand(packageName: var packageName) =>
        _adbCommandWithSerial(
          "shell appops set $packageName android:mock_location allow",
          serialNumber,
        ),
      ClearAppsData(packages: var packages) => packages
          .map(
            (package) =>
                _adbCommandWithSerial("shell pm clear $package", serialNumber),
          )
          .join(" && "),
      SetAllowMockLocationCommand(isAllow: var isAllow) =>
        _adbCommandWithSerial(
          "shell settings put secure mock_location ${isAllow ? 1 : 0}",
          serialNumber,
        ),
      SetMockLocationCommand(latitude: var lat, longitude: var lon) =>
        _adbCommandWithSerial(
          """shell am start -a android.intent.action.VIEW -d 'geo:$lat,$lon'""",
          serialNumber,
        ),
      OpenChPlayWithUrlCommand(url: var url) => _adbCommandWithSerial(
        'shell am start -a android.intent.action.VIEW -d "$url"',
        serialNumber,
      ),
      InputTextCommand(text: var text) => _adbCommandWithSerial(
        'shell input text "$text"',
        serialNumber,
      ),
      PullFileCommand(sourcePath: var source, destinationPath: var target) =>
        _adbCommandWithSerial("pull $source $target", serialNumber),
      CustomCommand(command: var cmd) => _adbCommandWithSerial(
        cmd,
        serialNumber,
      ),
      //
      _ => throw UnsupportedError('Unknown command'),
    };
  }

  bool _isConnectionError(String output) {
    return output.contains('cannot resolve host') ||
        output.contains('no such host is known') ||
        output.contains('failed to respond') ||
        output.contains('cannot connect');
  }

  CommandResult _logError(String? serialNumber, String message, String? error) {
    logCubit.log(
      title: "ADB Error",
      message: "$message\n$error",
      type: LogType.ERROR,
    );
    return CommandResult(
      success: false,
      message: message,
      error: error,
      serialNumber: serialNumber,
    );
  }

  CommandResult _logSuccess(String? serialNumber, String message) {
    logCubit.log(title: "ADB Success", message: message);
    return CommandResult(
      success: true,
      message: message,
      serialNumber: serialNumber,
    );
  }

  String _adbCommandWithSerial(String command, String? serialNumber) {
    return serialNumber != null
        ? 'adb -s $serialNumber $command'
        : 'adb $command';
  }

  Future<CommandResult> listDevices() async {
    return await runCommand(command: ListDevicesCommand());
  }

  Future<CommandResult> runShellCommand(
    String command, {
    String? serialNumber,
  }) async {
    return await runCommand(
      command: ShellCommand(command),
      serialNumber: serialNumber,
    );
  }

  Future<List<CommandResult>> runCommandOnMultipleDevices({
    required List<String> deviceSerials,
    required Command command,
  }) async {
    logCubit.log(
      title: "Running on multiple devices",
      message: "$deviceSerials -> $command",
    );

    List<Future<CommandResult>> tasks =
        deviceSerials.map((serial) async {
          return await runCommand(command: command, serialNumber: serial);
        }).toList();

    return await Future.wait(tasks);
  }

  Future<CommandResult> connectOverTcpIp(String serialNumber) async {
    return await runCommand(
      command: ConnectCommand(serialNumber),
      serialNumber: serialNumber,
    );
  }

  Future<CommandResult> disconnectOverTcpIp(String serialNumber) async {
    return await runCommand(
      command: DisconnectCommand(),
      serialNumber: serialNumber,
    );
  }

  Future<CommandResult> openPackage(
    String packageName, {
    String? serialNumber,
  }) async {
    return await runCommand(
      command: OpenPackageCommand(packageName),
      serialNumber: serialNumber,
    );
  }

  Future<CommandResult> closePackage(
    String packageName, {
    String? serialNumber,
  }) async {
    return await runCommand(
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

  Future<String?> _buildAndPushChangeInfoScript({
    required String serialNumber,
    required DeviceInfo deviceInfo,
  }) async {
    logCubit.log(title: "Device Info", message: deviceInfo.toString());
    var newMac = "00:11:22:33:44:${deviceInfo.macSuffix}";
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

  Future<CommandResult> _changeDeviceInfo({
    List<String>? packagesToClear,
    required DeviceInfo deviceInfo,
    required String serialNumber,
  }) async {
    try {
      var changeDeviceInfoScriptPath = await _buildAndPushChangeInfoScript(
        serialNumber: serialNumber,
        deviceInfo: deviceInfo,
      );

      var result = await _shell.run(
        """adb shell su -c "chmod +x $changeDeviceInfoScriptPath && $changeDeviceInfoScriptPath\"""",
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
        if (packagesToClear != null && packagesToClear.isNotEmpty) {
          await runCommand(
            command: ClearAppsData(packages: packagesToClear),
            serialNumber: serialNumber,
          );
        }

        // Delete data of device
        // var deleteDataScriptSourcePath =
        //     "./dependency/scripts/remove_data_script.sh";
        // var deleteDataScriptTargetPath =
        //     "/data/local/tmp/remove_data_script.sh";
        //
        // await _runCommand(
        //   command: PushFileCommand(
        //     deleteDataScriptSourcePath,
        //     deleteDataScriptTargetPath,
        //   ),
        //   serialNumber: serialNumber,
        // );
        //
        // await _shell.run(
        //   """adb shell su -c "chmod +x $deleteDataScriptTargetPath && $deleteDataScriptTargetPath\"""",
        // );

        return await runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
        );
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
    const realSdkVersion = "29"; // Set to your Mi A1’s actual SDK (28 or 29)
    return DeviceInfo(
      model: randomDevice.model,
      brand: randomDevice.brand,
      manufacturer: randomDevice.manufacturer,
      serialNo:
          "${randomDevice.serialNo.split(RegExp(r'\d+'))[0]}${_generateSerialSuffix(6)}",
      device: randomDevice.device,
      productName: randomDevice.productName,
      releaseVersion: randomDevice.releaseVersion,
      sdkVersion: realSdkVersion,
      macSuffix: randomDevice.macSuffix,
      fingerprint: randomDevice.fingerprint,
      androidId: _generateAndroidId(),
    );
  }

  String _generateSerialSuffix(int length) {
    const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String _generateAndroidId() {
    // Android ID is a 16-character hex string
    const chars = '0123456789abcdef';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        16,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
