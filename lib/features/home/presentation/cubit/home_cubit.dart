import 'dart:io';

import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/database_service.dart';
import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/core/service/text_file_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:bloc/bloc.dart';
import 'package:either_dart/either.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:collection/collection.dart';
import '../../../../injection_container.dart';
import '../../domain/entity/adb_device.dart';

part 'home_cubit.freezed.dart';

part 'home_state.dart';

const customCommand = "CustomCommand";
const customAdbCommand = "CustomAdbCommand";
const rebootCommand = "Reboot";
const keyCodeCommand = "KEYCODE";
const openAppCommand = "OpenApp";
const closeAppCommand = "CloseApp";
const runScriptCommand = "RunScript";
const tapCommand = "Tap";
const waitCommand = "Wait";
const swipeCommand = "Swipe";
const installApkCommand = "InstallApk";
const uninstallAppsCommand = "UninstallApps";
const fastbootCommand = "Fastboot";
const changeTimezoneCommand = "ChangeTimeZone";
const changeLocationCommand = "ChangeLocation";
const setProxyCommand = "SetProxy";
const verifyProxyCommand = "VerifyProxy";
const removeProxyCommand = "RemoveProxy";
const listPackagesCommand = "ListPackages";
const setAlwaysOnCommand = "SetAlwaysOn";
const recoveryCommand = "Recovery";
const changeDeviceInfoRandomCommand = "ChangeDeviceInfoRandom";
const setOnGpsCommand = "SetOnGpsCommand";
const setMockGpsPackageCommand = "SetMockGpsPackage";
const setAllowMockLocationCommand = "SetAllowMockLocation";
const setMockLocationCommand = "SetMockLocation";
const defaultLocationMockPackage = "com.lexa.fakegps";
const setUpCommand = "SetUp";
const uninstallInitApkCommand = "UninstallInitApk";
const removeAppsDataCommand = "RemoveAppsData";
const openChPlayWithUrlCommand = "OpenChPlayWithUrl";
const inputTextCommand = "InputText";
const pullCommand = "Pull";

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  final List<String> commandList = [
    customAdbCommand,
    rebootCommand,
    keyCodeCommand,
    openAppCommand,
    closeAppCommand,
    runScriptCommand,
    tapCommand,
    waitCommand,
    installApkCommand,
    uninstallAppsCommand,
    fastbootCommand,
    changeTimezoneCommand,
    changeLocationCommand,
    setProxyCommand,
    verifyProxyCommand,
    removeProxyCommand,
    listPackagesCommand,
    setAlwaysOnCommand,
    recoveryCommand,
    changeDeviceInfoRandomCommand,
    setOnGpsCommand,
    setMockGpsPackageCommand,
    setAllowMockLocationCommand,
    setMockLocationCommand,
    setUpCommand,
    uninstallInitApkCommand,
    removeAppsDataCommand,
    inputTextCommand,
    openChPlayWithUrlCommand,
    pullCommand,
  ];

  final CommandService commandService = sl();
  final DatabaseService dbService = sl();
  final ShellService shellService = sl();
  final TextFileService textFileService = sl();
  final LogCubit logCubit = sl();
  final ApkFileService apkFileService = sl();
  final DirectoryService _directoryService = sl();

  Future<void> init() async {
    await getDevices();
  }

  Map<String, DeviceConnectionStatus> deviceListStatusMap(
    List<AdbDevice> maps,
  ) {
    return Map.fromEntries(maps.map((e) => MapEntry(e.serialNumber, e.status)));
  }

  Future<void> getDevices() async {
    // Fetch device IPs from the database (main list)
    final Database db = await dbService.database;
    final result = await db.query(TableName.devices);
    final deviceList = result.map((data) => Device.fromJson(data)).toList();

    var adbDeviceList = await commandService.deviceList();
    Map<String, DeviceConnectionStatus> deviceStatusMap = deviceListStatusMap(
      adbDeviceList,
    );

    final updatedDevices =
        deviceList.map((device) {
          return device.copyWith(
            status:
                deviceStatusMap[device.ip] ??
                DeviceConnectionStatus.notDetected
          );
        }).toList();

    // Emit the updated device list with their statuses
    emit(state.copyWith(devices: updatedDevices));
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true));
    var deviceList = state.devices;
    if (deviceList.isEmpty) {
      return;
    }

    var adbDeviceList = await commandService.deviceList();
    Map<String, DeviceConnectionStatus> deviceStatusMap = deviceListStatusMap(
      adbDeviceList,
    );

    final updatedDevices =
        deviceList.map((device) {
          return device.copyWith(
            status:
            deviceStatusMap[device.ip] ??
                DeviceConnectionStatus.notDetected
          );
        }).toList();

    emit(state.copyWith(isRefreshing: false, devices: updatedDevices));
  }

  Future<bool> deviceExistsBySerial(String serialNumber) async {
    final Database db = await dbService.database;

    final List<Map<String, dynamic>> result = await db.query(
      TableName.devices,
      where: 'ip = ?',
      whereArgs: [serialNumber],
      limit: 1, // Optimization for faster query
    );

    return result.isNotEmpty;
  }

  Future<CommandResult> addDevice(String ip) async {
    emit(state.copyWith(isAddingDevice: true));
    var deviceList = await commandService.deviceList();
    if (deviceList.firstWhereOrNull((d) => d.serialNumber == ip) != null) {
      final Database db = await dbService.database;
      await db.insert(TableName.devices, {'ip': ip});
      // Refresh device list after adding a new device
      await getDevices();

      emit(state.copyWith(isAddingDevice: false));
      return CommandResult(success: true, message: "Success");
    }

    var connectResult = await commandService.connectOverTcpIp(ip);

    if (connectResult.success) {
      final Database db = await dbService.database;
      await db.insert(TableName.devices, {'ip': ip});
      // Refresh device list after adding a new device
      await getDevices();
    }
    emit(state.copyWith(isAddingDevice: false));
    // Return the result so the UI can react accordingly
    return connectResult;
  }

  Future<void> removeAllDevices() async {
    final Database db = await dbService.database;
    await db.delete(TableName.devices);
  }

  void onSelectAll(bool? isSelectAll) {
    var devices =
        state.devices
            .map((d) => d.copyWith(isSelected: isSelectAll ?? false))
            .toList();
    emit(state.copyWith(devices: devices));
  }

  void onToggleDeviceSelection(String ip, bool isSelected) {
    var devices =
        state.devices.map((d) {
          return d.ip == ip ? d.copyWith(isSelected: isSelected) : d;
        }).toList();
    emit(state.copyWith(devices: devices));
  }

  List<String> filterCommand(String input) {
    return commandList.where((cmd) {
      return cmd.toLowerCase().contains(input.toLowerCase());
    }).toList();
  }

  Future<Either<String, Command>> parseCommand(String command) async {
    logCubit.log(
      title: "Parse Command: ",
      message: command.isEmpty ? "Empty" : command,
      type: LogType.DEBUG,
    );
    if (command.isEmpty) return Left("Command is empty");

    var lowerCaseCommand = command.toLowerCase();
    if (lowerCaseCommand.startsWith(rebootCommand.toLowerCase())) {
      return Right(RebootCommand());
    }
    if (lowerCaseCommand.startsWith(keyCodeCommand.toLowerCase())) {
      return Right(KeyCommand(command));
    }

    if (lowerCaseCommand.startsWith(fastbootCommand.toLowerCase())) {
      return Right(RebootBootLoaderCommand());
    }

    if (lowerCaseCommand.startsWith(openAppCommand.toLowerCase())) {
      var packageName = getValueInsideParentheses(command);
      if (packageName == null || packageName.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid package name",
          type: LogType.ERROR,
        );
        return Left("Invalid package name");
      }
      return Right(OpenPackageCommand(packageName));
    }
    if (lowerCaseCommand.startsWith(closeAppCommand.toLowerCase())) {
      var packageName = getValueInsideParentheses(command);
      if (packageName == null || packageName.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid package name",
          type: LogType.ERROR,
        );
        return Left("Invalid package name");
      }
      return Right(ClosePackageCommand(packageName));
    }

    if (lowerCaseCommand.startsWith(runScriptCommand.toLowerCase())) {
      var scriptName = getValueInsideParentheses(command);
      if (scriptName == null || scriptName.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid script name",
          type: LogType.ERROR,
        );
        return Left("Invalid script name");
      }
      return Right(RunScriptCommand(scriptName: scriptName));
    }

    if (lowerCaseCommand.startsWith(tapCommand.toLowerCase())) {
      String? position = getValueInsideParentheses(command);
      if (position == null || position.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid position",
          type: LogType.ERROR,
        );
        return Left("Invalid position");
      }
      double? x = double.tryParse(position.split(" ")[0]);
      double? y = double.tryParse(position.split(" ")[1]);
      if (x == null || y == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid position",
          type: LogType.ERROR,
        );
        return Left("Invalid position");
      }
      return Right(TapCommand(x: x, y: y));
    }

    if (lowerCaseCommand.startsWith(swipeCommand.toLowerCase())) {
      String? swipeData = getValueInsideParentheses(command);
      if (swipeData == null || swipeData.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid swipe data",
          type: LogType.ERROR,
        );
        return Left("Invalid Swipe Data");
      }
      double? x1 = double.tryParse(swipeData.split(" ")[0]);
      double? y1 = double.tryParse(swipeData.split(" ")[1]);
      double? x2 = double.tryParse(swipeData.split(" ")[2]);
      double? y2 = double.tryParse(swipeData.split(" ")[3]);
      int? duration = int.tryParse(swipeData.split(" ")[4]);
      if (x1 == null ||
          y1 == null ||
          x2 == null ||
          y2 == null ||
          duration == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid swipe data",
          type: LogType.ERROR,
        );
        return Left("Invalid Swipe Data");
      }
      return Right(
        SwipeCommand(
          startX: x1,
          startY: y1,
          endX: x2,
          endY: y2,
          duration: duration,
        ),
      );
    }

    if (lowerCaseCommand.startsWith(waitCommand.toLowerCase())) {
      int? delayInSecond = int.tryParse(
        getValueInsideParentheses(command) ?? "0",
      );
      if (delayInSecond == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid delay time",
          type: LogType.ERROR,
        );
        return Left("Invalid delay time (time must be in seconds)");
      }
      return Right(WaitCommand(delayInSecond: delayInSecond));
    }

    if (lowerCaseCommand.startsWith(installApkCommand.toLowerCase())) {
      String? apkName = getValueInsideParentheses(command);
      if (apkName == null || apkName.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid apk name",
          type: LogType.ERROR,
        );
        return Left("Invalid apk name");
      }
      if (!await apkFileService.fileExists(apkName)) {
        logCubit.log(
          title: "Error: ",
          message: "Apk $apkName not found",
          type: LogType.ERROR,
        );
        return Left("Apk $apkName not found");
      }

      return Right(InstallApkCommand(apkName));
    }

    if (lowerCaseCommand.startsWith(uninstallAppsCommand.toLowerCase())) {
      List<String>? packages = getValueInsideParentheses(command)?.split(",");
      if (packages == null || packages.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid package name",
          type: LogType.ERROR,
        );
        return Left("Invalid package name");
      }
      return Right(UninstallAppsCommand(packages));
    }

    if (lowerCaseCommand.startsWith(changeTimezoneCommand.toLowerCase())) {
      String? timeZoneKey = getValueInsideParentheses(command);
      if (timeZoneKey == null || timeZoneKey.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid timezone",
          type: LogType.ERROR,
        );
        return Left("Invalid timezone key");
      }
      return Right(ChangeTimeZoneCommand(timeZone: timeZoneKey));
    }

    if (lowerCaseCommand.startsWith(setProxyCommand.toLowerCase())) {
      String? portAndProxy = getValueInsideParentheses(command);
      var port = portAndProxy?.split(":")[1];
      var ip = portAndProxy?.split(":")[0];
      if (port == null || ip == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid port or ip",
          type: LogType.ERROR,
        );
        return Left("Invalid port or ip");
      }
      return Right(SetProxyCommand(port: port, ip: ip));
    }

    if (lowerCaseCommand.startsWith(verifyProxyCommand.toLowerCase())) {
      return Right(VerifyProxyCommand());
    }

    if (lowerCaseCommand.startsWith(removeProxyCommand.toLowerCase())) {
      return Right(RemoveProxyCommand());
    }

    if (lowerCaseCommand.startsWith(listPackagesCommand.toLowerCase())) {
      return Right(GetPackagesCommand());
    }

    if (lowerCaseCommand.startsWith(setAlwaysOnCommand.toLowerCase())) {
      int? alwaysOn =
          getValueInsideParentheses(command) != null
              ? int.tryParse(getValueInsideParentheses(command)!)
              : null;
      if (alwaysOn == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid always on value (0 or 1)",
          type: LogType.ERROR,
        );
        return Left("Invalid always on value (0 or 1)");
      }
      return Right(SetAlwaysOnCommand(value: alwaysOn));
    }

    if (lowerCaseCommand.startsWith(recoveryCommand.toLowerCase())) {
      return Right(RecoveryCommand());
    }

    if (lowerCaseCommand.startsWith(setOnGpsCommand.toLowerCase())) {
      int? isOn =
          getValueInsideParentheses(command) != null
              ? int.tryParse(getValueInsideParentheses(command)!)
              : null;
      if (isOn == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid always on value (0 or 1)",
          type: LogType.ERROR,
        );
        return Left("Invalid always on value (0 or 1)");
      }
      return Right(SetOnGpsCommand(isOn: isOn == 0 ? false : true));
    }

    if (lowerCaseCommand.startsWith(
      changeDeviceInfoRandomCommand.toLowerCase(),
    )) {
      return Right(ChangeDeviceInfoRandomCommand());
    }

    if (lowerCaseCommand.startsWith(setMockGpsPackageCommand.toLowerCase())) {
      String? packageName = getValueInsideParentheses(command);
      if (packageName == null || packageName.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid package name",
          type: LogType.ERROR,
        );
        return Left("Invalid package name");
      }
      return Right(SetMockLocationPackageCommand(packageName: packageName));
    }

    if (lowerCaseCommand.startsWith(
      setAllowMockLocationCommand.toLowerCase(),
    )) {
      int? isAllow =
          getValueInsideParentheses(command) != null
              ? int.tryParse(getValueInsideParentheses(command)!)
              : null;
      if (isAllow == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid value (0 or 1)",
          type: LogType.ERROR,
        );
        return Left("Invalid value (0 or 1)");
      }
      return Right(
        SetAllowMockLocationCommand(isAllow: isAllow == 0 ? false : true),
      );
    }

    if (lowerCaseCommand.startsWith(setMockLocationCommand.toLowerCase())) {
      String? value = getValueInsideParentheses(command);
      double? lon;
      double? lat;
      if (value?.split(" ")[0] != null) {
        lon = double.tryParse(value!.split(" ")[0])!;
      }
      if (value?.split(" ")[1] != null) {
        lat = double.tryParse(value!.split(" ")[1])!;
      }
      if (lon == null || lat == null) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid lat or lon",
          type: LogType.ERROR,
        );
        return Left("Invalid lat or lon");
      }
      return Right(SetMockLocationCommand(longitude: lon, latitude: lat));
    }

    if (lowerCaseCommand.startsWith(setUpCommand.toLowerCase())) {
      return Right(SetUpCommand());
    }

    if (lowerCaseCommand.startsWith(uninstallInitApkCommand.toLowerCase())) {
      return Right(UninstallInitApkCommand());
    }

    if (lowerCaseCommand.startsWith(removeAppsDataCommand.toLowerCase())) {
      List<String>? packages = getValueInsideParentheses(command)?.split(",");
      if (packages == null || packages.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid package name (package1, package2)",
          type: LogType.ERROR,
        );
        return Left("Invalid package name (package1, package2)");
      }
      return Right(ClearAppsData(packages: packages));
    }

    if (lowerCaseCommand.startsWith(inputTextCommand.toLowerCase())) {
      String? text = getValueInsideParentheses(command);
      if (text == null || text.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid text",
          type: LogType.ERROR,
        );
        return Left("Invalid text");
      }
      return Right(InputTextCommand(text: text));
    }

    if (lowerCaseCommand.startsWith(customAdbCommand.toLowerCase())) {
      String? customCommand = getValueInsideParentheses(command);
      if (customCommand == null || customCommand.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid command",
          type: LogType.ERROR,
        );
        return Left("Invalid command");
      }
      return Right(CustomAdbCommand(command: customCommand));
    }

    if (lowerCaseCommand.startsWith(customCommand.toLowerCase())) {
      String? customCommand = getValueInsideParentheses(command);
      if (customCommand == null || customCommand.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid command",
          type: LogType.ERROR,
        );
        return Left("Invalid command");
      }
      return Right(CustomCommand(command: customCommand));
    }

    if (lowerCaseCommand.startsWith(openChPlayWithUrlCommand.toLowerCase())) {
      String? url = getValueInsideParentheses(command);
      if (url == null || url.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid url",
          type: LogType.ERROR,
        );
        return Left("Invalid url");
      }
      return Right(OpenChPlayWithUrlCommand(url: url));
    }

    if (lowerCaseCommand.startsWith(pullCommand.toLowerCase())) {
      String? path = getValueInsideParentheses(command);
      String? source = path?.split(" ")[0];
      String? destination = path?.split(" ")[1];
      if (source == null ||
          source.isEmpty ||
          destination == null ||
          destination.isEmpty) {
        logCubit.log(
          title: "Error: ",
          message: "Invalid path (source destination)",
          type: LogType.ERROR,
        );
        return Left("Invalid path");
      }
      return Right(
        PullFileCommand(sourcePath: source, destinationPath: destination),
      );
    }

    logCubit.log(
      title: "Error: ",
      message: "Invalid command",
      type: LogType.ERROR,
    );

    return Left("Invalid command");
  }

  Future<List<CommandResult>> executeCommand({
    required Command command,
    required List<Device> devices,
  }) async {
    logCubit.log(title: "Run Command: ", message: command.toString());

    // Update status to inProgress for selected devices
    var updatedDeviceSerialNumbers =
        devices.map((device) => device.ip).toList();
    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
              if (updatedDeviceSerialNumbers.contains(device.ip)) {
                return device.copyWith(
                  commandStatus: DeviceCommandStatus.inProgress,
                );
              }
              return device;
            }).toList(),
      ),
    );
    var deviceIps =
        state.devices.where((d) => d.isSelected).map((d) => d.ip).toList();

    List<CommandResult> results = [];
    if (command is SetUpCommand) {
      results = await Future.wait(
        deviceIps
            .map((serialNumber) => setUpPhone(serialNumber: serialNumber))
            .toList(),
      );
    } else if (command is BackupCommand) {
      results = await Future.wait(
        deviceIps
            .map(
              (serialNumber) => backupPhone(
                serialNumber: serialNumber,
                name: command.backupName,
              ),
            )
            .toList(),
      );
    } else if (command is RestoreBackupCommand) {
      results = await Future.wait(
        deviceIps
            .map(
              (serialNumber) => restorePhone(
                serialNumber: serialNumber,
                name: command.backupName,
              ),
            )
            .toList(),
      );
    } else {
      try {
        results = await commandService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: command,
        );
      } catch (error) {
        logCubit.log(
          title: "Command Error: ",
          message: error.toString(),
          type: LogType.ERROR,
        );
      }
    }

    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
              if (!device.isSelected) return device;

              var result = results.firstWhereOrNull(
                (r) => r.serialNumber == device.ip,
              );
              if (result == null) {
                return device;
              }

              return device.copyWith(
                commandStatus:
                    result.success
                        ? DeviceCommandStatus.success
                        : '${DeviceCommandStatus.failed}: ${result.error}',
              );
            }).toList(),
      ),
    );

    return results;
  }

  Future<void> showScreen() async {
    var devices = state.devices.where((d) => d.isSelected).toList();
    logCubit.log(
      title: "Showing screen: ",
      message: devices.map((d) => d.ip).toList().join(" "),
    );
    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
              if (device.isSelected) {
                return device.copyWith(
                  commandStatus:
                      "${DeviceCommandStatus.inProgress}: show screen",
                );
              }
              return device;
            }).toList(),
      ),
    );

    shellService.runScrcpyForMultipleDevices(devices.map((d) => d.ip).toList());
    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
              if (device.isSelected) {
                return device.copyWith(
                  commandStatus: "${DeviceCommandStatus.success}: show screen",
                );
              }
              return device;
            }).toList(),
      ),
    );
  }

  String? getValueInsideParentheses(String input) {
    final RegExp regExp = RegExp(
      r'\((.*?)\)',
    ); // Match anything inside parentheses
    final match = regExp.firstMatch(input);

    if (match != null) {
      return match.group(1);
    }
    return null;
  }

  Future<void> deleteDevices() async {
    var deviceSerials =
        state.devices.where((d) => d.isSelected).map((d) => d.ip).toList();

    logCubit.log(title: "Deleting: ");

    if (deviceSerials.isEmpty) return; // No devices selected

    final Database db = await dbService.database;

    // Convert IPs into a comma-separated list for the SQL WHERE clause
    final String whereClause =
        'ip IN (${List.filled(deviceSerials.length, '?').join(', ')})';

    await db.delete(
      TableName.devices,
      where: whereClause,
      whereArgs: deviceSerials,
    );

    await commandService.runCommandOnMultipleDevices(
      deviceSerials: deviceSerials,
      command: DisconnectCommand(),
    );
    await getDevices();
  }

  Future<void> connectAll() async {
    emit(state.copyWith(isConnectingAll: true));
    try {
      var devices =
          state.devices.where((device) => isValidIp(device.ip)).toList();
      var deviceSerials = devices.map((device) => device.ip).toList();
      List<Future<CommandResult>> tasks =
          deviceSerials.map((deviceIp) async {
            return await commandService.connectOverTcpIp(deviceIp);
          }).toList();
      await Future.wait(tasks);
    } finally {
      emit(state.copyWith(isConnectingAll: false));
      await refresh();
    }
  }

  bool isValidIp(String ip) {
    final ipRegex = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$');

    if (!ipRegex.hasMatch(ip)) {
      return false;
    }

    // Check each octet is between 0 and 255
    return ip.split('.').every((octet) {
      final intVal = int.tryParse(octet);
      return intVal != null && intVal >= 0 && intVal <= 255;
    });
  }

  Future<bool> scriptExists(String scriptName) async {
    return textFileService.fileExists(scriptPath(scriptName));
  }

  String scriptPath(String scriptName) {
    return "scripts/$scriptName";
  }

  Future<bool> apkFileExists(String apkName) async {
    return apkFileService.fileExists(apkName);
  }

  Future<CommandResult> setUpPhone({required String serialNumber}) async {
    var result = await executeMultipleCommandsOn1Device(
      successMessage: "Setup successfully",
      tasks: [
        () => commandService.runCommand(
          command: KeyCommand("KEYCODE_HOME"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: InstallApkCommand("link2sd"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: InstallApkCommand("hide_mock_location"),
          serialNumber: serialNumber,
        ),
        // () => commandService.runCommand(
        //   command: InstallApkCommand("google_chrome"),
        //   serialNumber: serialNumber,
        // ),
        () => commandService.runCommand(
          command: InstallApkCommand("device_info"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: InstallApkCommand("fake_gps"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: SetAlwaysOnCommand(value: 1),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: SetMockLocationPackageCommand(
            packageName: defaultLocationMockPackage,
          ),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: SetAlwaysOnCommand(value: 0),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
        ),
      ],
    );
    if (result.isLeft) {
      return result.left;
    } else {
      return CommandResult(
        success: true,
        message: "Back up $serialNumber successfully",
      );
    }
  }

  Future<List<CommandResult>> executeCommandForSelectedDevices({
    required Command command,
  }) {
    return executeCommand(command: command, devices: getSelectedDevices());
  }

  Future<CommandResult> backupPhone({
    required String serialNumber,
    required String name,
  }) async {
    var backupDir = _directoryService.getDeviceBackUpFolder(serialNumber: serialNumber, folderName: name);

    var result = await executeMultipleCommandsOn1Device(
      successMessage: "Backup successfully",
      tasks: [
        ()=> ,
        () => createBackupFolderIfNotExists(
          serialNumber: serialNumber,
          backupName: name,
        ),
        () => commandService.runCommand(
          command: PullFileCommand(
            sourcePath: backupDir,
            destinationPath: '$currentPath/file/rss/$serialNumber/',
          ),
          serialNumber: serialNumber,
        ),

      ],
    );

    if (result.isLeft) {
      return result.left;
    } else {
      return CommandResult(
        success: true,
        message: "Back up $serialNumber successfully",
      );
    }
  }

  Future<CommandResult> restorePhone({
    required String serialNumber,
    required String name,
  }) async {
    var backupDir = _directoryService.getDeviceBackUpFolder(serialNumber: serialNumber, folderName: name);
    var result = await executeMultipleCommandsOn1Device(
      successMessage: "Backup successfully",
      tasks: [
        () => commandService.runCommand(
          command: RecoveryCommand(),
          serialNumber: serialNumber,
        ),
        () => waitForTWRP(serialNumber),
        () => commandService.runCommand(
          command: PushFileCommand(
            sourcePath: deviceBackupFolder.path,
            destinationPath: backupDir,
          ),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: CustomAdbCommand(command: "shell twrp wipe dalvik"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: CustomAdbCommand(command: "shell twrp wipe data"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: CustomAdbCommand(command: "shell twrp restore $name"),
          serialNumber: serialNumber,
        ),
        () => commandService.runCommand(
          command: RebootCommand(),
          serialNumber: serialNumber,
        ),
      ],
    );
    if (result.isLeft) {
      return result.left;
    } else {
      return CommandResult(
        success: true,
        message: "Back up $serialNumber successfully",
      );
    }
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
          logCubit.log(title: "TWRP detected...", type: LogType.DEBUG);
          return CommandResult(success: true, message: "TWRP detected");
        } else {
          // Get device state
          ProcessResult stateResult = await Process.run('adb', [
            '-s',
            deviceSerial,
            'get-state',
          ], runInShell: true);
          await Future.delayed(Duration(seconds: 2));
        }
      } catch (e) {
        logCubit.log(
          title: "Open TWRP Error...",
          message: e.toString(),
          type: LogType.DEBUG,
        );
        return CommandResult(success: false, message: "TWRP not detected");
      }
      await Future.delayed(Duration(seconds: 2));
      i++;
    }
    return CommandResult(success: false, message: "TWRP not detected");
  }

  Future<Either<CommandResult, CommandResult>>
  executeMultipleCommandsOn1Device({
    required List<Future<CommandResult> Function()> tasks,
    required String successMessage,
  }) async {
    for (var task in tasks) {
      var result = await task();
      if (!result.success) return Left(result);
    }
    return Right(CommandResult(success: true, message: successMessage));
  }

  Future<CommandResult> createBackupFolderIfNotExists({
    required String serialNumber,
    required String backupName,
  }) async {
    try {
      var currentPath = Directory.current.path;
      Directory directory = Directory("$currentPath/file/rss/$serialNumber/$backupName");
      if (!(await directory.exists())) {
        await directory.create(recursive: true);
      }
      return CommandResult(
        success: true,
        message: "Create folder ${directory.path} successfully!",
      );
    } catch (e) {
      return CommandResult(success: false, message: e.toString());
    }
  }

  List<Device> getSelectedDevices() {
    return state.devices.where((d) => d.isSelected).toList();
  }

  Future<void> replayEventFile(String filePath, String serialNumber) async {
    final file = File(filePath);
    if (!await file.exists()) {
      print("File not found: $filePath");
      return;
    }

    List<String> lines = await file.readAsLines();
    if (lines.isEmpty) {
      print("Event file is empty.");
      return;
    }

    double? lastTimestamp;
    List<Future<void>> adbCommands = [];

    for (String line in lines) {
      List<String> parts = line.trim().split(RegExp(r'\s+'));

      if (parts.length < 4 || !parts[0].startsWith('[')) {
        continue; // Skip invalid lines
      }

      // Extract timestamp
      double timestamp =
          double.tryParse(parts[0].replaceAll(RegExp(r'[\[\]]'), '')) ?? 0;
      String event = parts.sublist(1).join(' '); // The rest is the event data

      // Calculate delay
      double delayMs =
          lastTimestamp != null ? (timestamp - lastTimestamp!) * 1000 : 0;
      lastTimestamp = timestamp;

      // Schedule event execution
      adbCommands.add(
        Future.delayed(Duration(milliseconds: delayMs.round()), () async {
          String command = 'adb -s $serialNumber shell sendevent $event';
          print("Running: $command");
          await Process.run('adb', [
            '-s',
            serialNumber,
            'shell',
            'sendevent',
            ...parts.sublist(1),
          ]);
        }),
      );
    }

    await Future.wait(adbCommands);
    print("Replay finished!");
  }
}

// adb shell settings put global verifier_verify_adb_installs 0
