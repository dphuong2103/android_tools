import 'dart:io';

class DirectoryService {
  String backupScriptPath = "${Directory.current.path}/dependency/scripts/backup_phone.sh";
  String restoreScriptPath = "${Directory.current.path}/dependency/scripts/restore_phone.sh";

  Directory getDeviceBackUpDirectory({required String serialNumber}) {
    return Directory("${Directory.current.path}/file/backup/$serialNumber");
  }

  Future<Directory> getDeviceBackUpFolder({
    required String serialNumber,
    required String folderName,
  }) async {
    var directory = Directory(
      "${Directory.current.path}/file/backup/$serialNumber/$folderName",
    );
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }


}
