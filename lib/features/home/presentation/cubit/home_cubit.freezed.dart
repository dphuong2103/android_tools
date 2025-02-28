// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$HomeState {
  List<Device> get devices => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;
  bool get isAddingDevice => throw _privateConstructorUsedError;
  bool get isRefreshing => throw _privateConstructorUsedError;
  bool get isConnectingAll => throw _privateConstructorUsedError;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $HomeStateCopyWith<HomeState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $HomeStateCopyWith<$Res> {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) then) =
      _$HomeStateCopyWithImpl<$Res, HomeState>;
  @useResult
  $Res call({
    List<Device> devices,
    String? error,
    bool isAddingDevice,
    bool isRefreshing,
    bool isConnectingAll,
  });
}

/// @nodoc
class _$HomeStateCopyWithImpl<$Res, $Val extends HomeState>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devices = null,
    Object? error = freezed,
    Object? isAddingDevice = null,
    Object? isRefreshing = null,
    Object? isConnectingAll = null,
  }) {
    return _then(
      _value.copyWith(
            devices:
                null == devices
                    ? _value.devices
                    : devices // ignore: cast_nullable_to_non_nullable
                        as List<Device>,
            error:
                freezed == error
                    ? _value.error
                    : error // ignore: cast_nullable_to_non_nullable
                        as String?,
            isAddingDevice:
                null == isAddingDevice
                    ? _value.isAddingDevice
                    : isAddingDevice // ignore: cast_nullable_to_non_nullable
                        as bool,
            isRefreshing:
                null == isRefreshing
                    ? _value.isRefreshing
                    : isRefreshing // ignore: cast_nullable_to_non_nullable
                        as bool,
            isConnectingAll:
                null == isConnectingAll
                    ? _value.isConnectingAll
                    : isConnectingAll // ignore: cast_nullable_to_non_nullable
                        as bool,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$HomeStateImplCopyWith<$Res>
    implements $HomeStateCopyWith<$Res> {
  factory _$$HomeStateImplCopyWith(
    _$HomeStateImpl value,
    $Res Function(_$HomeStateImpl) then,
  ) = __$$HomeStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    List<Device> devices,
    String? error,
    bool isAddingDevice,
    bool isRefreshing,
    bool isConnectingAll,
  });
}

/// @nodoc
class __$$HomeStateImplCopyWithImpl<$Res>
    extends _$HomeStateCopyWithImpl<$Res, _$HomeStateImpl>
    implements _$$HomeStateImplCopyWith<$Res> {
  __$$HomeStateImplCopyWithImpl(
    _$HomeStateImpl _value,
    $Res Function(_$HomeStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? devices = null,
    Object? error = freezed,
    Object? isAddingDevice = null,
    Object? isRefreshing = null,
    Object? isConnectingAll = null,
  }) {
    return _then(
      _$HomeStateImpl(
        devices:
            null == devices
                ? _value._devices
                : devices // ignore: cast_nullable_to_non_nullable
                    as List<Device>,
        error:
            freezed == error
                ? _value.error
                : error // ignore: cast_nullable_to_non_nullable
                    as String?,
        isAddingDevice:
            null == isAddingDevice
                ? _value.isAddingDevice
                : isAddingDevice // ignore: cast_nullable_to_non_nullable
                    as bool,
        isRefreshing:
            null == isRefreshing
                ? _value.isRefreshing
                : isRefreshing // ignore: cast_nullable_to_non_nullable
                    as bool,
        isConnectingAll:
            null == isConnectingAll
                ? _value.isConnectingAll
                : isConnectingAll // ignore: cast_nullable_to_non_nullable
                    as bool,
      ),
    );
  }
}

/// @nodoc

class _$HomeStateImpl implements _HomeState {
  const _$HomeStateImpl({
    final List<Device> devices = const [],
    this.error,
    this.isAddingDevice = false,
    this.isRefreshing = false,
    this.isConnectingAll = false,
  }) : _devices = devices;

  final List<Device> _devices;
  @override
  @JsonKey()
  List<Device> get devices {
    if (_devices is EqualUnmodifiableListView) return _devices;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_devices);
  }

  @override
  final String? error;
  @override
  @JsonKey()
  final bool isAddingDevice;
  @override
  @JsonKey()
  final bool isRefreshing;
  @override
  @JsonKey()
  final bool isConnectingAll;

  @override
  String toString() {
    return 'HomeState(devices: $devices, error: $error, isAddingDevice: $isAddingDevice, isRefreshing: $isRefreshing, isConnectingAll: $isConnectingAll)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$HomeStateImpl &&
            const DeepCollectionEquality().equals(other._devices, _devices) &&
            (identical(other.error, error) || other.error == error) &&
            (identical(other.isAddingDevice, isAddingDevice) ||
                other.isAddingDevice == isAddingDevice) &&
            (identical(other.isRefreshing, isRefreshing) ||
                other.isRefreshing == isRefreshing) &&
            (identical(other.isConnectingAll, isConnectingAll) ||
                other.isConnectingAll == isConnectingAll));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    const DeepCollectionEquality().hash(_devices),
    error,
    isAddingDevice,
    isRefreshing,
    isConnectingAll,
  );

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      __$$HomeStateImplCopyWithImpl<_$HomeStateImpl>(this, _$identity);
}

abstract class _HomeState implements HomeState {
  const factory _HomeState({
    final List<Device> devices,
    final String? error,
    final bool isAddingDevice,
    final bool isRefreshing,
    final bool isConnectingAll,
  }) = _$HomeStateImpl;

  @override
  List<Device> get devices;
  @override
  String? get error;
  @override
  bool get isAddingDevice;
  @override
  bool get isRefreshing;
  @override
  bool get isConnectingAll;

  /// Create a copy of HomeState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$HomeStateImplCopyWith<_$HomeStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
