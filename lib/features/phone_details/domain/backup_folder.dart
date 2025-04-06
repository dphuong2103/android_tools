
import 'package:freezed_annotation/freezed_annotation.dart';
part 'backup_folder.freezed.dart';
part 'backup_folder.g.dart';

@freezed
class BackUpFolder with _$BackUpFolder {
  factory BackUpFolder({
    required String path,
    required String name,
    required bool isSelected,
    required DateTime createdAt,
    required DateTime modifiedAt,
    // required FileSystemEntityType type,
  }) = _BackUpFolder;

  factory BackUpFolder.fromJson(Map<String, dynamic> json) => _$BackUpFolderFromJson(json);
}
