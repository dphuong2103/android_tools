// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'device_info.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

DeviceInfo _$DeviceInfoFromJson(Map<String, dynamic> json) {
  return _DeviceInfo.fromJson(json);
}

/// @nodoc
mixin _$DeviceInfo {
  String get model => throw _privateConstructorUsedError;
  String get brand => throw _privateConstructorUsedError;
  String get manufacturer => throw _privateConstructorUsedError;
  String get serialNo => throw _privateConstructorUsedError;
  String get device => throw _privateConstructorUsedError;
  String get productName => throw _privateConstructorUsedError;
  String get releaseVersion => throw _privateConstructorUsedError;
  String get sdkVersion => throw _privateConstructorUsedError;
  String get fingerprint => throw _privateConstructorUsedError;
  String get androidId => throw _privateConstructorUsedError;
  String get imei => throw _privateConstructorUsedError;
  String? get advertisingId => throw _privateConstructorUsedError;
  String? get ssid => throw _privateConstructorUsedError;
  String? get macAddress => throw _privateConstructorUsedError;
  int? get height => throw _privateConstructorUsedError;
  int? get width => throw _privateConstructorUsedError;

  /// Serializes this DeviceInfo to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $DeviceInfoCopyWith<DeviceInfo> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $DeviceInfoCopyWith<$Res> {
  factory $DeviceInfoCopyWith(
    DeviceInfo value,
    $Res Function(DeviceInfo) then,
  ) = _$DeviceInfoCopyWithImpl<$Res, DeviceInfo>;
  @useResult
  $Res call({
    String model,
    String brand,
    String manufacturer,
    String serialNo,
    String device,
    String productName,
    String releaseVersion,
    String sdkVersion,
    String fingerprint,
    String androidId,
    String imei,
    String? advertisingId,
    String? ssid,
    String? macAddress,
    int? height,
    int? width,
  });
}

