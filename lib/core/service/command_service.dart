import 'dart:io';
import 'dart:math';

import 'package:android_tools/core/constant/time_zone.dart';
import 'package:android_tools/core/device_list/adb_device.dart';
import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/backup_service.dart';
import 'package:android_tools/core/service/event_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/core/util/device_info_util.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/domain/entity/device_info.dart';
import 'package:archive/archive.dart';
import 'package:collection/collection.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:process_run/shell.dart';
import 'package:android_tools/core/logging/log_cubit.dart';
import '../../../../injection_container.dart';
import 'package:path/path.dart' as p;

class CommandResult {
  final String? serialNumber;
  final bool success;
  final String message;
  final String? error;
  dynamic payload;

  CommandResult({
    required this.success,
    required this.message,
    this.error,
    this.serialNumber,
    this.payload,
  });

  @override
  String toString() {
    return success
        ? '✅ [$serialNumber] Success: $message'
        : '❌ [$serialNumber] Error: $error';
  }
}

const changeDeviceBroadcast = "com.midouz.change_phone.SET_SPOOF";
const resetPhoneStateBroadcast = "com.midouz.change_phone.RESET_PHONE_STATE";
const changeGeoBroadcast = "com.midouz.change_phone.SET_GEO";
const changeDevicePackage = "com.midouz.change_phone";
const generalBroadCast = "com.midouz.change_phone.GENERAL_RECEIVER";

class CommandService {
  final LogCubit logCubit = sl();
  final ShellService _shellService = sl();
  final ApkFileService _apkFileService = sl();
  final BackUpService _backUpService = sl();
  final EventService _eventService = sl();

  final twrpPath = p.join(
    Directory.current.path,
    "file",
    "setup",
    "twrp",
    "twrp.img",
  );

  final romPath = p.join(
    Directory.current.path,
    "file",
    "setup",
    "rom",
    "rom.zip",
  );

  final magiskPath = p.join(
    Directory.current.path,
    "file",
    "setup",
    "magisk",
    "magisk.zip",
  );

