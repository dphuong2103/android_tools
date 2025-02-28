// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'adb_device.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AdbDevice _$AdbDeviceFromJson(Map<String, dynamic> json) {
  return _AdbDevice.fromJson(json);
}

/// @nodoc
mixin _$AdbDevice {
  String get serialNumber => throw _privateConstructorUsedError;
  String? get status => throw _privateConstructorUsedError;

  /// Serializes this AdbDevice to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AdbDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AdbDeviceCopyWith<AdbDevice> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AdbDeviceCopyWith<$Res> {
  factory $AdbDeviceCopyWith(AdbDevice value, $Res Function(AdbDevice) then) =
      _$AdbDeviceCopyWithImpl<$Res, AdbDevice>;
  @useResult
  $Res call({String serialNumber, String? status});
}

/// @nodoc
class _$AdbDeviceCopyWithImpl<$Res, $Val extends AdbDevice>
    implements $AdbDeviceCopyWith<$Res> {
  _$AdbDeviceCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AdbDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? serialNumber = null, Object? status = freezed}) {
    return _then(
      _value.copyWith(
            serialNumber:
                null == serialNumber
                    ? _value.serialNumber
                    : serialNumber // ignore: cast_nullable_to_non_nullable
                        as String,
            status:
                freezed == status
                    ? _value.status
                    : status // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AdbDeviceImplCopyWith<$Res>
    implements $AdbDeviceCopyWith<$Res> {
  factory _$$AdbDeviceImplCopyWith(
    _$AdbDeviceImpl value,
    $Res Function(_$AdbDeviceImpl) then,
  ) = __$$AdbDeviceImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String serialNumber, String? status});
}

/// @nodoc
class __$$AdbDeviceImplCopyWithImpl<$Res>
    extends _$AdbDeviceCopyWithImpl<$Res, _$AdbDeviceImpl>
    implements _$$AdbDeviceImplCopyWith<$Res> {
  __$$AdbDeviceImplCopyWithImpl(
    _$AdbDeviceImpl _value,
    $Res Function(_$AdbDeviceImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AdbDevice
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? serialNumber = null, Object? status = freezed}) {
    return _then(
      _$AdbDeviceImpl(
        serialNumber:
            null == serialNumber
                ? _value.serialNumber
                : serialNumber // ignore: cast_nullable_to_non_nullable
                    as String,
        status:
            freezed == status
                ? _value.status
                : status // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AdbDeviceImpl implements _AdbDevice {
  _$AdbDeviceImpl({required this.serialNumber, this.status = "not_connected"});

  factory _$AdbDeviceImpl.fromJson(Map<String, dynamic> json) =>
      _$$AdbDeviceImplFromJson(json);

  @override
  final String serialNumber;
  @override
  @JsonKey()
  final String? status;

  @override
  String toString() {
    return 'AdbDevice(serialNumber: $serialNumber, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AdbDeviceImpl &&
            (identical(other.serialNumber, serialNumber) ||
                other.serialNumber == serialNumber) &&
            (identical(other.status, status) || other.status == status));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, serialNumber, status);

  /// Create a copy of AdbDevice
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AdbDeviceImplCopyWith<_$AdbDeviceImpl> get copyWith =>
      __$$AdbDeviceImplCopyWithImpl<_$AdbDeviceImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AdbDeviceImplToJson(this);
  }
}

abstract class _AdbDevice implements AdbDevice {
  factory _AdbDevice({
    required final String serialNumber,
    final String? status,
  }) = _$AdbDeviceImpl;

  factory _AdbDevice.fromJson(Map<String, dynamic> json) =
      _$AdbDeviceImpl.fromJson;

  @override
  String get serialNumber;
  @override
  String? get status;

  /// Create a copy of AdbDevice
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AdbDeviceImplCopyWith<_$AdbDeviceImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
