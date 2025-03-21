import 'dart:io';

class DirectoryService {
  Directory getDeviceBackUpDirectory({required String serialNumber}){
    return Directory("${Directory.current.path}/file/rss/$serialNumber");
  }

}
