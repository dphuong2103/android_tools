import 'package:android_tools/core/device_list/adb_device.dart';
import 'device_info.dart';

const List<DeviceConnectionStatus> allPhoneConnectedStatuses = [
  DeviceConnectionStatus.booted,
  DeviceConnectionStatus.fastboot,
  DeviceConnectionStatus.recovery,
  DeviceConnectionStatus.twrp,
];

const List<DeviceConnectionStatus> adbConnectedStatuses = [
  DeviceConnectionStatus.booted,
  DeviceConnectionStatus.recovery,
  DeviceConnectionStatus.twrp,
];

sealed class Command {
  final String? description;
  final List<DeviceConnectionStatus>? deviceConnectionStatuses;

  const Command({
    this.deviceConnectionStatuses = const [DeviceConnectionStatus.booted],
    this.description,
  });

  @override
  String toString() => runtimeType.toString();
}

class ListDevicesCommand extends Command {
  const ListDevicesCommand()
      : super(
      deviceConnectionStatuses: null,
      description: "Lists all connected devices"
  );
}

class ConnectCommand extends Command {
  final String address;

  const ConnectCommand(this.address)
      : super(
      deviceConnectionStatuses: null,
      description: "Connects to a device at the specified address"
  );

  @override
  String toString() => 'ConnectCommand(address: $address)';
}

class DisconnectCommand extends Command {
  const DisconnectCommand()
      : super(
      deviceConnectionStatuses: allPhoneConnectedStatuses,
      description: "Disconnects the current device"
  );
}

class TcpIpCommand extends Command {
  final int port;

  const TcpIpCommand(this.port)
      : super(description: "Sets up TCP/IP connection on specified port");

  @override
  String toString() => 'TcpIpCommand(port: $port)';
}

class KeyCommand extends Command {
  final String key;

  const KeyCommand(this.key)
      : super(description: "Sends a key event to the device");

  @override
  String toString() => 'KeyCommand(key: $key)';
}

class ShellCommand extends Command {
  final String command;

  const ShellCommand(this.command)
      : super(description: "Executes a shell command on the device");

  @override
  String toString() => 'ShellCommand(command: $command)';
}

class OpenPackageCommand extends Command {
  final String packageName;

  const OpenPackageCommand(this.packageName)
      : super(description: "Opens a specific package/application");

  @override
  String toString() => 'OpenPackageCommand(packageName: $packageName)';
}

class ClosePackageCommand extends Command {
  final String packageName;

  const ClosePackageCommand(this.packageName)
      : super(description: "Closes a specific package/application");

  @override
  String toString() => 'ClosePackageCommand(packageName: $packageName)';
}

class TapCommand extends Command {
  final double x, y;

  const TapCommand({required this.x, required this.y})
      : super(description: "Performs a tap at specified screen coordinates");

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
  }) : super(description: "Performs a swipe gesture on the screen");

  @override
  String toString() =>
      'SwipeCommand(startX: $startX, startY: $startY, endX: $endX, endY: $endY, duration: $duration)';
}

class InstallApksCommand extends Command {
  final List<String> apkNames;

  const InstallApksCommand(this.apkNames)
      : super(description: "Installs one or more APK files");

  @override
  String toString() => 'InstallApkCommand(apkName: $apkNames)';
}

class UninstallAppsCommand extends Command {
  final List<String> packages;

  const UninstallAppsCommand(this.packages)
      : super(description: "Uninstalls one or more applications");

  @override
  String toString() => 'UninstallAppCommand(packageName: ${packages.toString()})';
}

class RebootCommand extends Command {
  const RebootCommand()
      : super(description: "Reboots the device");
}

class FastbootCommand extends Command {
  const FastbootCommand()
      : super(description: "Reboots device into fastboot mode");
}

class ChangeTimeZoneCommand extends Command {
  final String timeZone;

  const ChangeTimeZoneCommand({required this.timeZone})
      : super(description: "Changes the device timezone");

  @override
  String toString() => 'ChangeTimeZoneCommand(timeZone: $timeZone)';
}

class GetTimeZoneCommand extends Command {
  const GetTimeZoneCommand()
      : super(description: "Retrieves the current device timezone");
}

class SetProxyCommand extends Command {
  final String ip;
  final String port;

  const SetProxyCommand({required this.ip, required this.port})
      : super(description: "Sets up proxy with specified IP and port");

  @override
  String toString() => 'SetProxyCommand(ip: $ip, port: $port)';
}

class RemoveProxyCommand extends Command {
  const RemoveProxyCommand()
      : super(description: "Removes proxy settings");
}

class VerifyProxyCommand extends Command {
  const VerifyProxyCommand()
      : super(description: "Verifies current proxy settings");
}

class SetAlwaysOnCommand extends Command {
  final int value;

  const SetAlwaysOnCommand({required this.value})
      : super(description: "Sets always-on display feature");
}

class RecoveryCommand extends Command {
  const RecoveryCommand()
      : super(
      deviceConnectionStatuses: allPhoneConnectedStatuses,
      description: "Reboots device into recovery mode"
  );
}

class ClearAppsDataCommand extends Command {
  final List<String> packages;

  const ClearAppsDataCommand({required this.packages})
      : super(description: "Clears data for specified applications");
}

class ChangeRandomDeviceInfoCommand extends Command {
  final List<String>? packagesToClear;

