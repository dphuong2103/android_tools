import 'dart:io';

import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/injection_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';

import 'command_service.dart';

class EventService {
  final ShellService _shellService = sl();
  Process? _recordingProcess;

  String replayKitPath = p.join(
    Directory.current.path,
    'dependency',
    'replaykit',
    Platform.isWindows
        ? 'win32'
        : Platform.isMacOS
        ? 'macos'
        : 'linux',
  );

  Future<String> getReplayKitResultPath(String replayScriptName) async {
    Directory replayKitStoredDir = Directory(
      p.join(Directory.current.path, 'file', 'replaykit'),
    );

    if (!replayKitStoredDir.existsSync()) {
      replayKitStoredDir.createSync(recursive: true);
    }
    return p.join(replayKitStoredDir.path, "$replayScriptName.trace");
  }

  Future<void> startRecordingEvents({
    required String serialNumber,required String traceFileName
  }) async {
    try {
      final command = 'replaykit';
      final arguments = ['trace', 'record', '--device', serialNumber, (await getReplayKitResultPath(traceFileName))];

      // Start the process
      _recordingProcess = await Process.start(
        command,
        arguments,
        mode: ProcessStartMode.normal,
        workingDirectory: replayKitPath,
        runInShell: true,
      );

      // Print output from the process for debugging
      _recordingProcess!.stdout.transform(SystemEncoding().decoder).listen((data) {
        print('Recording Output: $data');
      });

      _recordingProcess!.stderr.transform(SystemEncoding().decoder).listen((data) {
        print('Recording Error: $data');
      });

    } catch (e) {
      print('Error starting recording: $e');
    }
  }


  Future<void> stopRecordEvents() async {
    if (_recordingProcess != null) {
      debugPrint('Stopping recording...');

      try {
        // Forcefully terminate the process
        _recordingProcess!.kill(ProcessSignal.sigterm); // SIGTERM to gracefully stop the process

        // Wait for the process to exit and check the exit code
        final exitCode = await _recordingProcess!.exitCode;
        debugPrint('Recording process exited with code: $exitCode');
        _recordingProcess = null;
      } catch (e) {
        debugPrint('Error stopping the recording: $e');
      }
    } else {
      debugPrint('No recording process is running.');
    }
  }

  Future<CommandResult> replayEvents({
    required Shell shell,
    required String serialNumber,
    required String replayScriptName,
  }) async {
    try {
      var execute = shell.cd(replayKitPath).run('''
        replaykit trace replay "${await getReplayKitResultPath(replayScriptName)}" $serialNumber 
      ''');
      return _shellService.runShell(run: () => execute);
    } catch (e) {
      throw Exception('Error replaying events: $e');
    }
  }

  Future<CommandResult> stopReplayEvents({required Shell shell}) async {
    try {
      shell.kill();
      return _shellService.logSuccess(null, "Replay stopped");
    } catch (e) {
      throw Exception('Error stop replaying events: $e');
    }
  }


}
