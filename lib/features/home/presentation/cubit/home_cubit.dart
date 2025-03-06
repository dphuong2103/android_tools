import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/core/service/adb_service.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/database_service.dart';
import 'package:android_tools/core/service/text_file_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/features/home/domain/entity/adb_command.dart';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:collection/collection.dart';
import '../../../../injection_container.dart';
import '../../domain/entity/adb_device.dart';

//931 1271
//320 1679
part 'home_cubit.freezed.dart';

part 'home_state.dart';

const rebootCommand = "Reboot";
const keyCodeCommand = "KEYCODE";
const openAppCommand = "OpenApp";
const closeAppCommand = "CloseApp";
const runScriptCommand = "RunScript";
const tapCommand = "Tap";
const waitCommand = "Wait";
const swipeCommand = "Swipe";
const installApkCommand = "InstallApk";
const uninstallAppCommand = "UninstallApp";
const rebootBootloader = "Bootloader";
const changeTimezone = "ChangeTimeZone";
const changeLocation = "ChangeLocation";

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  final List<String> commandList = [
    rebootCommand,
    keyCodeCommand,
    openAppCommand,
    closeAppCommand,
    runScriptCommand,
    tapCommand,
    waitCommand,
    installApkCommand,
    uninstallAppCommand,
    rebootBootloader,
    changeTimezone,
    changeLocation,
  ];

  final AdbService adbService = sl();
  final DatabaseService dbService = sl();
  final ShellService shellService = sl();
  final TextFileService textFileService = sl();
  final LogCubit logCubit = sl();
  final ApkFileService apkFileService = sl();

  Future<void> init() async {
    await getDevices();
  }

  Future<void> getDevices() async {
    // Fetch device IPs from the database (main list)
    final Database db = await dbService.database;
    final result = await db.query("devices");
    final deviceList = result.map((data) => Device.fromJson(data)).toList();

    var adbDeviceList = await adbService.deviceList();
    var adbDeviceStatusMap = {
      for (var device in adbDeviceList)
        device.serialNumber: device.status ?? DeviceStatus.notConnected,
    };

    var adbGetGeoResult = await adbService.runCommandOnMultipleDevices(
      deviceSerials:
          adbDeviceList
              .where((d) => d.status == AdbDeviceStatus.connected)
              .map((d) => d.serialNumber)
              .toList(),
      command: GetTimeZoneCommand(),
    );

    var adbGeoMap = {
      for (var result in adbGetGeoResult)
        result.serialNumber: result.success ? result.message : "",
    };

    final updatedDevices =
        deviceList.map((device) {
          final adbStatus = adbDeviceStatusMap[device.ip];
          final geoResult = adbGeoMap[device.ip] ?? "";
          if (adbStatus == AdbDeviceStatus.connected) {
            return device.copyWith(
              status: DeviceStatus.connected,
              geo: geoResult,
            );
          } else if (adbStatus == AdbDeviceStatus.unAuthorized) {
            return device.copyWith(
              status: DeviceStatus.unAuthorized,
              geo: geoResult,
            );
          } else {
            return device.copyWith(
              status: DeviceStatus.notConnected,
              geo: geoResult,
            );
          }
        }).toList();

    // Emit the updated device list with their statuses
    emit(state.copyWith(devices: updatedDevices));
  }

  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true));
    var devices = state.devices;
    if (devices.isEmpty) {
      return;
    }

    var adbDeviceList = await adbService.deviceList();
    var adbDeviceStatusMap = {
      for (var device in adbDeviceList)
        device.serialNumber: device.status ?? DeviceStatus.notConnected,
    };

    var adbGetGeoResult = await adbService.runCommandOnMultipleDevices(
      deviceSerials:
          adbDeviceList
              .where((d) => d.status == AdbDeviceStatus.connected)
              .map((d) => d.serialNumber)
              .toList(),
      command: GetTimeZoneCommand(),
    );

    var adbGeoMap = {
      for (var result in adbGetGeoResult)
        result.serialNumber: result.success ? result.message : "",
    };

    final updatedDevices =
        devices.map((device) {
          final adbStatus = adbDeviceStatusMap[device.ip];
          final geoResult = adbGeoMap[device.ip] ?? "";
          if (adbStatus == AdbDeviceStatus.connected) {
            return device.copyWith(
              status: DeviceStatus.connected,
              geo: geoResult,
            );
          } else if (adbStatus == AdbDeviceStatus.unAuthorized) {
            return device.copyWith(
              status: DeviceStatus.unAuthorized,
              geo: geoResult,
            );
          } else {
            return device.copyWith(
              status: DeviceStatus.notConnected,
              geo: geoResult,
            );
          }
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

  Future<AdbResult> addDevice(String ip) async {
    emit(state.copyWith(isAddingDevice: true));
    var deviceList = await adbService.deviceList();
    if (deviceList.firstWhereOrNull((d) => d.serialNumber == ip) != null) {
      final Database db = await dbService.database;
      await db.insert(TableName.devices, {'ip': ip});
      // Refresh device list after adding a new device
      await getDevices();

      emit(state.copyWith(isAddingDevice: false));
      return AdbResult(success: true, message: "Success");
    }

    var connectResult = await adbService.connectOverTcpIp(ip);

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

  Future<void> runCommand(String command) async {
    if (command.isEmpty) {
      return;
    }

    logCubit.log(title: "Run Command: ", message: command);

    // Update status to inProgress for selected devices
    emit(
      state.copyWith(
        devices:
            state.devices.map((device) {
              if (device.isSelected) {
                return device.copyWith(
                  commandStatus: DeviceCommandStatus.inProgress,
                );
              }
              return device;
            }).toList(),
      ),
    );

    // Extract device IPs of selected devices
    var deviceIps =
        state.devices.where((d) => d.isSelected).map((d) => d.ip).toList();

    List<AdbResult> results = [];
    command = command.toLowerCase();

    try {
      if (command == "KEYCODE_HOME".toLowerCase()) {
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: KeyCommand("KEYCODE_HOME"),
        );
      }
      if (command == "KEYCODE_BACK".toLowerCase()) {
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: KeyCommand("KEYCODE_BACK"),
        );
      }

      if (command == "KEYCODE_APP_SWITCH".toLowerCase()) {
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: KeyCommand("KEYCODE_APP_SWITCH"),
        );
      }

      if (command == rebootCommand.toLowerCase()) {
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: RebootCommand(),
        );
      } else if (command.startsWith(keyCodeCommand.toLowerCase())) {
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: KeyCommand(command),
        );
      } else if (command.startsWith(rebootBootloader.toLowerCase())) {
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: RebootBootLoaderCommand(),
        );
      } else if (command.startsWith(openAppCommand.toLowerCase())) {
        var packageName = getValueInsideParentheses(command);
        var commandResults = await openApp(deviceIps, packageName);
        if (commandResults != null) {
          results = commandResults;
        }
      } else if (command.startsWith(closeAppCommand.toLowerCase())) {
        var packageName = getValueInsideParentheses(command);
        if (packageName == null) return;
        results = await adbService.runCommandOnMultipleDevices(
          deviceSerials: deviceIps,
          command: ClosePackageCommand(packageName),
        );
      } else if (command.startsWith(runScriptCommand.toLowerCase())) {
        var scriptName = getValueInsideParentheses(command);
        if (scriptName == null ||
            scriptName.isEmpty ||
            !await scriptExists(scriptName)) {
          logCubit.log(
            title: "Not found: ",
            message: "$scriptName",
            type: LogType.ERROR,
          );
        }
        List<String>? scripts = await textFileService.readData(
          scriptPath(scriptName!),
        );

        if (scripts == null || scripts.isEmpty) {
          logCubit.log(
            title: "Empty: ",
            message: scriptName,
            type: LogType.ERROR,
          );
        }

        for (var scriptCommand in scripts!) {
          await runCommand(scriptCommand);
        }
      } else if (command.startsWith(tapCommand.toLowerCase())) {
        String? position = getValueInsideParentheses(command);
        if (position == null || position.isEmpty) {
          logCubit.log(
            title: "Empty: ",
            message: "position is empty",
            type: LogType.ERROR,
          );
        } else {
          double? x = double.tryParse(position.split(" ")[0]);
          double? y = double.tryParse(position.split(" ")[1]);
          if (x != null && y != null) {
            results = await adbService.runCommandOnMultipleDevices(
              deviceSerials: deviceIps,
              command: TapCommand(x: x, y: y),
            );
          }
        }
      } else if (command.toLowerCase().startsWith(swipeCommand.toLowerCase())) {
        String? swipeData = getValueInsideParentheses(command);
        if (swipeData == null || swipeData.isEmpty) {
          logCubit.log(
            title: "Empty: ",
            message: "Swipe data is empty",
            type: LogType.ERROR,
          );
        } else {
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
            logCubit.log(title: "Invalid swipe input", type: LogType.ERROR);
          } else {
            results = await adbService.runCommandOnMultipleDevices(
              deviceSerials: deviceIps,
              command: SwipeCommand(
                startX: x1,
                startY: y1,
                endX: x2,
                endY: y2,
                duration: duration,
              ),
            );
          }
        }
      } else if (command.startsWith(waitCommand.toLowerCase())) {
        int? delayInSecond = int.tryParse(
          getValueInsideParentheses(command) ?? "0",
        );
        if (delayInSecond != null && delayInSecond != 0) {
          await Future.delayed(Duration(seconds: delayInSecond));
        }
      } else if (command.startsWith(installApkCommand.toLowerCase())) {
        String? apkName = getValueInsideParentheses(command);
        var commandResults = await installApk(deviceIps, apkName);
        if (commandResults != null) {
          results = commandResults;
        }
      } else if (command.startsWith(uninstallAppCommand.toLowerCase())) {
        String? packageName = getValueInsideParentheses(command);
        var commandResults = await uninstallApp(deviceIps, packageName);
        if (commandResults != null) {
          results = commandResults;
        }
      } else if (command.startsWith(changeTimezone.toLowerCase())) {
        String? timeZoneKey = getValueInsideParentheses(command);
        var commandResults = await changeTimeZone(deviceSerials: deviceIps, timeZone: timeZoneKey);
        if (commandResults != null) {
          results = commandResults;
        }
      }

      // Update device statuses based on results
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
    } catch (e) {
      logCubit.log(
        title: "Command Error: ",
        message: e.toString(),
        type: LogType.ERROR,
      );
    }
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

    shellService.runScrcpy(devices);
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

    await adbService.runCommandOnMultipleDevices(
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
      List<Future<AdbResult>> tasks =
          deviceSerials.map((deviceIp) async {
            return await adbService.connectOverTcpIp(deviceIp);
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

  Future<List<AdbResult>?> installApk(
    List<String> deviceSerials,
    String? apkName,
  ) async {
    if (apkName == null) {
      logCubit.log(
        title: "Error: ",
        message: "Apk name empty",
        type: LogType.ERROR,
      );
      return null;
    }
    if (!await apkFileExists(apkName)) {
      logCubit.log(
        title: "Error: ",
        message: "Apk $apkName not found",
        type: LogType.ERROR,
      );
      return null;
    }

    String apkPath = await apkFileService.filePath(apkName);
    apkPath = apkPath.replaceAll("/", "\\");
    return adbService.runCommandOnMultipleDevices(
      deviceSerials: deviceSerials,
      command: InstallApkCommand(apkPath),
    );
  }

  Future<List<AdbResult>?> uninstallApp(
    List<String> deviceSerials,
    String? packageName,
  ) async {
    if (packageName == null || packageName.isEmpty) {
      logCubit.log(
        title: "Error: ",
        message: "Invalid package name",
        type: LogType.ERROR,
      );
      return null;
    }
    return adbService.runCommandOnMultipleDevices(
      deviceSerials: deviceSerials,
      command: UninstallAppCommand(packageName),
    );
  }

  Future<List<AdbResult>?> openApp(
    List<String> deviceSerials,
    String? packageName,
  ) async {
    if (packageName == null || packageName.isEmpty) {
      logCubit.log(
        title: "Error: ",
        message: "Invalid package name",
        type: LogType.ERROR,
      );
      return null;
    }
    return await adbService.runCommandOnMultipleDevices(
      deviceSerials: deviceSerials,
      command: OpenPackageCommand(packageName),
    );
  }

  Future<List<AdbResult>?> changeTimeZone({
    required List<String> deviceSerials,
    String? timeZone,
  }) async {
    if(timeZone == null || timeZone.isEmpty){
      logCubit.log(
        title: "Error: ",
        message: "Invalid TimeZone",
        type: LogType.ERROR,
      );

      return null;
    }
    return adbService.runCommandOnMultipleDevices(
      deviceSerials: deviceSerials,
      command: ChangeTimeZoneCommand(timeZone: timeZone),
    );
  }
}