  Future<CommandResult> runCommand({
    required Shell shell,
    required Command command,
    String? serialNumber,
    int port = 5555,
    bool isLogged = true,
  }) async {
    if (command is ChangeRandomDeviceInfoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      var deviceInfo = generateRandomDeviceInfo();
      return _shellService.returnCommandResult(
        result: await _changeDeviceInfo(
          deviceInfo: deviceInfo,
          serialNumber: serialNumber,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is ChangeDeviceInfoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");

      return _shellService.returnCommandResult(
        result: await _changeDeviceInfo(
          deviceInfo: command.deviceInfo,
          serialNumber: serialNumber,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is ChangeGeoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _changeGeo(
          command: command,
          serialNumber: serialNumber,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is BackupCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _backupPhone(
          command: command,
          serialNumber: serialNumber,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is RestoreBackupCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _restorePhone(
          command: command,
          serialNumber: serialNumber,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is PushAndRunShellScriptCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _pushAndRunShellScript(
          command: command,
          serialNumber: serialNumber,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is WaitCommand) {
      await Future.delayed(Duration(seconds: command.delayInSecond));
      return _shellService.returnCommandResult(
        result: CommandResult(
          success: true,
          message: "Waited for ${command.delayInSecond} seconds",
          serialNumber: serialNumber,
        ),
        serialNumber: serialNumber ?? "",
        isLogged: isLogged,
      );
    }

    if (command is WaitRandomCommand) {
      var random = Random();
      var delayInSecond =
          random.nextInt(command.maxDelayInSecond - command.minDelayInSecond) +
          command.minDelayInSecond;
      await Future.delayed(Duration(seconds: delayInSecond));
      return CommandResult(
        success: true,
        message: "Waited for $delayInSecond seconds",
        serialNumber: serialNumber,
      );
    }

    if (command is GetSpoofedDeviceInfoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _getSpoofedDeviceInfo(
          serialNumber: serialNumber,
          isLogged: isLogged,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is GetSpoofedGeoCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _getSpoofedGeo(
          serialNumber: serialNumber,
          isLogged: isLogged,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is ReplayTraceScriptCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _replayTraceScript(
          command: command,
          serialNumber: serialNumber,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is ZipDirectoryCommand) {
      return _shellService.returnCommandResult(
        result: await _zipDirectory(command: command),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is UnzipCommand) {
      return _shellService.returnCommandResult(
        result: await _unzip(command: command),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is GetProxyCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.returnCommandResult(
        result: await _getProxy(
          serialNumber: serialNumber,
          isLogged: isLogged,
          shell: shell,
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
      );
    }

    if (command is BroadCastCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return runCommand(
        command: CustomAdbCommand(
          command: _buildBroadcastCommand(command: command),
        ),
        serialNumber: serialNumber,
        isLogged: isLogged,
        shell: shell,
      );
    }

    if (command is ShowScreenCommand) {
      if (serialNumber == null) throw Exception("Serial Number is null");
      return _shellService.runScrcpy(serialNumber);
    }

    String fullCommand = _buildCommand(command, serialNumber, port);

    if (isLogged) {
      logCubit.log(
        title: "Execute command",
        message: fullCommand,
        type: LogType.DEBUG,
      );
    }

    return _shellService.runShell(
      serialNumber: serialNumber,
      run: () => shell.run(fullCommand),
      isLogged: isLogged,
    );
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
      InstallApksCommand(apkNames: var apkNames) => apkNames
          .map(
            (apkName) => _adbCommandWithSerial(
              "install \"${_apkFileService.filePath(apkName)}\"",
              serialNumber,
            ),
          )
          .join(Platform.isWindows ? " ; " : " && "),
      UninstallAppsCommand(packages: var packages) => packages
          .map(
            (package) =>
                _adbCommandWithSerial("uninstall $package", serialNumber),
          )
          .join(Platform.isWindows ? " ; " : " && "),
      RebootCommand() => _adbCommandWithSerial("reboot", serialNumber),
      FastbootCommand() => _adbCommandWithSerial(
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
        'shell "su -c \'${filePaths.map((path) => 'rm -rf $path').join(Platform.isWindows ? ' ; ' : ' && ')}\'"',
        serialNumber,
      ),
      PushFileCommand(sourcePath: var source, destinationPath: var target) =>
        _adbCommandWithSerial('push "$source" "$target"', serialNumber),
      SetOnGpsCommand(isOn: var isOn) => _adbCommandWithSerial(
        "shell settings put secure location_mode ${isOn ? 3 : 0}",
        serialNumber,
      ),
      RecoveryCommand() => _adbCommandWithSerial(
        "reboot recovery",
        serialNumber,
      ),
      ClearAppsDataCommand(packages: var packages) => packages
          .map(
            (package) =>
                _adbCommandWithSerial("shell pm clear $package", serialNumber),
          )
          .join(Platform.isWindows ? ' ; ' : ' && '),
      OpenChPlayWithUrlCommand(url: var url) => _adbCommandWithSerial(
        'shell am start -a android.intent.action.VIEW -d "$url"',
        serialNumber,
      ),
      InputTextCommand(text: var text) => _adbCommandWithSerial(
        'shell input text "$text"',
        serialNumber,
      ),
      PullFileCommand(sourcePath: var source, destinationPath: var target) =>
        _adbCommandWithSerial('pull "$source" "$target"', serialNumber),
      ChangeDeviceInfoCommand(deviceInfo: var deviceInfo) =>
        "${_adbCommandWithSerial(_buildChangeDeviceBroadcastCommand(deviceInfo), serialNumber)} ${Platform.isWindows ? ' ; ' : ' && '} ${_buildCommand(ClosePackageCommand(changeDevicePackage), serialNumber, port)} && ${_buildCommand(CustomAdbCommand(command: "shell am start -n $changeDevicePackage/$changeDevicePackage.MainActivity"), serialNumber, port)}",
      CustomAdbCommand(command: var cmd) => _adbCommandWithSerial(
        cmd,
        serialNumber,
      ),
      CustomCommand(command: var cmd) => cmd,
      ChangeGeoCommand(
        latitude: var latitude,
        longitude: var longitude,
        timeZone: var timeZone,
      ) =>
        _adbCommandWithSerial(
          _buildChangeGeoBroadcast(
            latitude: latitude,
            longitude: longitude,
            timeZone: timeZone,
          ),
          serialNumber,
        ),
      SetBrightnessCommand(brightness: var brightness) => _adbCommandWithSerial(
        "shell settings put system screen_brightness $brightness",
        serialNumber,
      ),
      SetVolumeCommand(volume: var volume) => _adbCommandWithSerial(
        "shell media volume --stream 3 --set $volume",
        serialNumber,
      ),
      SystemizeCommand(packages: var packages) => packages
          .map(
            (package) => _adbCommandWithSerial(
              'shell "su -c systemize -a $package"',
              serialNumber,
            ),
          )
          .join(Platform.isWindows ? ' ; ' : ' && '),
      ResetPhoneStateCommand(excludeApps: var excludeApps) =>
        _adbCommandWithSerial(
          'shell am broadcast -a $resetPhoneStateBroadcast -p $changeDevicePackage',
          serialNumber,
        ),
      SetWifiCommand(isOn: var isOn) => _adbCommandWithSerial(
        'shell svc wifi ${isOn ? 'enable' : 'disable'}',
        serialNumber,
      ),
      _ => throw UnsupportedError('Unknown command'),
    };
  }

  String _adbCommandWithSerial(String command, String? serialNumber) {
    return serialNumber != null
        ? 'adb -s $serialNumber $command'
        : 'adb $command';
  }

  Future<CommandResult> runShellCommand(
    String command, {
    required Shell shell,
    String? serialNumber,
    bool isLogged = true,
  }) async {
    return await runCommand(
      command: ShellCommand(command),
      serialNumber: serialNumber,
      shell: shell,
      isLogged: isLogged,
    );
  }

  Future<List<CommandResult>> runCommandOnMultipleDevices({
    required List<String> deviceSerials,
    required Command command,
    required Shell shell,
    isLogged = true,
  }) async {
    if (isLogged) {
      logCubit.log(
        title: "Running on multiple devices",
        message: "$deviceSerials -> $command",
      );
    }

    List<Future<CommandResult>> tasks =
        deviceSerials.map((serial) async {
          return await runCommand(
            command: command,
            serialNumber: serial,
            isLogged: isLogged,
            shell: shell,
          );
        }).toList();

    return await Future.wait(tasks);
  }

  Future<CommandResult> connectOverTcpIp(
    String serialNumber,
    Shell shell,
  ) async {
    return await runCommand(
      command: ConnectCommand(serialNumber),
      serialNumber: serialNumber,
      shell: shell,
    );
  }

  Future<CommandResult> disconnectOverTcpIp(
    String serialNumber,
    Shell shell,
  ) async {
    return await runCommand(
      command: DisconnectCommand(),
      serialNumber: serialNumber,
      shell: shell,
    );
  }

  Future<Either<CommandResult, CommandResult>>
  executeMultipleCommandsOn1Device({
    required List<Future<CommandResult> Function()> tasks,
    required String successMessage,
    required String serialNumber,
  }) async {
    for (var task in tasks) {
      var result = await task();
      if (!result.success) {
        return Left(
          CommandResult(
            success: false,
            message: result.message,
            error: result.error,
            serialNumber: serialNumber,
          ),
        );
      }
    }
    return Right(
      CommandResult(
        success: true,
        message: successMessage,
        serialNumber: serialNumber,
      ),
    );
  }

  Future<CommandResult> flashRom({
    required String serialNumber,
    required Shell shell,
  }) async {
    var results = await executeMultipleCommandsOn1Device(
      tasks: [
        () => _bootTwrp(serialNumber: serialNumber, shell: shell),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: CustomAdbCommand(command: "shell twrp wipe dalvik"),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: CustomAdbCommand(command: "shell twrp wipe data"),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: CustomAdbCommand(command: "shell twrp wipe system"),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: romPath,
            destinationPath: "/sdcard/rom.zip",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell twrp install /sdcard/rom.zip",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(command: "shell rm -rf /sdcard/rom.zip"),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      successMessage: "Rom flash successfully",
      serialNumber: serialNumber,
    );
    if (results.isLeft) {
      return results.left;
    } else {
      return results.right;
    }
  }

  Future<CommandResult> flashMagisk({
    required String serialNumber,
    required Shell shell,
  }) async {
    var results = await executeMultipleCommandsOn1Device(
      tasks: [
        () => _bootTwrp(serialNumber: serialNumber, shell: shell),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: magiskPath,
            destinationPath: "/sdcard/magisk.zip",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell twrp install /sdcard/magisk.zip",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(command: "shell rm -rf /sdcard/magisk.zip"),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => waitForPhoneBoot(serialNumber),
      ],
      successMessage: "Flask magisk successfully",
      serialNumber: serialNumber,
    );

    return results.isLeft ? results.left : results.right;
  }

  Future<CommandResult> waitForTWRP(String deviceSerial) async {
    logCubit.log(title: "Waiting for TWRP...", type: LogType.DEBUG);
    int i = 0;
    while (i <= 100) {
      try {
        // Execute the ADB command to check for TWRP
        ProcessResult result = await Process.run('adb', [
          '-s',
          deviceSerial,
          'shell',
          'ls /sbin',
        ], runInShell: true);

        // Check if 'twrp' appears in the output
        if (result.stdout.toString().contains('twrp')) {
          return CommandResult(
            success: true,
            message: "TWRP detected",
            serialNumber: deviceSerial,
          );
        } else {
          // Get device state
          await Process.run('adb', [
            '-s',
            deviceSerial,
            'get-state',
          ], runInShell: true);
          await Future.delayed(Duration(seconds: 2));
        }
      } catch (e) {
        return CommandResult(
          success: false,
          message: "TWRP not detected",
          error: e.toString(),
          serialNumber: deviceSerial,
        );
      }
      await Future.delayed(Duration(seconds: 2));
      i++;
    }
    return CommandResult(success: false, message: "TWRP not detected");
  }

  Future<CommandResult> waitForFastboot(String deviceSerial) async {
    logCubit.log(title: "Waiting for Fastboot...", type: LogType.DEBUG);
    int i = 0;
    while (i <= 100) {
      try {
        // Execute the Fastboot command to check if the device is connected
        ProcessResult result = await Process.run('fastboot', [
          'devices',
        ], runInShell: true);

        // Check if the device serial appears in the output
        if (result.stdout.toString().contains(deviceSerial)) {
          return CommandResult(
            success: true,
            message: "Fastboot detected",
            serialNumber: deviceSerial,
          );
        }
      } catch (e) {
        logCubit.log(
          title: "Fastboot Error...",
          message: e.toString(),
          type: LogType.DEBUG,
        );
        return CommandResult(
          success: false,
          message: "Fastboot error",
          error: e.toString(),
          serialNumber: deviceSerial,
        );
      }

      await Future.delayed(Duration(seconds: 2));
      i++;
    }
    return CommandResult(
      success: false,
      message: "Fastboot not detected",
      serialNumber: deviceSerial,
    );
  }

  Future<CommandResult> waitForPhoneBoot(String deviceSerial) async {
    logCubit.log(title: "Waiting for phone to boot...", type: LogType.DEBUG);
    int i = 0;
    while (i <= 100) {
      try {
        // Check device state first
        ProcessResult stateResult = await Process.run('adb', [
          '-s',
          deviceSerial,
          'get-state',
        ], runInShell: true);

        // If device is in 'device' state (fully booted)
        if (stateResult.stdout.toString().trim() == 'device') {
          // Additional check to ensure system is ready
          ProcessResult bootResult = await Process.run('adb', [
            '-s',
            deviceSerial,
            'shell',
            'getprop sys.boot_completed',
          ], runInShell: true);

          if (bootResult.stdout.toString().trim() == '1') {
            return CommandResult(
              success: true,
              message: "Phone booted successfully",
              serialNumber: deviceSerial,
            );
          }
        }

        await Future.delayed(Duration(seconds: 2));
      } catch (e) {
        return CommandResult(
          success: false,
          message: "Phone boot error",
          error: e.toString(),
          serialNumber: deviceSerial,
        );
      }
      await Future.delayed(Duration(seconds: 2));
      i++;
    }
    return CommandResult(success: false, message: "Phone boot timeout");
  }

  Future<CommandResult> installInitApks({
    required String serialNumber,
    required Shell shell,
  }) async {
    var results = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: InstallApksCommand(["google_chrome", "device_info"]),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      serialNumber: serialNumber,
      successMessage: "Init apks installed successfully",
    );

    return results.isLeft ? results.left : results.right;
  }

  Future<CommandResult> flashGApp({
    required String serialNumber,
    required Shell shell,
  }) async {
    var results = await executeMultipleCommandsOn1Device(
      tasks: [
        () => _bootTwrp(serialNumber: serialNumber, shell: shell),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: PushFileCommand(
            sourcePath:
                "${Directory.current.path}/file/setup/rom/open_gapp_nano.zip",
            destinationPath: "/sdcard/gapp.zip",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell twrp install /sdcard/gapp.zip",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(command: WaitCommand(delayInSecond: 1), shell: shell),
        () => runCommand(
          command: CustomAdbCommand(command: "shell rm -rf /sdcard/gapp.zip"),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => waitForPhoneBoot(serialNumber),
      ],
      serialNumber: serialNumber,
      successMessage: "Init apks installed successfully",
    );

    return results.isLeft ? results.left : results.right;
  }

  String _formatBroadcastValue(String value) {
    value = value
        .replaceAll('(', '\\(')
        .replaceAll(' ', '\\ ')
        .replaceAll(')', '\\)')
        .replaceAll('/', '\\/')
        .replaceAll(';', '\\;');
    return """\'$value\'""";
  }

  String _buildChangeDeviceBroadcastCommand(DeviceInfo deviceInfo) {
    // Build the command using a StringBuffer for efficiency
    final buffer = StringBuffer(
      'shell am broadcast -a $changeDeviceBroadcast -p $changeDevicePackage',
    );

    // Original required fields
    buffer.write(' --es model ${_formatBroadcastValue(deviceInfo.model)}');
    buffer.write(' --es brand ${_formatBroadcastValue(deviceInfo.brand)}');
    buffer.write(
      ' --es manufacturer ${_formatBroadcastValue(deviceInfo.manufacturer)}',
    );
    buffer.write(' --es serial ${_formatBroadcastValue(deviceInfo.serialNo)}');
    buffer.write(' --es device ${_formatBroadcastValue(deviceInfo.device)}');
    buffer.write(
      ' --es product ${_formatBroadcastValue(deviceInfo.productName)}',
    );
    buffer.write(
      ' --es release ${_formatBroadcastValue(deviceInfo.releaseVersion)}',
    );
    buffer.write(' --es sdk ${_formatBroadcastValue(deviceInfo.sdkVersion)}');
    buffer.write(
      ' --es fingerprint ${_formatBroadcastValue(deviceInfo.fingerprint)}',
    );
    buffer.write(
      ' --es android_id ${_formatBroadcastValue(deviceInfo.androidId)}',
    );
    buffer.write(' --es imei ${_formatBroadcastValue(deviceInfo.imei)}');

    buffer.write(
      ' --es subscriber_id ${_formatBroadcastValue(deviceInfo.subscriberId)}',
    );
    buffer.write(
      ' --es ad_id ${_formatBroadcastValue(deviceInfo.advertisingId)}',
    );

    buffer.write(' --es ssid ${_formatBroadcastValue(deviceInfo.ssid!)}');

    buffer.write(
      ' --es mac_address ${_formatBroadcastValue(deviceInfo.macAddress!)}',
    );

    buffer.write(' --es width ${deviceInfo.width}');
    buffer.write(' --es height ${deviceInfo.height}');

    buffer.write(
      ' --es android_serial ${_formatBroadcastValue(deviceInfo.androidSerial)}',
    );
    buffer.write(
      ' --es phone_number ${_formatBroadcastValue(deviceInfo.phoneNumber)}',
    );
    buffer.write(
      ' --es gl_vendor ${_formatBroadcastValue(deviceInfo.glVendor)}',
    );
    buffer.write(
      ' --es gl_render ${_formatBroadcastValue(deviceInfo.glRender)}',
    );
    buffer.write(
      ' --es hardware ${_formatBroadcastValue(deviceInfo.hardware)}',
    );
    buffer.write(' --es id ${_formatBroadcastValue(deviceInfo.id)}');
    buffer.write(' --es host ${_formatBroadcastValue(deviceInfo.host)}');
    buffer.write(' --es radio ${_formatBroadcastValue(deviceInfo.radio)}');
    buffer.write(
      ' --es bootloader ${_formatBroadcastValue(deviceInfo.bootloader)}',
    );
    buffer.write(' --es display ${_formatBroadcastValue(deviceInfo.display)}');
    buffer.write(' --es board ${_formatBroadcastValue(deviceInfo.board)}');
    buffer.write(
      ' --es codename ${_formatBroadcastValue(deviceInfo.codename)}',
    );
    buffer.write(
      ' --es serial_sim_number ${_formatBroadcastValue(deviceInfo.serialSimNumber)}',
    );
    buffer.write(' --es bssid ${_formatBroadcastValue(deviceInfo.bssid)}');
    buffer.write(
      ' --es operator ${_formatBroadcastValue(deviceInfo.operator)}',
    );
    buffer.write(
      ' --es operator_name ${_formatBroadcastValue(deviceInfo.operatorName)}',
    );
    buffer.write(
      ' --es country_iso ${_formatBroadcastValue(deviceInfo.countryIso)}',
    );
    buffer.write(
      ' --es user_agent ${_formatBroadcastValue(deviceInfo.userAgent)}',
    );
    buffer.write(
      ' --es os_version ${_formatBroadcastValue(deviceInfo.osVersion)}',
    );
    buffer.write(
      ' --es mac_hardware ${_formatBroadcastValue(deviceInfo.macHardware)}',
    );
    buffer.write(' --es wifi_ip ${_formatBroadcastValue(deviceInfo.wifiIp)}');
    buffer.write(
      ' --es version_chrome ${_formatBroadcastValue(deviceInfo.versionChrome)}',
    );

    return buffer.toString();
  }

  String _buildBroadcastCommand({required BroadCastCommand command}) {
    final buffer = StringBuffer(
      'shell am broadcast -a $generalBroadCast -p $changeDevicePackage',
    );
    if (command.type == BroadCastCommandType.RemoveAccounts) {
      buffer.write(' --es type remove_accounts');
    }

    return buffer.toString();
  }

  String _buildChangeGeoBroadcast({
    required double longitude,
    required double latitude,
    required String timeZone,
  }) {
    final buffer = StringBuffer(
      'shell am broadcast -a $changeGeoBroadcast -p $changeDevicePackage',
    );
    buffer.write(' --es longitude "$longitude"');
    buffer.write(' --es latitude "$latitude"');
    buffer.write(' --es time_zone "$timeZone"');
    return buffer.toString();
  }

  Future<CommandResult> _changeDeviceInfo({
    required String serialNumber,
    required DeviceInfo deviceInfo,
    required Shell shell,
  }) async {
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: CustomAdbCommand(
            command: _buildChangeDeviceBroadcastCommand(deviceInfo),
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: ClosePackageCommand(changeDevicePackage),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomCommand(
            command:
                "adb shell am start -n $changeDevicePackage/$changeDevicePackage.MainActivity",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),

        () => runCommand(
          command: WaitCommand(delayInSecond: 3),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      successMessage: "Change device info successfully",
      serialNumber: serialNumber,
    );

    return result.isLeft ? result.left : result.right;
  }

  Future<CommandResult> _changeGeo({
    required String serialNumber,
    required ChangeGeoCommand command,
    required Shell shell,
  }) async {
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: CustomAdbCommand(
            command: _buildChangeGeoBroadcast(
              latitude: command.latitude,
              longitude: command.longitude,
              timeZone: command.timeZone,
            ),
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: ClosePackageCommand(changeDevicePackage),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomCommand(
            command:
                "adb shell am start -n $changeDevicePackage/$changeDevicePackage.MainActivity",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      successMessage: "Change geo info successfully",
      serialNumber: serialNumber,
    );

    return result.isLeft ? result.left : result.right;
  }

  Future<CommandResult> flashTwrp({
    required String serialNumber,
    required Shell shell,
  }) async {
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => waitForFastboot(serialNumber),
        () => runCommand(
          command: CustomCommand(
            command:
                "fastboot -s $serialNumber boot ${Directory.current.path}/file/setup/twrp/twrp.img",
          ),
          shell: shell,
        ),
      ],
      successMessage: "Flash twrp successfully",
      serialNumber: serialNumber,
    );
    return result.isLeft ? result.left : result.right;
  }

  Future<CommandResult> installEdXposed({
    required String serialNumber,
    required Shell shell,
  }) async {
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: PushFileCommand(
            sourcePath: p.join(
              Directory.current.path,
              "file",
              "setup",
              "edxposed",
            ),
            destinationPath: "/sdcard",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: p.join(
              Directory.current.path,
              "file",
              "setup",
              "systemize",
            ),
            destinationPath: "/sdcard",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: p.join(
              Directory.current.path,
              "file",
              "setup",
              "scripts",
              "install_edxposed.sh",
            ),
            destinationPath: "/data/local/tmp/",
          ),
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell chmod +x /data/local/tmp/install_edxposed.sh",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell /data/local/tmp/install_edxposed.sh",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: [
              "/data/local/tmp/install_edxposed.sh",
              "/sdcard/edxposed",
              "/sdcard/systemize",
            ],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: InstallApksCommand(["edxposed-manager"]),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      successMessage: "Install edxposed successfully",
      serialNumber: serialNumber,
    );
    return result.isLeft ? result.left : result.right;
  }

  Future<CommandResult> installSystemize({
    required String serialNumber,
    required Shell shell,
  }) async {
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: PushFileCommand(
            sourcePath: p.join(
              Directory.current.path,
              "file",
              "setup",
              "systemize",
            ),
            destinationPath: "/sdcard",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: p.join(
              Directory.current.path,
              "file",
              "setup",
              "scripts",
              "install_systemize.sh",
            ),
            destinationPath: "/data/local/tmp/",
          ),
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell chmod +x /data/local/tmp/install_systemize.sh",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell /data/local/tmp/install_systemize.sh",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: [
              "/data/local/tmp/install_systemize.sh",
              "/sdcard/systemize",
            ],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      successMessage: "Install systemize successfully",
      serialNumber: serialNumber,
    );
    return result.isLeft ? result.left : result.right;
  }

  Future<DeviceConnectionStatus> checkPhoneStatus(String deviceSerial) async {
    logCubit.log(title: "Checking phone status...", type: LogType.DEBUG);

    try {
      // Check Fastboot status first
      ProcessResult fastbootResult = await Process.run('fastboot', [
        '-s',
        deviceSerial,
        'devices',
      ], runInShell: true);

      if (fastbootResult.stdout.toString().contains(deviceSerial)) {
        logCubit.log(title: "Fastboot mode detected...", type: LogType.DEBUG);
        return DeviceConnectionStatus.fastboot;
      }

      // Check ADB status
      ProcessResult adbDevices = await Process.run('adb', [
        'devices',
      ], runInShell: true);

      if (!adbDevices.stdout.toString().contains(deviceSerial)) {
        logCubit.log(title: "Device not detected...", type: LogType.DEBUG);
        return DeviceConnectionStatus.notDetected;
      }

      // Get device state via ADB
      ProcessResult stateResult = await Process.run('adb', [
        '-s',
        deviceSerial,
        'get-state',
      ], runInShell: true);

      String state = stateResult.stdout.toString().trim();

      switch (state) {
        case 'device':
          // Check if fully booted
          ProcessResult bootResult = await Process.run('adb', [
            '-s',
            deviceSerial,
            'shell',
            'getprop sys.boot_completed',
          ], runInShell: true);

          if (bootResult.stdout.toString().trim() == '1') {
            logCubit.log(title: "Phone fully booted...", type: LogType.DEBUG);
            return DeviceConnectionStatus.booted;
          }
          break;

        case 'recovery':
          // Check for TWRP specifically
          ProcessResult twrpResult = await Process.run('adb', [
            '-s',
            deviceSerial,
            'shell',
            'ls /sbin',
          ], runInShell: true);

          if (twrpResult.stdout.toString().contains('twrp')) {
            logCubit.log(
              title: "TWRP recovery detected...",
              type: LogType.DEBUG,
            );
            return DeviceConnectionStatus.twrp;
          } else {
            logCubit.log(
              title: "Generic recovery detected...",
              type: LogType.DEBUG,
            );
            return DeviceConnectionStatus.recovery;
          }

        case 'sideload':
          logCubit.log(title: "Sideload mode detected...", type: LogType.DEBUG);
          return DeviceConnectionStatus.sideload;

        default:
          logCubit.log(
            title: "Unknown state detected...",
            message: state,
            type: LogType.DEBUG,
          );
          return DeviceConnectionStatus.unknown;
      }
    } catch (e) {
      logCubit.log(
        title: "Status Check Error...",
        message: e.toString(),
        type: LogType.DEBUG,
      );
      return DeviceConnectionStatus.notDetected;
    }

    // Fallback if no specific state is determined
    logCubit.log(title: "Unable to determine status...", type: LogType.DEBUG);
    return DeviceConnectionStatus.notDetected;
  }

  Future<List<AdbDevice>> deviceList({bool isLogged = true}) async {
    Shell shell = sl();
    List<AdbDevice> devices = [];

    // Check ADB devices (includes booted, recovery, side load states)
    final adbOutput = await runCommand(
      command: ListDevicesCommand(),
      isLogged: isLogged,
      shell: shell,
    );
    devices.addAll(await _parseAdbDevices(adbOutput.message));

    // Check Fastboot devices
    final fastbootOutput = await runCommand(
      command: CustomCommand(command: "fastboot devices"),
      isLogged: isLogged,
      shell: shell,
    );
    devices.addAll(_parseFastbootDevices(fastbootOutput.message));

    return devices;
  }

  // Helper function to parse ADB output and determine detailed status
  Future<List<AdbDevice>> _parseAdbDevices(String output) async {
    final devices = <AdbDevice>[];

    for (var line in output.split('\n')) {
      if (line.contains('\t')) {
        final parts = line.trim().split('\t');
        if (parts.length == 2) {
          final serialNumber = parts[0].split(":")[0];
          final state = parts[1].trim();

          DeviceConnectionStatus status;
          switch (state) {
            case 'device':
              // Check if fully booted
              final bootResult = await Process.run('adb', [
                '-s',
                serialNumber,
                'shell',
                'getprop sys.boot_completed',
              ], runInShell: true);
              status =
                  bootResult.stdout.toString().trim() == '1'
                      ? DeviceConnectionStatus.booted
                      : DeviceConnectionStatus.unknown;
              break;

            case 'recovery':
              // Check for TWRP specifically
              final twrpResult = await Process.run('adb', [
                '-s',
                serialNumber,
                'shell',
                'ls /sbin',
              ], runInShell: true);
              status =
                  twrpResult.stdout.toString().contains('twrp')
                      ? DeviceConnectionStatus.twrp
                      : DeviceConnectionStatus.recovery;
              break;

            case 'sideload':
              status = DeviceConnectionStatus.sideload;
              break;

            case 'unauthorized':
              status = DeviceConnectionStatus.notDetected;
              break;

            default:
              status = DeviceConnectionStatus.unknown;
              logCubit.log(
                title: "Unknown ADB state",
                message: "Serial: $serialNumber, State: $state",
                type: LogType.DEBUG,
              );
          }

          devices.add(AdbDevice(serialNumber: serialNumber, status: status));
        }
      }
    }
    return devices;
  }

  // Helper function to parse Fastboot output
  List<AdbDevice> _parseFastbootDevices(String output) {
    final devices = <AdbDevice>[];

    for (var line in output.split('\n')) {
      if (line.trim().isNotEmpty && line.contains('\t')) {
        final parts = line.trim().split('\t');
        if (parts.isNotEmpty) {
          final serialNumber = parts[0].split(":")[0];
          devices.add(
            AdbDevice(
              serialNumber: serialNumber,
              status: DeviceConnectionStatus.fastboot,
            ),
          );
        }
      }
    }
    return devices;
  }

  Future<CommandResult> _bootTwrp({
    required String serialNumber,
    required Shell shell,
  }) async {
    var phoneStatus = await checkPhoneStatus(serialNumber);
    switch (phoneStatus) {
      case DeviceConnectionStatus.booted:
      case DeviceConnectionStatus.sideload:
        var result = await executeMultipleCommandsOn1Device(
          tasks: [
            () => runCommand(
              command: FastbootCommand(),
              serialNumber: serialNumber,
              shell: shell,
            ),
            () => waitForFastboot(serialNumber),
            () => runCommand(
              command: CustomCommand(
                command: 'fastboot -s $serialNumber boot "$twrpPath"',
              ),
              shell: shell,
            ),
            () => waitForTWRP(serialNumber),
          ],
          successMessage: "Phone boot to twrp",
          serialNumber: serialNumber,
        );
        return result.isLeft ? result.left : result.right;
      case DeviceConnectionStatus.fastboot:
        var result = await executeMultipleCommandsOn1Device(
          tasks: [
            () => runCommand(
              command: CustomCommand(
                command: 'fastboot -s $serialNumber boot "$twrpPath"',
              ),
              shell: shell,
            ),
            () => waitForTWRP(serialNumber),
          ],
          successMessage: "Phone boot to twrp",
          serialNumber: serialNumber,
        );
        return result.isLeft ? result.left : result.right;

      case DeviceConnectionStatus.notDetected:
      case DeviceConnectionStatus.unknown:
        return CommandResult(
          success: false,
          message: "Phone status: ${phoneStatus.toString()}",
          serialNumber: serialNumber,
        );
      case DeviceConnectionStatus.twrp:
      case DeviceConnectionStatus.recovery:
        return CommandResult(
          success: true,
          message: "Phone already in twrp",
          serialNumber: serialNumber,
        );
    }
  }

  Future<CommandResult> _backupPhone({
    required String serialNumber,
    required BackupCommand command,
    required Shell shell,
  }) async {
    var excludePackages = command.excludePackages ?? [];
    var backupName = command.backupName;
    excludePackages.addAll([
      "org.meowcat.edxposed.manager",
      "com.midouz.change_phone",
      "com.topjohnwu.magisk",
      "com.midouz.change_phone.apk",
      "com.google.android.contactkeys",
      "com.google.android.safetycore.apk",
      "com.google.ar.core",
    ]);
    var joinedExcludePackages = excludePackages.join(" ");
    var tempPhoneBackupDir = _backUpService.getSpecificTempPhoneBackupPath(
      backupName: backupName,
    );
    var deviceLocalBackupDir = await _backUpService.getDeviceLocalBackupDir(
      serialNumber: serialNumber,
    );
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: [
              _backUpService.getPhoneBackupScriptPath(),
              "/sdcard/backup/",
            ],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell rm -rf ${_backUpService.phoneScriptsDir}",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell mkdir -p ${_backUpService.phoneScriptsDir}",
          ),
          shell: shell,
        ),
        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: [
              _backUpService.getPhoneBackupScriptPath(),
              tempPhoneBackupDir,
            ],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: _backUpService.backupScriptPath,
            destinationPath: _backUpService.getPhoneBackupScriptPath(),
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command:
                "shell chmod +x ${_backUpService.getPhoneBackupScriptPath()}",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command:
                'shell "su -c\ ${_backUpService.getPhoneBackupScriptPath()} $tempPhoneBackupDir $joinedExcludePackages"',
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: PullFileCommand(
            sourcePath: tempPhoneBackupDir,
            destinationPath: deviceLocalBackupDir.path,
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),

        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: [
              _backUpService.getPhoneBackupScriptPath(),
              tempPhoneBackupDir,
            ],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),

        () => runCommand(
          command: ZipDirectoryCommand(
            zipFilePath: p.join(deviceLocalBackupDir.path, "$backupName.zip"),
            folderPath: p.join(deviceLocalBackupDir.path, backupName),
          ),
          shell: shell,
        ),

        () async {
          try {
            Directory dir = Directory(
              p.join(deviceLocalBackupDir.path, backupName),
            );
            if (!await dir.exists()) {
              return CommandResult(success: false, message: "Folder not found");
            }
            await dir.delete(recursive: true);
            return CommandResult(
              success: true,
              message: "Delete folder successfully",
            );
          } catch (e) {
            CommandResult(
              success: false,
              message: "Error deleting folder",
              error: e.toString(),
            );
          }
          return CommandResult(
            success: true,
            message: "Delete folder successfully",
          );
        },
      ],
      successMessage: "Backup successfully",
      serialNumber: serialNumber,
    );

    if (result.isLeft) {
      return result.left;
    } else {
      return result.right;
    }
  }

  Future<CommandResult> _restorePhone({
    required RestoreBackupCommand command,
    required String serialNumber,
    required Shell shell,
  }) async {
    var backupName = command.backupName;
    var backupFilePath = p.join(
      (await _backUpService.getDeviceLocalBackupDir(
        serialNumber: serialNumber,
      )).path,
      "$backupName.zip",
    );
    File backupFile = File(backupFilePath);

    if (!await backupFile.exists()) {
      return CommandResult(success: false, message: "Backup file not found");
    }

    var tempPhoneBackupPath = _backUpService.getSpecificTempPhoneBackupPath(
      backupName: backupName,
    );

    var deviceBackupDir = await _backUpService.getDeviceLocalBackupDir(
      serialNumber: serialNumber,
    );

    var localBackupDir = p.join(deviceBackupDir.path, backupName);

    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: UnzipCommand(
            zipFilePath: backupFilePath,
            destinationPath: p.join(deviceBackupDir.path, backupName),
          ),
          shell: shell,
        ),
        () => runCommand(
          command: ResetPhoneStateCommand(),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command: "shell mkdir -p ${_backUpService.phoneScriptsDir}",
          ),
          shell: shell,
        ),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: localBackupDir,
            destinationPath: _backUpService.tempPhoneBackupDirPath,
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: PushFileCommand(
            sourcePath: _backUpService.restoreScriptPath,
            destinationPath: _backUpService.getPhoneRestoreScriptPath(),
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command:
                "shell chmod +x ${_backUpService.getPhoneRestoreScriptPath()}",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command:
                'shell su -c ${_backUpService.getPhoneRestoreScriptPath()} $tempPhoneBackupPath',
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: [
              _backUpService.getPhoneRestoreScriptPath(),
              tempPhoneBackupPath,
            ],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: ClosePackageCommand(changeDevicePackage),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomCommand(
            command:
                "adb shell am start -n $changeDevicePackage/$changeDevicePackage.MainActivity",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () async {
          try {
            Directory dir = Directory(localBackupDir);
            if (!await dir.exists()) {
              return CommandResult(success: false, message: "Folder not found");
            }
            await dir.delete(recursive: true);
            return CommandResult(
              success: true,
              message: "Delete folder successfully",
            );
          } catch (e) {
            return CommandResult(
              success: false,
              message: "Error deleting folder",
              error: e.toString(),
            );
          }
        },
      ],
      successMessage: "Restore successfully",
      serialNumber: serialNumber,
    );
    return result.isLeft ? result.left : result.right;
  }

  Future<List<String>> _getDevicePackages({
    required String serialNumber,
    required GetPackagesCommand command,
    required Shell shell,
  }) async {
    bool isUserPackagesOnly = command.isUserPackagesOnly;
    final output = await runCommand(
      command: CustomAdbCommand(
        command: "shell pm list packages${isUserPackagesOnly ? " -3" : ""}",
      ),
      serialNumber: serialNumber,
      shell: shell,
    );
    return output.message
        .split('\n') // Split by newline
        .map((line) => line.trim()) // Trim whitespace
        .where((line) => line.startsWith('package:')) // Filter valid lines
        .map(
          (line) => line.replaceFirst('package:', ''),
        ) // Remove 'package:' prefix
        .toList(); // Convert to list
  }

  Future<CommandResult> _pushAndRunShellScript({
    required PushAndRunShellScriptCommand command,
    required String serialNumber,
    required Shell shell,
  }) async {
    var scriptName = "${command.scriptName}.sh";
    var parameters = command.parameters?.join(" ");
    File script = File(
      p.join(Directory.current.path, "dependency", "scripts", scriptName),
    );
    if (!(await script.exists())) {
      return CommandResult(
        success: false,
        message: "Script $scriptName not found",
      );
    }
    var result = await executeMultipleCommandsOn1Device(
      tasks: [
        () => runCommand(
          command: PushFileCommand(
            sourcePath: script.path,
            destinationPath: "${_backUpService.phoneScriptsDir}/$scriptName",
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command:
                "shell chmod +x ${_backUpService.phoneScriptsDir}/$scriptName",
          ),
          shell: shell,
        ),
        () => runCommand(
          command: CustomAdbCommand(
            command:
                'shell su -c ${_backUpService.phoneScriptsDir}/$scriptName${parameters != null ? " $parameters" : ""}',
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
        () => runCommand(
          command: RemoveFilesCommand(
            filePaths: ["${_backUpService.phoneScriptsDir}/$scriptName"],
          ),
          serialNumber: serialNumber,
          shell: shell,
        ),
      ],
      successMessage: "Run script successfully",
      serialNumber: serialNumber,
    );

    return result.isLeft ? result.left : result.right;
  }

  Future<CommandResult> _getSpoofedDeviceInfo({
    required String serialNumber,
    required Shell shell,
    bool isLogged = true,
  }) async {
    var phoneSpoofedDeviceInfoPath =
        "/data/local/tmp/spoof/spoofed_device_info.properties";
    var result = await runCommand(
      command: CustomAdbCommand(
        command: "shell cat $phoneSpoofedDeviceInfoPath",
      ),
      isLogged: isLogged,
      shell: shell,
    );

    if (!result.success) {
      return result;
    }

    return CommandResult(
      success: true,
      message: result.message,
      serialNumber: serialNumber,
      payload: _parseDeviceInfoFromAdbOutput(result.message),
    );
  }

  Future<CommandResult> _getSpoofedGeo({
    required String serialNumber,
    required Shell shell,
    isLogged = true,
  }) async {
    var phoneSpoofedDeviceInfoPath =
        "/data/local/tmp/spoof/spoofed_geo.properties";
    var result = await runCommand(
      command: CustomAdbCommand(
        command: "shell cat $phoneSpoofedDeviceInfoPath",
      ),
      isLogged: isLogged,
      shell: shell,
    );
    if (!result.success) {
      return result;
    }

    return CommandResult(
      success: true,
      message: result.message,
      serialNumber: serialNumber,
      payload: _parseGeoFromAdbOutput(result.message),
    );
  }

  DeviceInfo _parseDeviceInfoFromAdbOutput(String adbOutput) {
    // Split the output into lines and filter out comments and empty lines
    final lines =
        adbOutput
            .split('\n')
            .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
            .toList();

    // Create a map from the key-value pairs
    final properties = Map.fromEntries(
      lines.map((line) {
        final parts = line.split('=');
        if (parts.length == 2) {
          return MapEntry(parts[0].trim(), parts[1].trim());
        }
        return null;
      }).whereType<MapEntry<String, String>>(),
    );

    // Map the properties to DeviceInfo
    return DeviceInfo(
      model: properties['MODEL'] ?? '',
      brand: properties['BRAND'] ?? '',
      manufacturer: properties['MANUFACTURER'] ?? '',
      serialNo: properties['SERIAL'] ?? '',
      device: properties['DEVICE'] ?? '',
      productName: properties['PRODUCT'] ?? '',
      releaseVersion: properties['RELEASE'] ?? '',
      sdkVersion: properties['SDK'] ?? '',
      fingerprint: properties['FINGERPRINT'] ?? '',
      androidId: properties['ANDROID_ID'] ?? '',
      imei: properties['IMEI'] ?? '',
      advertisingId: properties['AD_ID'] ?? '',
      ssid: properties['WIFI_NAME'] ?? '',
      macAddress: properties['MAC_ADDRESS'] ?? '',
      height: int.tryParse(properties['HEIGHT'] ?? ''),
      width: int.tryParse(properties['WIDTH'] ?? ''),
      androidSerial: properties['ANDROID_SERIAL'] ?? '',
      phoneNumber: properties['PHONE_NUMBER'] ?? '',
      glVendor: properties['GL_VENDOR'] ?? '',
      glRender: properties['GL_RENDER'] ?? '',
      hardware: properties['HARDWARE'] ?? '',
      id: properties['ID'] ?? '',
      host: properties['HOST'] ?? '',
      radio: properties['RADIO'] ?? '',
      bootloader: properties['BOOTLOADER'] ?? '',
      display: properties['DISPLAY'] ?? '',
      board: properties['BOARD'] ?? '',
      codename: properties['CODENAME'] ?? '',
      subscriberId: properties['SUBSCRIBER_ID'] ?? '',
      serialSimNumber: properties['SERIAL_SIM_NUMBER'] ?? '',
      bssid: properties['BSSID'] ?? '',
      operator: properties['OPERATOR'] ?? '',
      operatorName: properties['OPERATOR_NAME'] ?? '',
      countryIso: properties['COUNTRY_ISO'] ?? '',
      userAgent: properties['USER_AGENT'] ?? '',
      osVersion: properties['OS_VERSION'] ?? '',
      macHardware: properties['MAC_HARDWARE'] ?? '',
      wifiIp: properties['WIFI_IP'] ?? '',
      versionChrome: properties['VERSION_CHROME'] ?? '',
    );
  }

  String? _parseGeoFromAdbOutput(String adbOutput) {
    final lines =
        adbOutput
            .split('\n')
            .where((line) => line.trim().isNotEmpty && !line.startsWith('#'))
            .toList();

    final properties = Map.fromEntries(
      lines.map((line) {
        final parts = line.split('=');
        if (parts.length == 2) {
          return MapEntry(parts[0].trim(), parts[1].trim());
        }
        return null;
      }).whereType<MapEntry<String, String>>(),
    );
    var timezoneName = properties["time_zone"];

    if (timezoneName == null) return null;
    return timezoneMap.keys.firstWhereOrNull(
      (k) => timezoneMap[k] == timezoneName,
    );
  }

  Future<CommandResult> _replayTraceScript({
    required String serialNumber,
    required ReplayTraceScriptCommand command,
  }) {
    return _eventService.replayEvents(
      shell: Shell(),
      serialNumber: serialNumber,
      replayScriptName: command.traceScriptName,
    );
  }

  Future<CommandResult> _zipDirectory({
    required ZipDirectoryCommand command,
  }) async {
    try {
      final sourceDirPath = command.folderPath;
      debugPrint("Attempting to zip directory: $sourceDirPath");
      final sourceDir = Directory(sourceDirPath);

      if (!await sourceDir.exists()) {
        return CommandResult(
          success: false,
          message: "Source directory $sourceDirPath not found",
        );
      }

      final zipFilePath = command.zipFilePath;
      debugPrint("Output ZIP file path: $zipFilePath");
      final zipFile = File(zipFilePath);

      final encoder = ZipEncoder();
      final archive = Archive();

      debugPrint("Listing files in $sourceDirPath...");
      final files = sourceDir.listSync(recursive: true);
      for (var entity in files) {
        debugPrint("Processing entity: ${entity.path}");
        if (entity is File) {
          try {
            debugPrint("Reading file: ${entity.path}");
            final fileBytes = await entity.readAsBytes();
            final relativePath = entity.path
                .replaceFirst(sourceDir.path, '')
                .replaceAll('\\', '/')
                .substring(1);
            archive.addFile(
              ArchiveFile(relativePath, fileBytes.length, fileBytes),
            );
          } catch (fileError) {
            return CommandResult(
              success: false,
              message: "Failed to process file ${entity.path}: $fileError",
            );
          }
        }
      }

      final zipBytes = encoder.encode(archive);
      await zipFile.writeAsBytes(zipBytes);
      return CommandResult(
        success: true,
        message: "Zipped directory successfully",
      );
    } catch (e) {
      return CommandResult(
        success: false,
        message: "Error zipping directory: $e",
      );
    }
  }

  Future<CommandResult> _unzip({required UnzipCommand command}) async {
    try {
      final zipFilePath = command.zipFilePath;
      debugPrint("Attempting to unzip file: $zipFilePath");
      final zipFile = File(zipFilePath);

      if (!await zipFile.exists()) {
        return CommandResult(
          success: false,
          message: "ZIP file $zipFilePath not found",
        );
      }

      final destinationPath = command.destinationPath;
      debugPrint("Extracting to: $destinationPath");
      final destinationDir = Directory(destinationPath);

      // Create destination directory if it doesn’t exist
      if (!await destinationDir.exists()) {
        await destinationDir.create(recursive: true);
        debugPrint("Created destination directory: $destinationPath");
      }

      // Read the ZIP file
      debugPrint("Reading ZIP file...");
      final zipBytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      // Extract each file from the archive
      debugPrint("Extracting files...");
      for (final file in archive) {
        final filePath = '$destinationPath\\${file.name}';
        debugPrint("Processing: $filePath");

        if (file.isFile) {
          try {
            final data = file.content as List<int>;
            final outputFile = File(filePath);
            // Ensure the parent directory exists
            await outputFile.parent.create(recursive: true);
            await outputFile.writeAsBytes(data);
            debugPrint("Extracted file: $filePath");
          } catch (fileError) {
            return CommandResult(
              success: false,
              message: "Failed to extract file $filePath: $fileError",
            );
          }
        } else {
          // Handle directories
          final dir = Directory(filePath);
          if (!await dir.exists()) {
            await dir.create(recursive: true);
          }
        }
      }

      return CommandResult(
        success: true,
        message: "Unzipped file successfully",
      );
    } catch (e) {
      return CommandResult(success: false, message: "Error unzipping file: $e");
    }
  }

  Future<CommandResult> _getProxy({
    required String serialNumber,
    required Shell shell,
    bool isLogged = true,
  }) async {
    var result = await runCommand(
      command: CustomAdbCommand(
        command: "shell settings get global http_proxy",
      ),
      isLogged: isLogged,
      shell: shell,
    );
    if (!result.success) {
      return result;
    }

    return CommandResult(
      success: true,
      message: result.message,
      serialNumber: serialNumber,
      payload: result.message,
    );
  }
}
