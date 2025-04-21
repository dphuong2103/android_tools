import 'package:freezed_annotation/freezed_annotation.dart';
part 'backup_file.freezed.dart';
part 'backup_file.g.dart';

@freezed
class BackUpFile with _$BackUpFile {
  factory BackUpFile({
    required String path,
    required String name,
    required bool isSelected,
    required DateTime createdAt,
    required DateTime modifiedAt,
    required double size,
    String? restoreStatus
  }) = _BackUpFile;

  factory BackUpFile.fromJson(Map<String, dynamic> json) => _$BackUpFileFromJson(json);
}
