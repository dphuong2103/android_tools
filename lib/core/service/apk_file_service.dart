import 'dart:io';

import 'package:android_tools/features/home/domain/entity/apk_file.dart';
import 'package:path/path.dart' as p;
import 'package:android_tools/flavors.dart';

class ApkFileService {
  final Flavor flavor;
  final String apkFolder = p.join(Directory.current.path, "file", "apks");
  ApkFileService({required this.flavor});

  Future<bool> fileExists(String apkName) async {

    final file = File('$apkFolder/$apkName.apk');
    return file.exists();
  }

  String filePath(String apkName) {
    final file = File(p.join(apkFolder,'$apkName.apk'));
    return file.path;
  }

  Future<List<ApkFile>> getApkFiles() async {
    final dir = Directory(apkFolder);
    if (!await dir.exists()) {
      throw Exception("Directory does not exist: $apkFolder");
    }

    return dir
        .listSync()
        .where((file) => file is File && file.path.endsWith('.apk'))
        .map((file) {
          final stat = File(file.path).statSync();
          final fileName = file.uri.pathSegments.last.replaceAll('.apk', '');
          return ApkFile(
            path: file.path,
            name: fileName,
            isSelected: false,
            // Default value
            createdAt: stat.changed,
            // File creation time
            modifiedAt: stat.modified, // Last modification time
          );
        })
        .toList();
  }
}
