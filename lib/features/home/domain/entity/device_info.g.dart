// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_info.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceInfoImpl _$$DeviceInfoImplFromJson(Map<String, dynamic> json) =>
    _$DeviceInfoImpl(
      model: json['model'] as String,
      brand: json['brand'] as String,
      manufacturer: json['manufacturer'] as String,
      serialNo: json['serialNo'] as String,
      device: json['device'] as String,
      productName: json['productName'] as String,
      releaseVersion: json['releaseVersion'] as String,
      sdkVersion: json['sdkVersion'] as String,
      fingerprint: json['fingerprint'] as String,
      androidId: json['androidId'] as String,
      imei: json['imei'] as String,
      advertisingId: json['advertisingId'] as String?,
      ssid: json['ssid'] as String?,
      macAddress: json['macAddress'] as String?,
      height: (json['height'] as num?)?.toInt(),
      width: (json['width'] as num?)?.toInt(),
    );

Map<String, dynamic> _$$DeviceInfoImplToJson(_$DeviceInfoImpl instance) =>
    <String, dynamic>{
      'model': instance.model,
      'brand': instance.brand,
      'manufacturer': instance.manufacturer,
      'serialNo': instance.serialNo,
      'device': instance.device,
      'productName': instance.productName,
      'releaseVersion': instance.releaseVersion,
      'sdkVersion': instance.sdkVersion,
      'fingerprint': instance.fingerprint,
      'androidId': instance.androidId,
      'imei': instance.imei,
      'advertisingId': instance.advertisingId,
      'ssid': instance.ssid,
      'macAddress': instance.macAddress,
      'height': instance.height,
      'width': instance.width,
    };
