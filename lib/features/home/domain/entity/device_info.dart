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
    required String fingerprint,
    required String androidId,
    required String imei,
    String? advertisingId,
    String? ssid,
    String? macAddress,
    int? height,
    int? width,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

final List<DeviceInfo> deviceInfoList = [
  // Xiaomi Mi A1 (Original Device)
  DeviceInfo(
    model: "Mi A1",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "",
    device: "tissot",
    productName: "tissot",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/tissot/tissot:10/QKQ1.190910.002/V11.0.9.0.QDQMIXM:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 1920,
  ),

  // Xiaomi Redmi Note 7
  DeviceInfo(
    model: "Redmi Note 7",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "",
    device: "lavender",
    productName: "lavender",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/lavender/lavender:10/QKQ1.190910.002/V11.0.5.0.QFGMIXM:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2340,
  ),

  // Xiaomi Mi 8 Lite
  DeviceInfo(
    model: "Mi 8 Lite",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "",
    device: "platina",
    productName: "platina",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/platina/platina:10/QKQ1.190910.002/V11.0.2.0.QDTMIXM:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2280,
  ),

  // Xiaomi Redmi 8
  DeviceInfo(
    model: "Redmi 8",
    brand: "Xiaomi",
    manufacturer: "Xiaomi",
    serialNo: "",
    device: "olive",
    productName: "olive",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Xiaomi/olive/olive:10/QKQ1.191008.001/V11.0.3.0.QCCMIXM:user/release-keys",
    androidId: "",
    imei: "",
    width: 720,
    height: 1520, // Slightly lower resolution, but still close
  ),

  // Samsung Galaxy A50
  DeviceInfo(
    model: "SM-A505F",
    brand: "Samsung",
    manufacturer: "Samsung",
    serialNo: "",
    device: "a50",
    productName: "a50",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "samsung/a50/a50:10/QP1A.190711.020/A505FXXU5BTG3:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2340,
  ),

  // Samsung Galaxy M31
  DeviceInfo(
    model: "SM-M315F",
    brand: "Samsung",
    manufacturer: "Samsung",
    serialNo: "",
    device: "m31",
    productName: "m31",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "samsung/m31/m31:10/QP1A.190711.020/M315FXXU2ATG2:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2340,
  ),

  // Samsung Galaxy S9
  DeviceInfo(
    model: "SM-G960F",
    brand: "Samsung",
    manufacturer: "Samsung",
    serialNo: "",
    device: "starlte",
    productName: "starlte",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "samsung/starlte/starlte:10/QP1A.190711.020/G960FXXUFUEB1:user/release-keys",
    androidId: "",
    imei: "",
    width: 1440,
    height: 2960, // Slightly higher, but plausible for flagship
  ),

  // OnePlus 6T
  DeviceInfo(
    model: "A6010",
    brand: "OnePlus",
    manufacturer: "OnePlus",
    serialNo: "",
    device: "OnePlus6T",
    productName: "OnePlus6T",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "OnePlus/OnePlus6T/OnePlus6T:10/QKQ1.190716.003/2003031830:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2340,
  ),

  // OnePlus Nord
  DeviceInfo(
    model: "AC2003",
    brand: "OnePlus",
    manufacturer: "OnePlus",
    serialNo: "",
    device: "avicii",
    productName: "avicii",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "OnePlus/avicii/avicii:10/QKQ1.200114.002/2003031830:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2400,
  ),

  // Google Pixel 3
  DeviceInfo(
    model: "Pixel 3",
    brand: "Google",
    manufacturer: "Google",
    serialNo: "",
    device: "blueline",
    productName: "blueline",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "google/blueline/blueline:10/QP1A.191005.007/5878912:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2160,
  ),

  // Google Pixel 4a
  DeviceInfo(
    model: "Pixel 4a",
    brand: "Google",
    manufacturer: "Google",
    serialNo: "",
    device: "sunfish",
    productName: "sunfish",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "google/sunfish/sunfish:10/QD1A.200317.002/6174812:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2340,
  ),

  // Sony Xperia 10 II
  DeviceInfo(
    model: "XQ-AU52",
    brand: "Sony",
    manufacturer: "Sony",
    serialNo: "",
    device: "XQ-AU52",
    productName: "XQ-AU52",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Sony/XQ-AU52/XQ-AU52:10/59.1.A.3.49/123456789:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2520, // Slightly taller, but close
  ),

  // Sony Xperia 5
  DeviceInfo(
    model: "J8210",
    brand: "Sony",
    manufacturer: "Sony",
    serialNo: "",
    device: "J8210",
    productName: "J8210",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Sony/J8210/J8210:10/55.1.A.3.49/123456789:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2520,
  ),

  // Huawei P40 Lite
  DeviceInfo(
    model: "JNY-LX1",
    brand: "Huawei",
    manufacturer: "Huawei",
    serialNo: "",
    device: "JNY",
    productName: "JNY",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Huawei/JNY-LX1/JNY:10/HUAWEIJNY-LX1/10.0.0.185:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2310,
  ),

  // Oppo A72
  DeviceInfo(
    model: "CPH2067",
    brand: "Oppo",
    manufacturer: "Oppo",
    serialNo: "",
    device: "CPH2067",
    productName: "CPH2067",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "Oppo/CPH2067/CPH2067:10/QKQ1.200209.002/1591234567:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2400,
  ),

  // Realme 6
  DeviceInfo(
    model: "RMX2001",
    brand: "Realme",
    manufacturer: "Realme",
    serialNo: "",
    device: "RMX2001",
    productName: "RMX2001",
    releaseVersion: "10",
    sdkVersion: "29",
    fingerprint: "realme/RMX2001/RMX2001:10/QKQ1.200209.002/1591234567:user/release-keys",
    androidId: "",
    imei: "",
    width: 1080,
    height: 2400,
  ),
];