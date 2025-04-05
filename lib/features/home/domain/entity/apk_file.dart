
import 'package:freezed_annotation/freezed_annotation.dart';
part 'apk_file.freezed.dart';
part 'apk_file.g.dart';

@freezed
class ApkFile with _$ApkFile {
  factory ApkFile({
    required String path,
    required String name,
    required double size,
    required bool isSelected,
    required DateTime createdAt,
    required DateTime modifiedAt,
  }) = _ApkFile;

  factory ApkFile.fromJson(Map<String, dynamic> json) => _$ApkFileFromJson(json);
}
