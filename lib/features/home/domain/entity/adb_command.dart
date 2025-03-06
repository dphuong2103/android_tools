sealed class AdbCommand {
  const AdbCommand();
}

class ListDevicesCommand extends AdbCommand {}

class ConnectCommand extends AdbCommand {
  final String address;

  const ConnectCommand(this.address);
}

class DisconnectCommand extends AdbCommand {
  const DisconnectCommand();
}

class TcpIpCommand extends AdbCommand {
  final int port;

  const TcpIpCommand(this.port);
}

class KeyCommand extends AdbCommand {
  final String key;

  const KeyCommand(this.key);
}

class ShellCommand extends AdbCommand {
  final String command;

  const ShellCommand(this.command);
}

class OpenPackageCommand extends AdbCommand {
  final String packageName;

  const OpenPackageCommand(this.packageName);
}

class ClosePackageCommand extends AdbCommand {
  final String packageName;

  const ClosePackageCommand(this.packageName);
}

class WithoutShellCommand extends AdbCommand {
  final String command;

  const WithoutShellCommand(this.command);
}

class TapCommand extends AdbCommand {
  final double x, y;

  const TapCommand({required this.x, required this.y});
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
}

class InstallApkCommand extends AdbCommand {
  final String apkPath;

  const InstallApkCommand(this.apkPath);
}

class UninstallAppCommand extends AdbCommand {
  final String packageName;

  const UninstallAppCommand(this.packageName);
}

class RebootCommand extends AdbCommand {
  const RebootCommand();
}

class RebootBootLoaderCommand extends AdbCommand {
  const RebootBootLoaderCommand();
}

class ChangeTimeZoneCommand extends AdbCommand {
  final String timeZone;

  const ChangeTimeZoneCommand({required this.timeZone});
}

class GetTimeZoneCommand extends AdbCommand {
  const GetTimeZoneCommand();
}
