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
    required String subscriberId,
    required String advertisingId,
    required String? ssid,
    required String? macAddress,
    required int? height,
    required int? width,
    required String androidSerial,
    required String phoneNumber,
    required String glVendor,
    required String glRender,
    required String hardware,
    required String id,
    required String host,
    required String radio,
    required String bootloader,
    required String display,
    required String board,
    required String codename,
    required String serialSimNumber,
    required String bssid,
    required String operator,
    required String operatorName,
    required String countryIso,
    required String userAgent,
    required String osVersion,
    required String macHardware,
    required String wifiIp,
    required String versionChrome,
  }) = _DeviceInfo;

  factory DeviceInfo.fromJson(Map<String, dynamic> json) =>
      _$DeviceInfoFromJson(json);
}

extension DeviceInfoPrettyPrint on DeviceInfo {
  String customToString() {
    return '''
Model: $model
Brand: $brand
Manufacturer: $manufacturer
SerialNo: $serialNo
Device: $device
ProductName: $productName
ReleaseVersion: $releaseVersion
SdkVersion: $sdkVersion
Fingerprint: $fingerprint
AndroidId: $androidId
IMEI: $imei
AdvertisingId: ${advertisingId ?? 'N/A'}
SSID: ${ssid ?? 'N/A'}
MacAddress: ${macAddress ?? 'N/A'}
Height: ${height ?? 'N/A'}
Width: ${width ?? 'N/A'}
''';
  }
}

