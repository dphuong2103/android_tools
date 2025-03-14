// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_batch.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeviceBatch _$DeviceBatchFromJson(Map<String, dynamic> json) {
  return _DeviceBatch.fromJson(json);
}

/// @nodoc
mixin _$DeviceBatch {
  String get batchId => throw _privateConstructorUsedError;
  String get device_serial_number => throw _privateConstructorUsedError;

  /// Serializes this DeviceBatch to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceBatchCopyWith<DeviceBatch> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceBatchCopyWith<$Res> {
  factory $DeviceBatchCopyWith(
    DeviceBatch value,
    $Res Function(DeviceBatch) then,
  ) = _$DeviceBatchCopyWithImpl<$Res, DeviceBatch>;
  @useResult
  $Res call({String batchId, String device_serial_number});
}

/// @nodoc
class _$DeviceBatchCopyWithImpl<$Res, $Val extends DeviceBatch>
    implements $DeviceBatchCopyWith<$Res> {
  _$DeviceBatchCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? batchId = null, Object? device_serial_number = null}) {
    return _then(
      _value.copyWith(
            batchId:
                null == batchId
                    ? _value.batchId
                    : batchId // ignore: cast_nullable_to_non_nullable
                        as String,
            device_serial_number:
                null == device_serial_number
                    ? _value.device_serial_number
                    : device_serial_number // ignore: cast_nullable_to_non_nullable
                        as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceBatchImplCopyWith<$Res>
    implements $DeviceBatchCopyWith<$Res> {
  factory _$$DeviceBatchImplCopyWith(
    _$DeviceBatchImpl value,
    $Res Function(_$DeviceBatchImpl) then,
  ) = __$$DeviceBatchImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String batchId, String device_serial_number});
}

/// @nodoc
class __$$DeviceBatchImplCopyWithImpl<$Res>
    extends _$DeviceBatchCopyWithImpl<$Res, _$DeviceBatchImpl>
    implements _$$DeviceBatchImplCopyWith<$Res> {
  __$$DeviceBatchImplCopyWithImpl(
    _$DeviceBatchImpl _value,
    $Res Function(_$DeviceBatchImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceBatch
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? batchId = null, Object? device_serial_number = null}) {
    return _then(
      _$DeviceBatchImpl(
        batchId:
            null == batchId
                ? _value.batchId
                : batchId // ignore: cast_nullable_to_non_nullable
                    as String,
        device_serial_number:
            null == device_serial_number
                ? _value.device_serial_number
                : device_serial_number // ignore: cast_nullable_to_non_nullable
                    as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceBatchImpl implements _DeviceBatch {
  _$DeviceBatchImpl({
    required this.batchId,
    required this.device_serial_number,
  });

  factory _$DeviceBatchImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceBatchImplFromJson(json);

  @override
  final String batchId;
  @override
  final String device_serial_number;

  @override
  String toString() {
    return 'DeviceBatch(batchId: $batchId, device_serial_number: $device_serial_number)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceBatchImpl &&
            (identical(other.batchId, batchId) || other.batchId == batchId) &&
            (identical(other.device_serial_number, device_serial_number) ||
                other.device_serial_number == device_serial_number));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, batchId, device_serial_number);

  /// Create a copy of DeviceBatch
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceBatchImplCopyWith<_$DeviceBatchImpl> get copyWith =>
      __$$DeviceBatchImplCopyWithImpl<_$DeviceBatchImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceBatchImplToJson(this);
  }
}

abstract class _DeviceBatch implements DeviceBatch {
  factory _DeviceBatch({
    required final String batchId,
    required final String device_serial_number,
  }) = _$DeviceBatchImpl;

  factory _DeviceBatch.fromJson(Map<String, dynamic> json) =
      _$DeviceBatchImpl.fromJson;

  @override
  String get batchId;
  @override
  String get device_serial_number;

  /// Create a copy of DeviceBatch
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceBatchImplCopyWith<_$DeviceBatchImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
