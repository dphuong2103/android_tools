import 'dart:io';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:path/path.dart' as p;

import '../../flavors.dart';

class ShellService {
  Flavor flavor;
  ShellService({required this.flavor});

  Future<List<void>> runScrcpy(List<Device> devices) async {
    String scrcpyPath;
    if(flavor == Flavor.PROD){
      scrcpyPath = p.join(
        Directory.current.path,
        'scrcpy',
        Platform.isWindows ? 'scrcpy.exe' : 'scrcpy',
      );
    }else{
      scrcpyPath = p.join(
        Directory.current.path,
        'dependency',
        Platform.isWindows ? 'scrcpy' : Platform.isMacOS ? 'scrcpy-macos': 'scrcpy' ,
        Platform.isWindows ? 'scrcpy.exe' : 'scrcpy',
      );
    }
    // Check if scrcpy exists
    if (!File(scrcpyPath).existsSync()) {
      throw Exception('scrcpy not found at $scrcpyPath');
    }

    // Run scrcpy for each device serial
    List<Future<void>> tasks = devices.map((device) async {
      await Process.run(scrcpyPath, ['-s', device.ip, '--window-title', device.ip]);
    }).toList();

    return await Future.wait(tasks);
  }



}
