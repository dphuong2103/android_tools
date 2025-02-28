
import 'package:freezed_annotation/freezed_annotation.dart';
part 'adb_device.freezed.dart';
part 'adb_device.g.dart';

class AdbDeviceStatus{
  static final String connected = "connected";
  static final String notConnected = "not_connected";
  static final String unAuthorized = "unauthorized";
}

@freezed
class AdbDevice with _$AdbDevice {
  factory AdbDevice({
    required String serialNumber,
    @Default("not_connected") String? status,
  }) = _AdbDevice;

  factory AdbDevice.fromJson(Map<String, dynamic> json) => _$AdbDeviceFromJson(json);
}
