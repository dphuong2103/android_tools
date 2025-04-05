import 'package:freezed_annotation/freezed_annotation.dart';

import 'adb_device.dart';

part 'device.freezed.dart';

part 'device.g.dart';

class DeviceCommandStatus {
  static final String inProgress = "In Progress";
  static final String success = "Success";
  static final String failed = "Error";
}

@freezed
class Device with _$Device {
  factory Device({
    required String ip,
    @Default(DeviceConnectionStatus.notDetected) DeviceConnectionStatus status,
    @Default(false) bool isSelected,
    String? commandStatus,
    String? geo,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
