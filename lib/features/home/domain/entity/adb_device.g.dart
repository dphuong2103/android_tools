// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'adb_device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AdbDeviceImpl _$$AdbDeviceImplFromJson(Map<String, dynamic> json) =>
    _$AdbDeviceImpl(
      serialNumber: json['serialNumber'] as String,
      status:
          $enumDecodeNullable(
            _$DeviceConnectionStatusEnumMap,
            json['status'],
          ) ??
          DeviceConnectionStatus.unknown,
    );

Map<String, dynamic> _$$AdbDeviceImplToJson(_$AdbDeviceImpl instance) =>
    <String, dynamic>{
      'serialNumber': instance.serialNumber,
      'status': _$DeviceConnectionStatusEnumMap[instance.status]!,
    };

const _$DeviceConnectionStatusEnumMap = {
  DeviceConnectionStatus.fastboot: 'fastboot',
  DeviceConnectionStatus.booted: 'booted',
  DeviceConnectionStatus.twrp: 'twrp',
  DeviceConnectionStatus.recovery: 'recovery',
  DeviceConnectionStatus.sideload: 'sideload',
  DeviceConnectionStatus.unknown: 'unknown',
  DeviceConnectionStatus.notDetected: 'notDetected',
};
