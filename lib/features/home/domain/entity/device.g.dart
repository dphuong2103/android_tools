// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$DeviceImpl _$$DeviceImplFromJson(Map<String, dynamic> json) => _$DeviceImpl(
  ip: json['ip'] as String,
  status: json['status'] as String? ?? "not_connected",
  isSelected: json['isSelected'] as bool? ?? false,
  commandStatus: json['commandStatus'] as String?,
  geo: json['geo'] as String?,
);

Map<String, dynamic> _$$DeviceImplToJson(_$DeviceImpl instance) =>
    <String, dynamic>{
      'ip': instance.ip,
      'status': instance.status,
      'isSelected': instance.isSelected,
      'commandStatus': instance.commandStatus,
      'geo': instance.geo,
    };
