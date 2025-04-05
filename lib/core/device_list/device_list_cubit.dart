import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/database_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/core/service/text_file_service.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'adb_device.dart';
import 'device.dart';

part 'device_list_cubit.freezed.dart';

part 'device_list_state.dart';

class DeviceListCubit extends Cubit<DeviceListState> {
  DeviceListCubit() : super(const DeviceListState());

  final CommandService _commandService = sl();
  final DatabaseService _dbService = sl();
  final ShellService _shellService = sl();
  final TextFileService _textFileService = sl();
  final LogCubit _logCubit = sl();
  final ApkFileService _apkFileService = sl();

  Future<void> getDevices() async {
    // Fetch device IPs from the database (main list)
    final Database db = await _dbService.database;
    final result = await db.query(TableName.devices);
    final deviceList = result.map((data) => Device.fromJson(data)).toList();

    var adbDeviceList = await _commandService.deviceList();
    Map<String, DeviceConnectionStatus> deviceStatusMap = deviceListStatusMap(
      adbDeviceList ,
    );

    final updatedDevices =
    deviceList.map((device) {
      return device.copyWith(
        status:
        deviceStatusMap[device.ip] ??
            DeviceConnectionStatus.notDetected,
      );
    }).toList();

    // Emit the updated device list with their statuses
    emit(state.copyWith(devices: updatedDevices));
  }

  Map<String, DeviceConnectionStatus> deviceListStatusMap(
      List<AdbDevice> maps,) {
    return Map.fromEntries(maps.map((e) => MapEntry(e.serialNumber, e.status)));
  }


  Future<void> refresh() async {
    emit(state.copyWith(isRefreshing: true));
    var deviceList = state.devices;
    if (deviceList.isEmpty) {
      return;
    }

    var adbDeviceList = await _commandService.deviceList();
    Map<String, DeviceConnectionStatus> deviceStatusMap = deviceListStatusMap(
      adbDeviceList,
    );

    final updatedDevices =
    deviceList.map((device) {
      return device.copyWith(
        status:
        deviceStatusMap[device.ip] ??
            DeviceConnectionStatus.notDetected,
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

    await _commandService.runCommandOnMultipleDevices(
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
}