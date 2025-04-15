import 'package:freezed_annotation/freezed_annotation.dart';

part 'base_device_info.freezed.dart';
part 'base_device_info.g.dart';

@freezed
class BaseDeviceInfo with _$BaseDeviceInfo {
  factory BaseDeviceInfo({
    required String model,
    required String brand,
    required String manufacturer,
    required String device,
    required String productName,
    required String releaseVersion,
    required String sdkVersion,
    required int width,
    required int height,
    required String glVendor,
    required String glRender,
    required String hardware,
    required String radio,
    required String bootloader,
    required String board,
    required String codename,
    required String macHardware,
    required String versionChrome,
    required String id,
    required String display,
  }) = _BaseDeviceInfo;

  factory BaseDeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$BaseDeviceInfoFromJson(json);
}