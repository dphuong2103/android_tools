import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/features/home/domain/entity/adb_command.dart';
import 'package:android_tools/features/home/domain/entity/adb_device.dart';
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
      ConnectCommand(address: var address) => _withSerial(
        'connect $address',
        serialNumber,
      ),
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
        'install "$path"',
        serialNumber,
      ),
      UninstallAppCommand(packageName: var pkg) => _withSerial(
        'uninstall $pkg',
        serialNumber,
      ),
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
    // setprop persist.sys.timezone "America/Chicago"
      ChangeTimeZoneCommand(timeZone: var timeZone) => _withSerial(
        "shell service call alarm 3 s16 $timeZone",
        serialNumber,
      ),
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
}
