import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_batch.freezed.dart';
part 'device_batch.g.dart';

@freezed
class DeviceBatch with _$DeviceBatch {
  factory DeviceBatch({
    required String batchId,
    required String device_serial_number,
  }) = _DeviceBatch;

  factory DeviceBatch.fromJson(Map<String, dynamic> json) => _$DeviceBatchFromJson(json);
}
