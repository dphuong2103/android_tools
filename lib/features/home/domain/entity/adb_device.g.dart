// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adb_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdbDeviceImpl _$$AdbDeviceImplFromJson(Map<String, dynamic> json) =>
    _$AdbDeviceImpl(
      serialNumber: json['serialNumber'] as String,
      status: json['status'] as String? ?? "not_connected",
    );

Map<String, dynamic> _$$AdbDeviceImplToJson(_$AdbDeviceImpl instance) =>
    <String, dynamic>{
      'serialNumber': instance.serialNumber,
      'status': instance.status,
    };
