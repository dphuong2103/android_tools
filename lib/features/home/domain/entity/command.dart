import 'device_info.dart';

sealed class Command {
  const Command();

  @override
  String toString() => runtimeType.toString();
}

class ListDevicesCommand extends Command {}

class ConnectCommand extends Command {
  final String address;

  const ConnectCommand(this.address);

  @override
  String toString() => 'ConnectCommand(address: $address)';
}

class DisconnectCommand extends Command {}

class TcpIpCommand extends Command {
  final int port;

  const TcpIpCommand(this.port);

  @override
  String toString() => 'TcpIpCommand(port: $port)';
}

class KeyCommand extends Command {
  final String key;

  const KeyCommand(this.key);

  @override
  String toString() => 'KeyCommand(key: $key)';
}

class ShellCommand extends Command {
  final String command;

  const ShellCommand(this.command);

  @override
  String toString() => 'ShellCommand(command: $command)';
}

class OpenPackageCommand extends Command {
  final String packageName;

  const OpenPackageCommand(this.packageName);

  @override
  String toString() => 'OpenPackageCommand(packageName: $packageName)';
}

class ClosePackageCommand extends Command {
  final String packageName;

  const ClosePackageCommand(this.packageName);

  @override
  String toString() => 'ClosePackageCommand(packageName: $packageName)';
}

class WithoutShellCommand extends Command {
  final String command;

  const WithoutShellCommand(this.command);

  @override
  String toString() => 'WithoutShellCommand(command: $command)';
}

class TapCommand extends Command {
  final double x, y;

  const TapCommand({required this.x, required this.y});

  @override
  String toString() => 'TapCommand(x: $x, y: $y)';
}

class SwipeCommand extends Command {
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
  String toString() =>
      'SwipeCommand(startX: $startX, startY: $startY, endX: $endX, endY: $endY, duration: $duration)';
}

class InstallApkCommand extends Command {
  final String apkPath;

  const InstallApkCommand(this.apkPath);

  @override
  String toString() => 'InstallApkCommand(apkPath: $apkPath)';
}

class UninstallAppsCommand extends Command {
  final List<String> packages;

  const UninstallAppsCommand(this.packages);

  @override
  String toString() =>
      'UninstallAppCommand(packageName: ${packages.toString()})';
}

class RebootCommand extends Command {}

class RebootBootLoaderCommand extends Command {}

class ChangeTimeZoneCommand extends Command {
  final String timeZone;

  const ChangeTimeZoneCommand({required this.timeZone});

  @override
  String toString() => 'ChangeTimeZoneCommand(timeZone: $timeZone)';
}

class GetTimeZoneCommand extends Command {}

class SetProxyCommand extends Command {
  final String ip;
  final String port;

  const SetProxyCommand({required this.ip, required this.port});

  @override
  String toString() => 'SetProxyCommand(ip: $ip, port: $port)';
}

class RemoveProxyCommand extends Command {}

class VerifyProxyCommand extends Command {}

class GetPackagesCommand extends Command {}

class SetAlwaysOnCommand extends Command {
  final int value;

  const SetAlwaysOnCommand({required this.value});
}

class RecoveryCommand extends Command {
  const RecoveryCommand();
}

class ClearAppsData extends Command {
  final List<String> packages;

  const ClearAppsData({required this.packages});
}

class ChangeRandomDeviceInfoCommand extends Command {
  final List<String>? packagesToClear;

  const ChangeRandomDeviceInfoCommand({this.packagesToClear});
}

class ChangeDeviceInfoCommand extends Command {
  final DeviceInfo deviceInfo;
  final List<String>? packagesToClear;

  const ChangeDeviceInfoCommand({
    required this.deviceInfo,
    this.packagesToClear,
  });
}

class RemoveFilesCommand extends Command {
  final List<String> filePaths;

  const RemoveFilesCommand({required this.filePaths});
}

class PushFileCommand extends Command {
  final String sourcePath;
  final String destinationPath;

  PushFileCommand({required this.sourcePath,required this.destinationPath});
}

class PullFileCommand extends Command {
  final String sourcePath;
  final String destinationPath;

  PullFileCommand({required this.sourcePath, required this.destinationPath});
}

class SetOnGpsCommand extends Command {
  final bool isOn;

  const SetOnGpsCommand({required this.isOn});
}

class SetMockLocationPackageCommand extends Command {
  final String packageName;

  const SetMockLocationPackageCommand({required this.packageName});
}

class SetAllowMockLocationCommand extends Command {
  final bool isAllow;

  const SetAllowMockLocationCommand({required this.isAllow});
}

class SetMockLocationCommand extends Command {
  final double latitude;
  final double longitude;

  const SetMockLocationCommand({
    required this.latitude,
    required this.longitude,
  });
}

class OpenChPlayWithUrlCommand extends Command {
  final String url;

  const OpenChPlayWithUrlCommand({required this.url});
}

class InputTextCommand extends Command {
  final String text;

  const InputTextCommand({required this.text});
}

class CustomCommand extends Command {
  final String command;

  const CustomCommand({required this.command});
}

class RunScriptCommand extends Command {
  final String scriptName;

  const RunScriptCommand({required this.scriptName});
}

class WaitCommand extends Command {
  final int delayInSecond;

  const WaitCommand({required this.delayInSecond});
}

class ChangeDeviceInfoRandomCommand extends Command {
  const ChangeDeviceInfoRandomCommand();
}

class SetUpCommand extends Command {
  const SetUpCommand();
}

class UninstallInitApkCommand extends Command {
  const UninstallInitApkCommand();
}

class BackupCommand extends Command {
  final String backupName;

  const BackupCommand({required this.backupName});
}

class ListBackUpFileCommand extends Command {
  const ListBackUpFileCommand();
}

class RestoreBackupCommand extends Command {
  final String backupName;

  const RestoreBackupCommand({required this.backupName});
}