/// @nodoc
class _$DeviceInfoCopyWithImpl<$Res, $Val extends DeviceInfo>
    implements $DeviceInfoCopyWith<$Res> {
  _$DeviceInfoCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? brand = null,
    Object? manufacturer = null,
    Object? serialNo = null,
    Object? device = null,
    Object? productName = null,
    Object? releaseVersion = null,
    Object? sdkVersion = null,
    Object? fingerprint = null,
    Object? androidId = null,
    Object? imei = null,
    Object? advertisingId = freezed,
    Object? ssid = freezed,
    Object? macAddress = freezed,
    Object? height = freezed,
    Object? width = freezed,
  }) {
    return _then(
      _value.copyWith(
            model:
                null == model
                    ? _value.model
                    : model // ignore: cast_nullable_to_non_nullable
                        as String,
            brand:
                null == brand
                    ? _value.brand
                    : brand // ignore: cast_nullable_to_non_nullable
                        as String,
            manufacturer:
                null == manufacturer
                    ? _value.manufacturer
                    : manufacturer // ignore: cast_nullable_to_non_nullable
                        as String,
            serialNo:
                null == serialNo
                    ? _value.serialNo
                    : serialNo // ignore: cast_nullable_to_non_nullable
                        as String,
            device:
                null == device
                    ? _value.device
                    : device // ignore: cast_nullable_to_non_nullable
                        as String,
            productName:
                null == productName
                    ? _value.productName
                    : productName // ignore: cast_nullable_to_non_nullable
                        as String,
            releaseVersion:
                null == releaseVersion
                    ? _value.releaseVersion
                    : releaseVersion // ignore: cast_nullable_to_non_nullable
                        as String,
            sdkVersion:
                null == sdkVersion
                    ? _value.sdkVersion
                    : sdkVersion // ignore: cast_nullable_to_non_nullable
                        as String,
            fingerprint:
                null == fingerprint
                    ? _value.fingerprint
                    : fingerprint // ignore: cast_nullable_to_non_nullable
                        as String,
            androidId:
                null == androidId
                    ? _value.androidId
                    : androidId // ignore: cast_nullable_to_non_nullable
                        as String,
            imei:
                null == imei
                    ? _value.imei
                    : imei // ignore: cast_nullable_to_non_nullable
                        as String,
            advertisingId:
                freezed == advertisingId
                    ? _value.advertisingId
                    : advertisingId // ignore: cast_nullable_to_non_nullable
                        as String?,
            ssid:
                freezed == ssid
                    ? _value.ssid
                    : ssid // ignore: cast_nullable_to_non_nullable
                        as String?,
            macAddress:
                freezed == macAddress
                    ? _value.macAddress
                    : macAddress // ignore: cast_nullable_to_non_nullable
                        as String?,
            height:
                freezed == height
                    ? _value.height
                    : height // ignore: cast_nullable_to_non_nullable
                        as int?,
            width:
                freezed == width
                    ? _value.width
                    : width // ignore: cast_nullable_to_non_nullable
                        as int?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$DeviceInfoImplCopyWith<$Res>
    implements $DeviceInfoCopyWith<$Res> {
  factory _$$DeviceInfoImplCopyWith(
    _$DeviceInfoImpl value,
    $Res Function(_$DeviceInfoImpl) then,
  ) = __$$DeviceInfoImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String model,
    String brand,
    String manufacturer,
    String serialNo,
    String device,
    String productName,
    String releaseVersion,
    String sdkVersion,
    String fingerprint,
    String androidId,
    String imei,
    String? advertisingId,
    String? ssid,
    String? macAddress,
    int? height,
    int? width,
  });
}

/// @nodoc
class __$$DeviceInfoImplCopyWithImpl<$Res>
    extends _$DeviceInfoCopyWithImpl<$Res, _$DeviceInfoImpl>
    implements _$$DeviceInfoImplCopyWith<$Res> {
  __$$DeviceInfoImplCopyWithImpl(
    _$DeviceInfoImpl _value,
    $Res Function(_$DeviceInfoImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? model = null,
    Object? brand = null,
    Object? manufacturer = null,
    Object? serialNo = null,
    Object? device = null,
    Object? productName = null,
    Object? releaseVersion = null,
    Object? sdkVersion = null,
    Object? fingerprint = null,
    Object? androidId = null,
    Object? imei = null,
    Object? advertisingId = freezed,
    Object? ssid = freezed,
    Object? macAddress = freezed,
    Object? height = freezed,
    Object? width = freezed,
  }) {
    return _then(
      _$DeviceInfoImpl(
        model:
            null == model
                ? _value.model
                : model // ignore: cast_nullable_to_non_nullable
                    as String,
        brand:
            null == brand
                ? _value.brand
                : brand // ignore: cast_nullable_to_non_nullable
                    as String,
        manufacturer:
            null == manufacturer
                ? _value.manufacturer
                : manufacturer // ignore: cast_nullable_to_non_nullable
                    as String,
        serialNo:
            null == serialNo
                ? _value.serialNo
                : serialNo // ignore: cast_nullable_to_non_nullable
                    as String,
        device:
            null == device
                ? _value.device
                : device // ignore: cast_nullable_to_non_nullable
                    as String,
        productName:
            null == productName
                ? _value.productName
                : productName // ignore: cast_nullable_to_non_nullable
                    as String,
        releaseVersion:
            null == releaseVersion
                ? _value.releaseVersion
                : releaseVersion // ignore: cast_nullable_to_non_nullable
                    as String,
        sdkVersion:
            null == sdkVersion
                ? _value.sdkVersion
                : sdkVersion // ignore: cast_nullable_to_non_nullable
                    as String,
        fingerprint:
            null == fingerprint
                ? _value.fingerprint
                : fingerprint // ignore: cast_nullable_to_non_nullable
                    as String,
        androidId:
            null == androidId
                ? _value.androidId
                : androidId // ignore: cast_nullable_to_non_nullable
                    as String,
        imei:
            null == imei
                ? _value.imei
                : imei // ignore: cast_nullable_to_non_nullable
                    as String,
        advertisingId:
            freezed == advertisingId
                ? _value.advertisingId
                : advertisingId // ignore: cast_nullable_to_non_nullable
                    as String?,
        ssid:
            freezed == ssid
                ? _value.ssid
                : ssid // ignore: cast_nullable_to_non_nullable
                    as String?,
        macAddress:
            freezed == macAddress
                ? _value.macAddress
                : macAddress // ignore: cast_nullable_to_non_nullable
                    as String?,
        height:
            freezed == height
                ? _value.height
                : height // ignore: cast_nullable_to_non_nullable
                    as int?,
        width:
            freezed == width
                ? _value.width
                : width // ignore: cast_nullable_to_non_nullable
                    as int?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$DeviceInfoImpl implements _DeviceInfo {
  _$DeviceInfoImpl({
    required this.model,
    required this.brand,
    required this.manufacturer,
    required this.serialNo,
    required this.device,
    required this.productName,
    required this.releaseVersion,
    required this.sdkVersion,
    required this.fingerprint,
    required this.androidId,
    required this.imei,
    this.advertisingId,
    this.ssid,
    this.macAddress,
    this.height,
    this.width,
  });

  factory _$DeviceInfoImpl.fromJson(Map<String, dynamic> json) =>
      _$$DeviceInfoImplFromJson(json);

  @override
  final String model;
  @override
  final String brand;
  @override
  final String manufacturer;
  @override
  final String serialNo;
  @override
  final String device;
  @override
  final String productName;
  @override
  final String releaseVersion;
  @override
  final String sdkVersion;
  @override
  final String fingerprint;
  @override
  final String androidId;
  @override
  final String imei;
  @override
  final String? advertisingId;
  @override
  final String? ssid;
  @override
  final String? macAddress;
  @override
  final int? height;
  @override
  final int? width;

  @override
  String toString() {
    return 'DeviceInfo(model: $model, brand: $brand, manufacturer: $manufacturer, serialNo: $serialNo, device: $device, productName: $productName, releaseVersion: $releaseVersion, sdkVersion: $sdkVersion, fingerprint: $fingerprint, androidId: $androidId, imei: $imei, advertisingId: $advertisingId, ssid: $ssid, macAddress: $macAddress, height: $height, width: $width)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$DeviceInfoImpl &&
            (identical(other.model, model) || other.model == model) &&
            (identical(other.brand, brand) || other.brand == brand) &&
            (identical(other.manufacturer, manufacturer) ||
                other.manufacturer == manufacturer) &&
            (identical(other.serialNo, serialNo) ||
                other.serialNo == serialNo) &&
            (identical(other.device, device) || other.device == device) &&
            (identical(other.productName, productName) ||
                other.productName == productName) &&
            (identical(other.releaseVersion, releaseVersion) ||
                other.releaseVersion == releaseVersion) &&
            (identical(other.sdkVersion, sdkVersion) ||
                other.sdkVersion == sdkVersion) &&
            (identical(other.fingerprint, fingerprint) ||
                other.fingerprint == fingerprint) &&
            (identical(other.androidId, androidId) ||
                other.androidId == androidId) &&
            (identical(other.imei, imei) || other.imei == imei) &&
            (identical(other.advertisingId, advertisingId) ||
                other.advertisingId == advertisingId) &&
            (identical(other.ssid, ssid) || other.ssid == ssid) &&
            (identical(other.macAddress, macAddress) ||
                other.macAddress == macAddress) &&
            (identical(other.height, height) || other.height == height) &&
            (identical(other.width, width) || other.width == width));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    model,
    brand,
    manufacturer,
    serialNo,
    device,
    productName,
    releaseVersion,
    sdkVersion,
    fingerprint,
    androidId,
    imei,
    advertisingId,
    ssid,
    macAddress,
    height,
    width,
  );

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      __$$DeviceInfoImplCopyWithImpl<_$DeviceInfoImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$DeviceInfoImplToJson(this);
  }
}

abstract class _DeviceInfo implements DeviceInfo {
  factory _DeviceInfo({
    required final String model,
    required final String brand,
    required final String manufacturer,
    required final String serialNo,
    required final String device,
    required final String productName,
    required final String releaseVersion,
    required final String sdkVersion,
    required final String fingerprint,
    required final String androidId,
    required final String imei,
    final String? advertisingId,
    final String? ssid,
    final String? macAddress,
    final int? height,
    final int? width,
  }) = _$DeviceInfoImpl;

  factory _DeviceInfo.fromJson(Map<String, dynamic> json) =
      _$DeviceInfoImpl.fromJson;

  @override
  String get model;
  @override
  String get brand;
  @override
  String get manufacturer;
  @override
  String get serialNo;
  @override
  String get device;
  @override
  String get productName;
  @override
  String get releaseVersion;
  @override
  String get sdkVersion;
  @override
  String get fingerprint;
  @override
  String get androidId;
  @override
  String get imei;
  @override
  String? get advertisingId;
  @override
  String? get ssid;
  @override
  String? get macAddress;
  @override
  int? get height;
  @override
  int? get width;

  /// Create a copy of DeviceInfo
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$DeviceInfoImplCopyWith<_$DeviceInfoImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
