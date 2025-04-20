import 'dart:io';

import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/database_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/core/service/text_file_service.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'adb_device.dart';
import 'device.dart';

part 'device_list_cubit.freezed.dart';

part 'device_list_state.dart';

const customCommand = "CustomCommand";
const customAdbCommand = "CustomAdbCommand";
const rebootCommand = "Reboot";
const keyCodeCommand = "KEYCODE";
const openAppCommand = "OpenApp";
const closeAppCommand = "CloseApp";
const runScriptCommand = "RunScript";
const tapCommand = "Tap";
const waitCommand = "Wait";
const waitRandomCommand = "WaitRandom";
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
const setUpCommand = "SetUp";
const uninstallInitApkCommand = "UninstallInitApk";
const removeAppsDataCommand = "RemoveAppsData";
const openChPlayWithUrlCommand = "OpenChPlayWithUrl";
const inputTextCommand = "InputText";
const pullCommand = "Pull";
const getSpoofedDeviceInfoCommand = "GetSpoofedDeviceInfo";
const getSpoofedGeoCommand = "GetSpoofedGeo";
const replayTraceScriptCommand = "ReplayTraceScriptCommand";

class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit() : super(const DeviceListState());
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
    setUpCommand,
    uninstallInitApkCommand,
    removeAppsDataCommand,
    inputTextCommand,
    openChPlayWithUrlCommand,
    pullCommand,
    waitRandomCommand,
    getSpoofedDeviceInfoCommand,
    getSpoofedGeoCommand,
    replayTraceScriptCommand,
  ];

  final CommandService _commandService = sl();
  final DatabaseService _dbService = sl();
  final ShellService _shellService = sl();
  final TextFileService _textFileService = sl();
  final LogCubit _logCubit = sl();
  final ApkFileService _apkFileService = sl();

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
    final Database db = await _dbService.database;
    final result = await db.query(TableName.devices);
    final deviceList = result.map((data) => Device.fromJson(data)).toList();

    var adbDeviceList = await _commandService.deviceList();
    Map<String, DeviceConnectionStatus> deviceStatusMap = deviceListStatusMap(
      adbDeviceList,
    );

    var updatedDevices =
        deviceList.map((device) {
          return device.copyWith(
            status:
                deviceStatusMap[device.ip] ??
                DeviceConnectionStatus.notDetected,
          );
        }).toList();

    final connectedDevice =
        deviceList.where((device) {
          return deviceStatusMap[device.ip] == DeviceConnectionStatus.booted ||
              deviceStatusMap[device.ip] == DeviceConnectionStatus.twrp ||
              deviceStatusMap[device.ip] == DeviceConnectionStatus.recovery;
        }).toList();

    var spoofedDeviceInfoResult = await _commandService
        .runCommandOnMultipleDevices(
          command: GetSpoofedDeviceInfoCommand(),
          deviceSerials: connectedDevice.map((d) => d.ip).toList(),
        );

    var spoofedDeviceInfoMap = Map.fromEntries(
      spoofedDeviceInfoResult.map((e) => MapEntry(e.serialNumber, e.payload)),
    );

    var spoofedGeoResult = await _commandService.runCommandOnMultipleDevices(
      command: GetSpoofedGeoCommand(),
      deviceSerials: connectedDevice.map((d) => d.ip).toList(),
    );
    var spoofedGeoMap = Map.fromEntries(
      spoofedGeoResult.map((e) => MapEntry(e.serialNumber, e.payload)),
    );

    var proxyResult = await _commandService.runCommandOnMultipleDevices(
      command: GetProxyCommand(),
      deviceSerials: connectedDevice.map((d) => d.ip).toList(),
    );

    var proxyMap = Map.fromEntries(
      proxyResult.map((e) => MapEntry(e.serialNumber, e.payload)),
    );

    // Update the device list with the spoofed device info and geo
    updatedDevices =
        updatedDevices.map((device) {
          var spoofedDeviceInfo = spoofedDeviceInfoMap[device.ip];
          var geo = spoofedGeoMap[device.ip];
          var proxy = proxyMap[device.ip];
          return device.copyWith(
            spoofedDeviceInfo: spoofedDeviceInfo,
            geo: geo,
            proxy: proxy,
          );
        }).toList();

    // Emit the updated device list with their statuses
    emit(state.copyWith(devices: updatedDevices));
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true));
    var deviceList = state.devices;
    final connectedDevices =
        deviceList.where((device) {
          return device.status == DeviceConnectionStatus.booted ||
              device.status == DeviceConnectionStatus.twrp ||
              device.status == DeviceConnectionStatus.recovery;
        }).toList();
    if (deviceList.isEmpty) {
      return;
    }

    var adbDeviceList = await _commandService.deviceList();
    Map<String, DeviceConnectionStatus> deviceStatusMap = deviceListStatusMap(
      adbDeviceList,
    );

    var updatedDevices =
        deviceList.map((device) {
          return device.copyWith(
            status:
                deviceStatusMap[device.ip] ??
                DeviceConnectionStatus.notDetected,
          );
        }).toList();

    var spoofedDeviceInfoResult = await _commandService
        .runCommandOnMultipleDevices(
          command: GetSpoofedDeviceInfoCommand(),
          deviceSerials: connectedDevices.map((d) => d.ip).toList(),
        );

    var spoofedDeviceInfoMap = Map.fromEntries(
      spoofedDeviceInfoResult.map((e) => MapEntry(e.serialNumber, e.payload)),
    );

    var spoofedGeoResult = await _commandService.runCommandOnMultipleDevices(
      command: GetSpoofedGeoCommand(),
      deviceSerials: connectedDevices.map((d) => d.ip).toList(),
    );
    var spoofedGeoMap = Map.fromEntries(
      spoofedGeoResult.map((e) => MapEntry(e.serialNumber, e.payload)),
    );

    var proxyResult = await _commandService.runCommandOnMultipleDevices(
      command: GetProxyCommand(),
      deviceSerials: connectedDevices.map((d) => d.ip).toList(),
    );

    var proxyMap = Map.fromEntries(
      proxyResult.map((e) => MapEntry(e.serialNumber, e.payload)),
    );

    // Update the device list with the spoofed device info and geo
    updatedDevices =
        updatedDevices.map((device) {
          var spoofedDeviceInfo = spoofedDeviceInfoMap[device.ip];
          var geo = spoofedGeoMap[device.ip];
          var proxy = proxyMap[device.ip];
          return device.copyWith(
            spoofedDeviceInfo: spoofedDeviceInfo,
            geo: geo,
            proxy: proxy,
          );
        }).toList();

    emit(state.copyWith(isRefreshing: false, devices: updatedDevices));
  }

  Future<bool> deviceExistsBySerial(String serialNumber) async {
    final Database db = await _dbService.database;

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
    var deviceList = await _commandService.deviceList();
    if (deviceList.firstWhereOrNull((d) => d.serialNumber == ip) != null) {
      final Database db = await _dbService.database;
      await db.insert(TableName.devices, {'ip': ip});
      // Refresh device list after adding a new device
      await getDevices();

      emit(state.copyWith(isAddingDevice: false));
      return CommandResult(success: true, message: "Success");
    }

    var connectResult = await _commandService.connectOverTcpIp(ip);

    if (connectResult.success) {
      final Database db = await _dbService.database;
      await db.insert(TableName.devices, {'ip': ip});
      // Refresh device list after adding a new device
      await getDevices();
    }
    emit(state.copyWith(isAddingDevice: false));
    // Return the result so the UI can react accordingly
    return connectResult;
  }

  Future<void> removeAllDevices() async {
    final Database db = await _dbService.database;
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
    _logCubit.log(
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
      return Right(FastbootCommand());
    }

    if (lowerCaseCommand.startsWith(openAppCommand.toLowerCase())) {
      var packageName = getValueInsideParentheses(command);
      if (packageName == null || packageName.isEmpty) {
        _logCubit.log(
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
        _logCubit.log(
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
      if (scriptName == null ||
          scriptName.isEmpty ||
          !await scriptExists(scriptName)) {
        _logCubit.log(
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
        _logCubit.log(
          title: "Error: ",
          message: "Invalid position",
          type: LogType.ERROR,
        );
        return Left("Invalid position");
      }
      double? x = double.tryParse(position.split(" ")[0]);
      double? y = double.tryParse(position.split(" ")[1]);
      if (x == null || y == null) {
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
          title: "Error: ",
          message: "Invalid delay time",
          type: LogType.ERROR,
        );
        return Left("Invalid delay time (time must be in seconds)");
      }
      return Right(WaitCommand(delayInSecond: delayInSecond));
    }
    if (lowerCaseCommand.startsWith(waitRandomCommand.toLowerCase())) {
      int? minDelayInSecond = int.tryParse(
        getValueInsideParentheses(command)?.split(",")[0] ?? "0",
      );
      int? maxDelayInSecond = int.tryParse(
        getValueInsideParentheses(command)?.split(",")[1] ?? "0",
      );
      if (minDelayInSecond == null || maxDelayInSecond == null) {
        _logCubit.log(
          title: "Error: ",
          message: "Invalid delay time",
          type: LogType.ERROR,
        );
        return Left("Invalid delay time (time must be in seconds)");
      }
      return Right(
        WaitRandomCommand(
          minDelayInSecond: minDelayInSecond,
          maxDelayInSecond: maxDelayInSecond,
        ),
      );
    }

    if (lowerCaseCommand.startsWith(installApkCommand.toLowerCase())) {
      String? apkName = getValueInsideParentheses(command);
      if (apkName == null || apkName.isEmpty) {
        _logCubit.log(
          title: "Error: ",
          message: "Invalid apk name",
          type: LogType.ERROR,
        );
        return Left("Invalid apk name");
      }
      if (!await _apkFileService.fileExists(apkName)) {
        _logCubit.log(
          title: "Error: ",
          message: "Apk $apkName not found",
          type: LogType.ERROR,
        );
        return Left("Apk $apkName not found");
      }

      return Right(InstallApksCommand([apkName]));
    }

    if (lowerCaseCommand.startsWith(uninstallAppsCommand.toLowerCase())) {
      List<String>? packages = getValueInsideParentheses(command)?.split(",");
      if (packages == null || packages.isEmpty) {
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
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
      return Right(ChangeRandomDeviceInfoCommand());
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
        _logCubit.log(
          title: "Error: ",
          message: "Invalid package name (package1, package2)",
          type: LogType.ERROR,
        );
        return Left("Invalid package name (package1, package2)");
      }
      return Right(ClearAppsDataCommand(packages: packages));
    }

    if (lowerCaseCommand.startsWith(inputTextCommand.toLowerCase())) {
      String? text = getValueInsideParentheses(command);
      if (text == null || text.isEmpty) {
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
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
        _logCubit.log(
          title: "Error: ",
          message: "Invalid url",
          type: LogType.ERROR,
        );
        return Left("Invalid url");
      }
      return Right(OpenChPlayWithUrlCommand(url: url));
    }

    if (lowerCaseCommand.startsWith(
      getSpoofedDeviceInfoCommand.toLowerCase(),
    )) {
      return Right(GetSpoofedDeviceInfoCommand());
    }

    if (lowerCaseCommand.startsWith(pullCommand.toLowerCase())) {
      String? path = getValueInsideParentheses(command);
      String? source = path?.split(" ")[0];
      String? destination = path?.split(" ")[1];
      if (source == null ||
          source.isEmpty ||
          destination == null ||
          destination.isEmpty) {
        _logCubit.log(
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

    if (lowerCaseCommand.startsWith(replayTraceScriptCommand.toLowerCase())) {
      String? scriptName = getValueInsideParentheses(command);
      if (scriptName == null || scriptName.isEmpty) {
        _logCubit.log(
          title: "Error: ",
          message: "Invalid script name $scriptName",
          type: LogType.ERROR,
        );
        return Left("Invalid script name: $scriptName");
      }
      return Right(ReplayTraceScriptCommand(traceScriptName: scriptName));
    }

    _logCubit.log(
      title: "Error: ",
      message: "Invalid command",
      type: LogType.ERROR,
    );

    return Left("Invalid command");
  }

  Future<List<CommandResult>> executeCommandForMultipleDevices({
    required Command command,
    required List<String> serialNumbers,
  }) async {
    _logCubit.log(title: "Run Command: ", message: command.toString());

    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
              if (serialNumbers.contains(device.ip)) {
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
    if (command is RunScriptCommand) {
      List<String>? scripts = await _textFileService.readData(
        scriptPath(command.scriptName),
      );

      for (var scriptCommand in scripts!) {
        if (scriptCommand.startsWith("#") || scriptCommand.trim().isEmpty) {
          continue;
        }
        var parsedCommandResult = await parseCommand(scriptCommand);
        if (parsedCommandResult.isLeft) continue;
        await executeCommandForMultipleDevices(
          command: parsedCommandResult.right,
          serialNumbers: serialNumbers,
        );
      }
    } else {
      try {
        results = await _commandService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: command,
        );
      } catch (error) {
        _logCubit.log(
          title: "Command Error: ",
          message: error.toString(),
          type: LogType.ERROR,
        );
      }
    }

    updateDeviceStatusFromResults(results);

    return results;
  }

  Future<void> showScreen() async {
    var devices = state.devices.where((d) => d.isSelected).toList();
    _logCubit.log(
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

    _shellService.runScrcpyForMultipleDevices(
      devices.map((d) => d.ip).toList(),
    );
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

    _logCubit.log(title: "Deleting: ");

    if (deviceSerials.isEmpty) return; // No devices selected

    final Database db = await _dbService.database;

    // Convert IPs into a comma-separated list for the SQL WHERE clause
    final String whereClause =
        'ip IN (${List.filled(deviceSerials.length, '?').join(', ')})';

    await db.delete(
      TableName.devices,
      where: whereClause,
      whereArgs: deviceSerials,
    );

    _commandService.runCommandOnMultipleDevices(
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
            return await _commandService.connectOverTcpIp(deviceIp);
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
    return _textFileService.fileExists(scriptPath(scriptName));
  }

  String scriptPath(String scriptName) {
    return "scripts/$scriptName";
  }

  Future<bool> apkFileExists(String apkName) async {
    return _apkFileService.fileExists(apkName);
  }

  Future<List<CommandResult>> executeCommandForSelectedDevices({
    required Command command,
  }) {
    return executeCommandForMultipleDevices(
      command: command,
      serialNumbers: getSelectedDevices().map((d) => d.ip).toList(),
    );
  }

  List<Device> getSelectedDevices() {
    return state.devices.where((d) => d.isSelected).toList();
  }

  Future<void> replayEventFile(String filePath, String serialNumber) async {
    final file = File(filePath);
    if (!await file.exists()) {
      debugPrint("File not found: $filePath");
      return;
    }

    List<String> lines = await file.readAsLines();
    if (lines.isEmpty) {
      debugPrint("Event file is empty.");
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
          lastTimestamp != null ? (timestamp - lastTimestamp) * 1000 : 0;
      lastTimestamp = timestamp;

      // Schedule event execution
      adbCommands.add(
        Future.delayed(Duration(milliseconds: delayMs.round()), () async {
          String command = 'adb -s $serialNumber shell sendevent $event';
          debugPrint("Running: $command");
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
    debugPrint("Replay finished!");
  }

  Future<CommandResult> restorePhone({
    required String serialNumber,
    required RestoreBackupCommand command,
  }) async {
    return await _commandService.runCommand(
      command: command,
      serialNumber: serialNumber,
    );
  }

  void updateDeviceStatusFromResults(List<CommandResult> results) {
    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
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
                        : '${DeviceCommandStatus.failed}: ${result.message}',
              );
            }).toList(),
      ),
    );
  }
}
