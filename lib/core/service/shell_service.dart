import 'dart:io';
import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:path/path.dart' as p;

import '../../flavors.dart';

enum ScriptType { backup, restore }

class ShellService {
  Flavor flavor;

  ShellService({required this.flavor});

  Future<List<void>> runScrcpy(List<String> serialNumbers) async {
    String scrcpyPath;
    if (flavor == Flavor.PROD) {
      scrcpyPath = p.join(
        Directory.current.path,
        'dependency',
        'scrcpy',
        Platform.isWindows ? 'scrcpy.exe' : 'scrcpy',
      );
    } else {
      scrcpyPath = p.join(
        Directory.current.path,
        'dependency',
        Platform.isWindows
            ? 'scrcpy'
            : Platform.isMacOS
            ? 'scrcpy-macos'
            : 'scrcpy',
        Platform.isWindows ? 'scrcpy.exe' : 'scrcpy',
      );
    }
    // Check if scrcpy exists
    if (!File(scrcpyPath).existsSync()) {
      throw Exception('scrcpy not found at $scrcpyPath');
    }

    // Run scrcpy for each device serial
    List<Future<void>> tasks =
        serialNumbers.map((serialNumber) async {
          await Process.run(scrcpyPath, [
            '-s',
            serialNumber,
            '--window-title',
            serialNumber,
          ]);
        }).toList();

    return await Future.wait(tasks);
  }

  Future<void> runHelperScript({
    required ScriptType scriptType,
    required Map<String, String> args,
  }) async {
    if (scriptType == ScriptType.backup) {
      if (args['storedBackupPath'] == null) {
        throw Exception('storedBackupPath is required for backup script');
      }
    } else {}
    String scriptPath;
    if (flavor == Flavor.PROD) {
      scriptPath = p.join(
        Directory.current.path,
        'dependency',
        'scripts',
        '${scriptType == ScriptType.backup ? 'backup_script' : 'restore_script'}.${Platform.isWindows ? 'ps1' : 'sh'}',
      );
    } else {
      scriptPath = p.join(
        Directory.current.path,
        'dependency',
        'scripts',
        '${scriptType == ScriptType.backup ? 'backup_script' : 'restore_script'}.${Platform.isWindows ? 'ps1' : 'sh'}',
      );
    }

    if (!File(scriptPath).existsSync()) {
      throw Exception('Script not found not found at $scriptPath');
    }
  }
}
