import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_info.freezed.dart';

part 'device_info.g.dart';

@freezed
class DeviceInfo with _$DeviceInfo {
  factory DeviceInfo({
    required String model,
    required String brand,
    required String manufacturer,
    required String serialNo,
    required String device,
    required String productName,
    required String releaseVersion,
    required String sdkVersion,
    String? macAddress,
    required String fingerprint,
    required String androidId,
    String? ssid,
    String? longitude,
    String? latitude
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

final List<DeviceInfo> deviceInfoList = [
  DeviceInfo(
    model: "Mi A1",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "unknown", // Randomize this later
    device: "tissot",
    productName: "tissot",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/tissot/tissot:10/QKQ1.190910.002/V11.0.9.0.QDQMIXM:user/release-keys",
    androidId: "unknown", // Randomize this later
  ),
  // Xiaomi Redmi Note 8
  DeviceInfo(
    model: "Redmi Note 8",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "unknown",
    device: "ginkgo",
    productName: "ginkgo",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/ginkgo/ginkgo:10/QKQ1.190828.002/V12.0.3.0.QCOMIXM:user/release-keys",
    androidId: "unknown",
  ),
  // Xiaomi Mi 9T
  DeviceInfo(
    model: "Mi 9T",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "unknown",
    device: "davinci",
    productName: "davinci",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/davinci/davinci:10/QKQ1.190825.002/V12.0.2.0.QFJMIXM:user/release-keys",
    androidId: "unknown",
  ),
];
