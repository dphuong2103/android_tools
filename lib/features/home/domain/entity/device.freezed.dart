// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Device _$DeviceFromJson(Map<String, dynamic> json) {
  return _Device.fromJson(json);
}

/// @nodoc
mixin _$Device {
  String get ip => throw _privateConstructorUsedError;
  DeviceConnectionStatus get status => throw _privateConstructorUsedError;
  bool get isSelected => throw _privateConstructorUsedError;
  String? get commandStatus => throw _privateConstructorUsedError;
  String? get geo => throw _privateConstructorUsedError;

  /// Serializes this Device to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceCopyWith<Device> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceCopyWith<$Res> {
  factory $DeviceCopyWith(Device value, $Res Function(Device) then) =
      _$DeviceCopyWithImpl<$Res, Device>;
  @useResult
  $Res call({
    String ip,
    DeviceConnectionStatus status,
    bool isSelected,
    String? commandStatus,
    String? geo,
  });
}

/// @nodoc
class _$DeviceCopyWithImpl<$Res, $Val extends Device>
    implements $DeviceCopyWith<$Res> {
  _$DeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ip = null,
    Object? status = null,
    Object? isSelected = null,
    Object? commandStatus = freezed,
    Object? geo = freezed,
  }) {
    return _then(
      _value.copyWith(
            ip:
                null == ip
                    ? _value.ip
                    : ip // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                null == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as DeviceConnectionStatus,
            isSelected:
                null == isSelected
                    ? _value.isSelected
                    : isSelected // ignore: cast_nullable_to_non_nullable
                        as bool,
            commandStatus:
                freezed == commandStatus
                    ? _value.commandStatus
                    : commandStatus // ignore: cast_nullable_to_non_nullable
                        as String?,
            geo:
                freezed == geo
                    ? _value.geo
                    : geo // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceImplCopyWith<$Res> implements $DeviceCopyWith<$Res> {
  factory _$$DeviceImplCopyWith(
    _$DeviceImpl value,
    $Res Function(_$DeviceImpl) then,
  ) = __$$DeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String ip,
    DeviceConnectionStatus status,
    bool isSelected,
    String? commandStatus,
    String? geo,
  });
}

/// @nodoc
class __$$DeviceImplCopyWithImpl<$Res>
    extends _$DeviceCopyWithImpl<$Res, _$DeviceImpl>
    implements _$$DeviceImplCopyWith<$Res> {
  __$$DeviceImplCopyWithImpl(
    _$DeviceImpl _value,
    $Res Function(_$DeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? ip = null,
    Object? status = null,
    Object? isSelected = null,
    Object? commandStatus = freezed,
    Object? geo = freezed,
  }) {
    return _then(
      _$DeviceImpl(
        ip:
            null == ip
                ? _value.ip
                : ip // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            null == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as DeviceConnectionStatus,
        isSelected:
            null == isSelected
                ? _value.isSelected
                : isSelected // ignore: cast_nullable_to_non_nullable
                    as bool,
        commandStatus:
            freezed == commandStatus
                ? _value.commandStatus
                : commandStatus // ignore: cast_nullable_to_non_nullable
                    as String?,
        geo:
            freezed == geo
                ? _value.geo
                : geo // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceImpl implements _Device {
  _$DeviceImpl({
    required this.ip,
    this.status = DeviceConnectionStatus.notDetected,
    this.isSelected = false,
    this.commandStatus,
    this.geo,
  });

  factory _$DeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceImplFromJson(json);

  @override
  final String ip;
  @override
  @JsonKey()
  final DeviceConnectionStatus status;
  @override
  @JsonKey()
  final bool isSelected;
  @override
  final String? commandStatus;
  @override
  final String? geo;

  @override
  String toString() {
    return 'Device(ip: $ip, status: $status, isSelected: $isSelected, commandStatus: $commandStatus, geo: $geo)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceImpl &&
            (identical(other.ip, ip) || other.ip == ip) &&
            (identical(other.status, status) || other.status == status) &&
            (identical(other.isSelected, isSelected) ||
                other.isSelected == isSelected) &&
            (identical(other.commandStatus, commandStatus) ||
                other.commandStatus == commandStatus) &&
            (identical(other.geo, geo) || other.geo == geo));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, ip, status, isSelected, commandStatus, geo);

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      __$$DeviceImplCopyWithImpl<_$DeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceImplToJson(this);
  }
}

abstract class _Device implements Device {
  factory _Device({
    required final String ip,
    final DeviceConnectionStatus status,
    final bool isSelected,
    final String? commandStatus,
    final String? geo,
  }) = _$DeviceImpl;

  factory _Device.fromJson(Map<String, dynamic> json) = _$DeviceImpl.fromJson;

  @override
  String get ip;
  @override
  DeviceConnectionStatus get status;
  @override
  bool get isSelected;
  @override
  String? get commandStatus;
  @override
  String? get geo;

  /// Create a copy of Device
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceImplCopyWith<_$DeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
