import 'dart:io';

import 'package:android_tools/features/home/domain/entity/apk_file.dart';
import 'package:flutter/material.dart';
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
    final file = File(p.join(apkFolder, '$apkName.apk'));
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
            size: stat.size / (1024 * 1024),
            // Convert bytes to MB
            // Default value
            createdAt: stat.changed,
            // File creation time
            modifiedAt: stat.modified, // Last modification time
          );
        })
        .toList();
  }

  Future<void> addApkFileFromAnotherLocation(File file) async {
    if (!file.uri.pathSegments.last.endsWith('.apk')) {
      return;
    }
    final destinationFile = File(
      p.join(apkFolder, file.uri.pathSegments.last),
    );
    if (!await destinationFile.exists()) {
      await destinationFile.create(recursive: true);
    }
    await file.copy(destinationFile.path);

  }
}
