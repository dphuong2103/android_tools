import 'dart:io';

class DirectoryService {
  Directory getDeviceBackUpDirectory({required String serialNumber}){
    return Directory("${Directory.current.path}/file/rss/$serialNumber");
  }

  Directory getDeviceBackUpFolder({required String serialNumber, required String folderName}){
    return Directory("${Directory.current.path}/file/rss/$serialNumber/$folderName");
  }
}
