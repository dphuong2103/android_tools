import 'package:freezed_annotation/freezed_annotation.dart';

part 'device.freezed.dart';
part 'device.g.dart';

class DeviceStatus{
  static final String connected = "connected";
  static final String notConnected = "not_connected";
  static final String unAuthorized = "unauthorized";
}

class DeviceCommandStatus{
  static final String inProgress = "In Progress";
  static final String success = "Success";
  static final String failed = "Error";
}


@freezed
class Device with _$Device {
  factory Device({
    required String ip,
    @Default("not_connected") String? status,
    @Default(false) bool isSelected,
    String? commandStatus,
    String? geo,
  }) = _Device;

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
}
