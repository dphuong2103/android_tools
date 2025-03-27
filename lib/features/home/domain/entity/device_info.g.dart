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
      macAddress: json['macAddress'] as String?,
      fingerprint: json['fingerprint'] as String,
      androidId: json['androidId'] as String,
      ssid: json['ssid'] as String?,
      longitude: json['longitude'] as String?,
      latitude: json['latitude'] as String?,
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
      'macAddress': instance.macAddress,
      'fingerprint': instance.fingerprint,
      'androidId': instance.androidId,
      'ssid': instance.ssid,
      'longitude': instance.longitude,
      'latitude': instance.latitude,
    };
