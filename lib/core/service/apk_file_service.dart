import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:android_tools/flavors.dart';

class ApkFileService {
  final Flavor flavor;

  ApkFileService({required this.flavor});

  Future<bool> fileExists(String apkName) async {
    String path;
    if (flavor == Flavor.PROD) {
      path = p.join(Directory.current.path, "apks");
    } else {
      path = p.join(Directory.current.path, "apks");
    }

    final file = File('$path/$apkName.apk');
    return file.exists();
  }

  String filePath(String apkName) {
    String path;
    if (flavor == Flavor.PROD) {
      path = p.join(Directory.current.path, "apks");
    } else {
      path = p.join(Directory.current.path, "apks");
    }

    final file = File('$path/$apkName.apk');
    return file.path;
  }
}
