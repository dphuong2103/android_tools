import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:process_run/shell.dart';

class ApkInstaller {
  final _shell = Shell();
  final String apkFolderPath;

  ApkInstaller({required this.apkFolderPath});

  /// 📥 Find the latest APK file in the folder
  File? getLatestApkFile() {
    final directory = Directory(apkFolderPath);
    if (!directory.existsSync()) {
      debugPrint('❌ APK folder does not exist.');
      return null;
    }

    final apkFiles = directory
        .listSync()
        .where((file) => file.path.endsWith('.apk'))
        .toList();

    if (apkFiles.isEmpty) {
      debugPrint('⚠️ No APK files found in $apkFolderPath');
      return null;
    }

    // Sort by last modified time (newest first)
    apkFiles.sort((a, b) =>
        b.statSync().modified.compareTo(a.statSync().modified));

    return File(apkFiles.first.path);
  }

  /// 🔗 Copy APK to Android device
  Future<bool> copyApkToDevice(String deviceIp, File apkFile) async {
    try {
      String devicePath = '/data/local/tmp/${apkFile.uri.pathSegments.last}';
      var result = await _shell.run('adb -s $deviceIp push "${apkFile.path}" $devicePath');

      return result.first.exitCode == 0;
    } catch (e) {
      debugPrint('❌ Error copying APK: $e');
      return false;
    }
  }

  /// 📲 Install APK on Android device
  Future<bool> installApkOnDevice(String deviceIp, String apkFileName) async {
    try {
      String devicePath = '/data/local/tmp/$apkFileName';
      var result = await _shell.run('adb -s $deviceIp shell pm install -r $devicePath');

      return result.first.exitCode == 0;
    } catch (e) {
      debugPrint('❌ Error installing APK: $e');
      return false;
    }
  }

  /// 🚀 Full Process: Detect, Copy, Install
  Future<void> autoInstallApk(String deviceIp) async {
    File? apkFile = getLatestApkFile();
    if (apkFile == null) {
      debugPrint('⚠️ No APK file found to install.');
      return;
    }

    bool copied = await copyApkToDevice(deviceIp, apkFile);
    if (!copied) {
      debugPrint('❌ Failed to copy APK to device.');
      return;
    }

    bool installed = await installApkOnDevice(deviceIp, apkFile.uri.pathSegments.last);
    if (installed) {
      debugPrint('✅ APK installed successfully!');
    } else {
      debugPrint('❌ APK installation failed.');
    }
  }
}
