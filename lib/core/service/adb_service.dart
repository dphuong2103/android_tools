import 'package:android_tools/features/home/domain/entity/adb_device.dart';
import 'package:process_run/shell.dart';

/// 🔥 Enum for command types
enum CommandType {
  listDevices,
  connect,
  disconnect,
  tcpip,
  shell,
  openPackage,
  closePackage,
  withoutShell
}

class AdbResult {
  final String? ip;
  final bool success;
  final String message;
  final String? error;

  AdbResult({
    required this.success,
    required this.message,
    this.error,
    this.ip,
  });

  @override
  String toString() {
    return success ? '✅ [$ip] Success: $message' : '❌ [$ip] Error: $error';
  }
}

class AdbService {
  final _shell = Shell();

  /// Add serial number for specific device
  String _withSerial(String command, {String? serialNumber}) {
    return serialNumber != null ? 'adb -s $serialNumber $command' : 'adb $command';
  }

  /// Generalized command runner
  Future<AdbResult> _runCommand(
      CommandType type, {
        String? command,
        String? serialNumber,
        String? ip,
        int port = 5555,
      }) async {
    String fullCommand = '';

    switch (type) {
      case CommandType.listDevices:
        fullCommand = 'adb devices';
        break;
      case CommandType.connect:
        fullCommand = 'adb connect $ip';
        break;
      case CommandType.disconnect:
        fullCommand = 'adb disconnect $ip';
        break;
      case CommandType.tcpip:
        fullCommand = 'adb tcpip $port';
        break;
      case CommandType.shell:
        fullCommand = _withSerial('shell $command', serialNumber: serialNumber);
        break;
      case CommandType.openPackage:
        fullCommand = _withSerial('shell am start -n $command', serialNumber: serialNumber);
        break;
      case CommandType.closePackage:
        fullCommand = _withSerial('shell am force-stop $command', serialNumber: serialNumber);
        break;
      case CommandType.withoutShell:
        fullCommand = _withSerial(command ?? "", serialNumber: serialNumber);
    }

    try {
      var result = await _shell.run(fullCommand);
      String output = result.outText.toLowerCase();

      // Handle connection-related errors
      if (output.contains('cannot resolve host') ||
          output.contains('no such host is known') ||
          output.contains('failed to respond') ||
          output.contains('cannot connect')) {
        return AdbResult(
          success: false,
          message: result.outText,
          error: result.errText.isNotEmpty ? result.errText : 'Connection error detected.',
          ip: ip,
        );
      }

      if (result.first.exitCode == 0) {
        return AdbResult(success: true, message: result.outText, ip: ip);
      } else {
        return AdbResult(
          success: false,
          message: result.outText,
          error: result.errText,
          ip: ip,
        );
      }
    } catch (e) {
      return AdbResult(success: false, message: '', error: e.toString(), ip: ip);
    }
  }

  /// 📱 List all connected devices
  Future<AdbResult> listDevices() async {
    return await _runCommand(CommandType.listDevices);
  }

  /// 🔌 Connect a device over TCP/IP using its IP
  Future<AdbResult> connectOverTcpIp(String ip) async {
    return await _runCommand(CommandType.connect, ip: ip);
  }

  /// 🔌 Disconnect a device over TCP/IP using its IP
  Future<AdbResult> disconnectOverTcpIp(String ip) async {
    return await _runCommand(CommandType.disconnect, ip: ip);
  }

  /// 📡 Restart ADB in TCP/IP mode (default port is 5555)
  Future<AdbResult> restartInTcpIpMode(int port) async {
    return await _runCommand(CommandType.tcpip, port: port);
  }

  /// 🖥️ Run shell command on device
  Future<AdbResult> runShellCommand(
      String command, {
        String? serialNumber,
        String? ip,
      }) async {
    return await _runCommand(
      CommandType.shell,
      command: command,
      serialNumber: serialNumber,
      ip: ip,
    );
  }

  /// 🏃 Run command on multiple devices concurrently
  Future<List<AdbResult>> runCommandOnMultipleDevices(
      List<String> deviceSerials,
      String command,
  {CommandType commandType = CommandType.shell}
      ) async {
    List<Future<AdbResult>> tasks = deviceSerials.map((serial) async {
      String sanitizedSerial = serial.contains(':') ? serial.split(':').first : serial;
      return await _runCommand(
        commandType,
        command: command,
        serialNumber: serial,
        ip: sanitizedSerial,
      );
    }).toList();

    return await Future.wait(tasks);
  }

  /// 📦 Open an app package on a specific device
  Future<AdbResult> openPackage(
      String packageName,
      String activityName, {
        String? serialNumber,
        String? ip,
      }) async {
    String command = '$packageName/$activityName';
    return await _runCommand(
      CommandType.openPackage,
      command: command,
      serialNumber: serialNumber,
      ip: ip,
    );
  }

  /// ❌ Close an app package on a specific device
  Future<AdbResult> closePackage(
      String packageName, {
        String? serialNumber,
        String? ip,
      }) async {
    return await _runCommand(
      CommandType.closePackage,
      command: packageName,
      serialNumber: serialNumber,
      ip: ip,
    );
  }

  /// 📋 List devices with their statuses
  Future<List<AdbDevice>> deviceList() async {
    List<AdbDevice> list = [];
    final adbOutput = await listDevices();

    final lines = adbOutput.message.split('\n');

    for (var line in lines) {
      if (line.contains('\t')) {
        final parts = line.split('\t');
        if (parts.length == 2) {
          final serialNumber = parts[0].split(':').first;
          final status = parts[1];
          AdbDevice device = AdbDevice(
            serialNumber: serialNumber,
            status: status == "device"
                ? AdbDeviceStatus.connected
                : AdbDeviceStatus.unAuthorized,
          );
          list.add(device);
        }
      }
    }
    return list;
  }
}
