import 'device_info.dart';

sealed class AdbCommand {
  const AdbCommand();

  @override
  String toString() => runtimeType.toString();
}

class ListDevicesCommand extends AdbCommand {}

class ConnectCommand extends AdbCommand {
  final String address;
  const ConnectCommand(this.address);

  @override
  String toString() => 'ConnectCommand(address: $address)';
}

class DisconnectCommand extends AdbCommand {}

class TcpIpCommand extends AdbCommand {
  final int port;
  const TcpIpCommand(this.port);

  @override
  String toString() => 'TcpIpCommand(port: $port)';
}

class KeyCommand extends AdbCommand {
  final String key;
  const KeyCommand(this.key);

  @override
  String toString() => 'KeyCommand(key: $key)';
}

class ShellCommand extends AdbCommand {
  final String command;
  const ShellCommand(this.command);

  @override
  String toString() => 'ShellCommand(command: $command)';
}

class OpenPackageCommand extends AdbCommand {
  final String packageName;
  const OpenPackageCommand(this.packageName);

  @override
  String toString() => 'OpenPackageCommand(packageName: $packageName)';
}

class ClosePackageCommand extends AdbCommand {
  final String packageName;
  const ClosePackageCommand(this.packageName);

  @override
  String toString() => 'ClosePackageCommand(packageName: $packageName)';
}

class WithoutShellCommand extends AdbCommand {
  final String command;
  const WithoutShellCommand(this.command);

  @override
  String toString() => 'WithoutShellCommand(command: $command)';
}

class TapCommand extends AdbCommand {
  final double x, y;
  const TapCommand({required this.x, required this.y});

  @override
  String toString() => 'TapCommand(x: $x, y: $y)';
}

class SwipeCommand extends AdbCommand {
  final double startX, startY, endX, endY;
  final int duration;

  const SwipeCommand({
    required this.startX,
    required this.startY,
    required this.endX,
    required this.endY,
    required this.duration,
  });

  @override
  String toString() => 'SwipeCommand(startX: $startX, startY: $startY, endX: $endX, endY: $endY, duration: $duration)';
}

class InstallApkCommand extends AdbCommand {
  final String apkPath;
  const InstallApkCommand(this.apkPath);

  @override
  String toString() => 'InstallApkCommand(apkPath: $apkPath)';
}

class UninstallAppsCommand extends AdbCommand {
  final List<String> packages;
  const UninstallAppsCommand(this.packages);

  @override
  String toString() => 'UninstallAppCommand(packageName: ${packages.toString()})';
}

class RebootCommand extends AdbCommand {}

class RebootBootLoaderCommand extends AdbCommand {}

class ChangeTimeZoneCommand extends AdbCommand {
  final String timeZone;
  const ChangeTimeZoneCommand({required this.timeZone});

  @override
  String toString() => 'ChangeTimeZoneCommand(timeZone: $timeZone)';
}

class GetTimeZoneCommand extends AdbCommand {}

class SetProxyCommand extends AdbCommand {
  final String ip;
  final String port;

  const SetProxyCommand({required this.ip, required this.port});

  @override
  String toString() => 'SetProxyCommand(ip: $ip, port: $port)';
}

class RemoveProxyCommand extends AdbCommand {

}

class VerifyProxyCommand extends AdbCommand {}

class GetPackagesCommand extends AdbCommand{}

class SetAlwaysOnCommand extends AdbCommand{
  final int value;
  const SetAlwaysOnCommand({required this.value});
}

class RecoveryCommand extends AdbCommand{
  const RecoveryCommand();
}

class ClearAppsData extends AdbCommand{
  final List<String> packages;
  const ClearAppsData({required this.packages});
}


class ChangeDeviceInfoCommand extends AdbCommand {
  final bool useRandom;
  final DeviceInfo? deviceInfo;

  // Random mode: No DeviceInfo required
  ChangeDeviceInfoCommand.random()
      : useRandom = true,
        deviceInfo = null;

  // User-input mode: DeviceInfo required
  ChangeDeviceInfoCommand.userInput({
    required this.deviceInfo,
  }) : useRandom = false;

  // Optional: Factory for runtime validation
  factory ChangeDeviceInfoCommand({
    bool useRandom = true,
    DeviceInfo? deviceInfo,
  }) {
    if (useRandom) {
      return ChangeDeviceInfoCommand.random();
    } else {
      if (deviceInfo == null) {
        throw ArgumentError('DeviceInfo must be provided when useRandom is false');
      }
      return ChangeDeviceInfoCommand.userInput(deviceInfo: deviceInfo);
    }
  }
}