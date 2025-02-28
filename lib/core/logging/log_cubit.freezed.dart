// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'log_cubit.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$LogState {
  List<Log> get logs => throw _privateConstructorUsedError;

  /// Create a copy of LogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $LogStateCopyWith<LogState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $LogStateCopyWith<$Res> {
  factory $LogStateCopyWith(LogState value, $Res Function(LogState) then) =
      _$LogStateCopyWithImpl<$Res, LogState>;
  @useResult
  $Res call({List<Log> logs});
}

/// @nodoc
class _$LogStateCopyWithImpl<$Res, $Val extends LogState>
    implements $LogStateCopyWith<$Res> {
  _$LogStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of LogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? logs = null}) {
    return _then(
      _value.copyWith(
            logs:
                null == logs
                    ? _value.logs
                    : logs // ignore: cast_nullable_to_non_nullable
                        as List<Log>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$LogStateImplCopyWith<$Res>
    implements $LogStateCopyWith<$Res> {
  factory _$$LogStateImplCopyWith(
    _$LogStateImpl value,
    $Res Function(_$LogStateImpl) then,
  ) = __$$LogStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({List<Log> logs});
}

/// @nodoc
class __$$LogStateImplCopyWithImpl<$Res>
    extends _$LogStateCopyWithImpl<$Res, _$LogStateImpl>
    implements _$$LogStateImplCopyWith<$Res> {
  __$$LogStateImplCopyWithImpl(
    _$LogStateImpl _value,
    $Res Function(_$LogStateImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of LogState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? logs = null}) {
    return _then(
      _$LogStateImpl(
        logs:
            null == logs
                ? _value._logs
                : logs // ignore: cast_nullable_to_non_nullable
                    as List<Log>,
      ),
    );
  }
}

/// @nodoc

class _$LogStateImpl implements _LogState {
  const _$LogStateImpl({final List<Log> logs = const []}) : _logs = logs;

  final List<Log> _logs;
  @override
  @JsonKey()
  List<Log> get logs {
    if (_logs is EqualUnmodifiableListView) return _logs;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_logs);
  }

  @override
  String toString() {
    return 'LogState(logs: $logs)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$LogStateImpl &&
            const DeepCollectionEquality().equals(other._logs, _logs));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, const DeepCollectionEquality().hash(_logs));

  /// Create a copy of LogState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$LogStateImplCopyWith<_$LogStateImpl> get copyWith =>
      __$$LogStateImplCopyWithImpl<_$LogStateImpl>(this, _$identity);
}

abstract class _LogState implements LogState {
  const factory _LogState({final List<Log> logs}) = _$LogStateImpl;

  @override
  List<Log> get logs;

  /// Create a copy of LogState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$LogStateImplCopyWith<_$LogStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
