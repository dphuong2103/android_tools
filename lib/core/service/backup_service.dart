import 'dart:io';

import 'package:path/path.dart' as p;

class BackUpService {
  String backupScriptPath =
      "${Directory.current.path}/dependency/scripts/backup_phone.sh";
  String phoneBackupScriptPath = p.join(
    "/data",
    "local",
    "tmp",
    "backup_script.sh",
  );

  String phoneRestoreScriptPath = p.join(
    "/data",
    "local",
    "tmp",
    "restore_script.sh",
  );

  String tempPhoneBackupDirPath =
      "/sdcard/backups";

  String restoreScriptPath =
      "${Directory.current.path}/dependency/scripts/restore_phone.sh";

  Directory getDeviceBackUpDirectory({required String serialNumber}) {
    return Directory("${Directory.current.path}/file/backup/$serialNumber");
  }

  Future<Directory> getDeviceLocalBackupDir({
    required String serialNumber,
  }) async {
    var directory = Directory(
      "${Directory.current.path}/file/backup/$serialNumber",
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }


  String getSpecificTempPhoneBackupDir({required String backupName}) {
    return p.join(tempPhoneBackupDirPath, backupName);
  }

}
