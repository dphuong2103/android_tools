import 'package:freezed_annotation/freezed_annotation.dart';

part 'batch.freezed.dart';
part 'batch.g.dart';

@freezed
class Batch with _$Batch {
  factory Batch({
    required String id,
    required String name,
  }) = _Batch;

  factory Batch.fromJson(Map<String, dynamic> json) => _$BatchFromJson(json);
}