  const ChangeRandomDeviceInfoCommand({this.packagesToClear})
      : super(description: "Changes device info with random values");
}

class ChangeDeviceInfoCommand extends Command {
  final DeviceInfo deviceInfo;
  final List<String>? packagesToClear;

  const ChangeDeviceInfoCommand({
    required this.deviceInfo,
    this.packagesToClear,
  }) : super(description: "Changes device info with specific values");
}

class RemoveFilesCommand extends Command {
  final List<String> filePaths;

  const RemoveFilesCommand({required this.filePaths})
      : super(
      deviceConnectionStatuses: adbConnectedStatuses,
      description: "Removes files at specified paths"
  );
}

class PushFileCommand extends Command {
  final String sourcePath;
  final String destinationPath;

  PushFileCommand({required this.sourcePath, required this.destinationPath})
      : super(
      deviceConnectionStatuses: adbConnectedStatuses,
      description: "Pushes file from host to device"
  );
}

class PullFileCommand extends Command {
  final String sourcePath;
  final String destinationPath;

  PullFileCommand({required this.sourcePath, required this.destinationPath})
      : super(
      deviceConnectionStatuses: adbConnectedStatuses,
      description: "Pulls file from device to host"
  );
}

class SetOnGpsCommand extends Command {
  final bool isOn;

  const SetOnGpsCommand({required this.isOn})
      : super(description: "Enables or disables GPS");
}

class OpenChPlayWithUrlCommand extends Command {
  final String url;

  const OpenChPlayWithUrlCommand({required this.url})
      : super(description: "Opens Google Play Store with specific URL");
}

class InputTextCommand extends Command {
  final String text;

  const InputTextCommand({required this.text})
      : super(description: "Inputs text on the device");
}

class CustomAdbCommand extends Command {
  final String command;

  const CustomAdbCommand({required this.command})
      : super(description: "Executes custom ADB command");
}

class CustomCommand extends Command {
  final String command;

  const CustomCommand({required this.command})
      : super(description: "Executes custom command");
}

class RunScriptCommand extends Command {
  final String scriptName;

  const RunScriptCommand({required this.scriptName})
      : super(description: "Runs specified script");
}

class WaitCommand extends Command {
  final int delayInSecond;

  const WaitCommand({required this.delayInSecond})
      : super(
      deviceConnectionStatuses: allPhoneConnectedStatuses,
      description: "Waits for specified number of seconds"
  );
}

class WaitRandomCommand extends Command {
  final int minDelayInSecond;
  final int maxDelayInSecond;

  const WaitRandomCommand({required this.minDelayInSecond, required this.maxDelayInSecond})
      : super(description: "Waits for random duration between min and max seconds");
}

class SetUpCommand extends Command {
  const SetUpCommand()
      : super(description: "Performs initial device setup");
}

class UninstallInitApkCommand extends Command {
  const UninstallInitApkCommand()
      : super(description: "Uninstalls initial APK files");
}

class BackupCommand extends Command {
  final String backupName;
  final List<String>? excludePackages;

  const BackupCommand({required this.backupName, this.excludePackages})
      : super(description: "Creates backup with specified name");
}

class ListBackUpFileCommand extends Command {
  const ListBackUpFileCommand()
      : super(description: "Lists all backup files");
}

class RestoreBackupCommand extends Command {
  final String backupName;

  const RestoreBackupCommand({required this.backupName})
      : super(description: "Restores backup with specified name");
}

class ChangeGeoCommand extends Command {
  final double latitude;
  final double longitude;
  final String timeZone;

  const ChangeGeoCommand({
    required this.latitude,
    required this.longitude,
    required this.timeZone,
  }) : super(description: "Changes geographical location and timezone");
}

class GetPackagesCommand extends Command {
  final bool isUserPackagesOnly;

  const GetPackagesCommand({this.isUserPackagesOnly = false})
      : super(description: "Gets list of installed packages");
}

class ResetPhoneStateCommand extends Command {
  final List<String>? excludeApps;

  const ResetPhoneStateCommand({this.excludeApps})
      : super(description: "Remove all installed apps with optional app exclusions");
}

class PushAndRunShellScriptCommand extends Command {
  final String scriptName;
  final String? parameters;

  PushAndRunShellScriptCommand({required this.scriptName, this.parameters})
      : super(description: "Pushes and runs shell script with optional parameters");
}

class SetBrightnessCommand extends Command {
  final int brightness;

  const SetBrightnessCommand({required this.brightness})
      : super(description: "Sets screen brightness");
}

class SetVolumeCommand extends Command {
  final int volume;

  const SetVolumeCommand({required this.volume})
      : super(description: "Sets device volume");
}

class GetSpoofedDeviceInfoCommand extends Command{
  const GetSpoofedDeviceInfoCommand()
      : super(description: "Retrieves spoofed device information");
}

class GetSpoofedGeoCommand extends Command{
  const GetSpoofedGeoCommand()
      : super(description: "Retrieves spoofed geographical information");
}

class RecordEventsCommand extends Command {
  final String name;

  const RecordEventsCommand({required this.name})
      : super(description: "Records device events (user's action)");
}

class ReplayTraceScriptCommand extends Command{
  final String traceScriptName;

  const ReplayTraceScriptCommand({required this.traceScriptName})
      : super(description: "Replays recorded trace script");
}