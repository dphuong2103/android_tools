import 'dart:io';

class DirectoryService {
  Directory getDeviceBackUpDirectory({required String serialNumber}){
    return Directory("${Directory.current.path}/file/rss/$serialNumber");
  }

  Future<Directory> getDeviceBackUpFolder({required String serialNumber, required String folderName}) async {
    var directory = Directory("${Directory.current.path}/file/rss/$serialNumber/$folderName");
    if(!await directory.exists()){
      await directory.create(recursive: true);
    }
    return directory;
  }

}
