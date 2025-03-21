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
    required String macSuffix,
    required String fingerprint,
    required String androidId,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

final List<DeviceInfo> deviceInfoList = [
  // Xiaomi Mi A1 (Android 9)
  // DeviceInfo(
  //   model: "Mi A1",
  //   brand: "Xiaomi",
  //   manufacturer: "Xiaomi",
  //   serialNo: "XMI${_generateSerialSuffix(7)}",
  //   device: "tissot",
  //   productName: "tissot_sprout",
  //   releaseVersion: "9",
  //   sdkVersion: "28",
  //   macSuffix: "A1:BC",
  //   fingerprint: "xiaomi/tissot/tissot_sprout:9/PKQ1.180917.001/V9.6.17.0.ODHMIFE:user/release-keys",
  //   androidId: _generateAndroidId(),
  // ),
  // // Xiaomi Mi A1 (Android 10 - Custom ROM)
  // DeviceInfo(
  //   model: "Mi A1",
  //   brand: "Xiaomi",
  //   manufacturer: "Xiaomi",
  //   serialNo: "XMI${_generateSerialSuffix(7)}",
  //   device: "tissot",
  //   productName: "tissot",
  //   releaseVersion: "10",
  //   sdkVersion: "29",
  //   macSuffix: "A1:DE",
  //   fingerprint: "LineageOS/tissot/tissot:10/QKQ1.191014.001/12345678:user/release-keys",
  //   androidId: _generateAndroidId(),
  // ),
  // Xiaomi Redmi Note 7 (Android 10)
  DeviceInfo(
    model: "Redmi Note 7",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "XMI${_generateSerialSuffix(7)}",
    device: "lavender",
    productName: "lavender",
    releaseVersion: "10",
    sdkVersion: "29",
    macSuffix: "RN7:FG",
    fingerprint:
        "xiaomi/lavender/lavender:10/QKQ1.190910.002/V12.5.1.0.QFGMIXM:user/release-keys",
    androidId: _generateAndroidId(),
  ),
  // Realme 6 (Android 10)
  DeviceInfo(
    model: "Realme 6",
    brand: "Realme",
    manufacturer: "Oppo",
    serialNo: "RM${_generateSerialSuffix(7)}",
    device: "RMX2001",
    productName: "RMX2001",
    releaseVersion: "10",
    sdkVersion: "29",
    macSuffix: "R6:HI",
    fingerprint:
        "realme/RMX2001/RMX2001:10/QKQ1.200209.002/1591234567:user/release-keys",
    androidId: _generateAndroidId(),
  ),
  // Huawei P30 Lite (Android 10)
  DeviceInfo(
    model: "P30 Lite",
    brand: "Huawei",
    manufacturer: "Huawei",
    serialNo: "HUA${_generateSerialSuffix(7)}",
    device: "marie",
    productName: "marie",
    releaseVersion: "10",
    sdkVersion: "29",
    macSuffix: "P30L:JK",
    fingerprint:
        "huawei/marie/marie:10/HUAWEIMAR-LX1M/10.0.0.195(C432E5R1P1):user/release-keys",
    androidId: _generateAndroidId(),
  ),
];

String _generateSerialSuffix(int length) {
  const chars = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      length,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}

String _generateAndroidId() {
  // Android ID is a 16-character hex string
  const chars = '0123456789abcdef';
  final random = Random();
  return String.fromCharCodes(
    Iterable.generate(
      16,
      (_) => chars.codeUnitAt(random.nextInt(chars.length)),
    ),
  );
}
