import 'dart:io';

import 'package:path/path.dart' as p;

class BackUpService {
  String rootBackupFolder =
      p.join(Directory.current.path, "file", "backup");

  String backupScriptPath = p.join(
    Directory.current.path,
    "dependency",
    "scripts",
    "backup_phone.sh",
  );

  final String phoneScriptsDir = "/data/local/tmp/scripts";
  String getPhoneBackupScriptPath(){
    return "$phoneScriptsDir/backup_phone.sh";
  }

  String getPhoneRestoreScriptPath(){
    return "$phoneScriptsDir/restore_phone.sh";
  }

  String tempPhoneBackupDirPath ="/sdcard/backup";

  String restoreScriptPath = p.join(
    Directory.current.path,
    "dependency",
    "scripts",
    "restore_phone.sh",
  );

  Directory getDeviceBackUpDirectory({required String serialNumber}) {
    // "${Directory.current.path}/file/backup/$serialNumber"
    return Directory(
      p.join(Directory.current.path, "file", "backup", serialNumber),
    );
  }

  Future<Directory> getDeviceLocalBackupDir({
    required String serialNumber,
  }) async {
    var directory = Directory(
      p.join(rootBackupFolder, serialNumber),
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  String getSpecificTempPhoneBackupPath({required String backupName}) {
    return "$tempPhoneBackupDirPath/$backupName";
  }

}
