
import 'package:freezed_annotation/freezed_annotation.dart';
part 'adb_device.freezed.dart';
part 'adb_device.g.dart';

enum DeviceConnectionStatus {
  fastboot,
  booted,
  twrp,
  recovery,
  sideload,
  unknown,
  notDetected,
}

@freezed
class AdbDevice with _$AdbDevice {
  factory AdbDevice({
    required String serialNumber,
    @Default(DeviceConnectionStatus.unknown) DeviceConnectionStatus status,
  }) = _AdbDevice;

  factory AdbDevice.fromJson(Map<String, dynamic> json) => _$AdbDeviceFromJson(json);
}
