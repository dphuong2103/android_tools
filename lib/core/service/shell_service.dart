import 'dart:io';
import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/logging/log_model.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:path/path.dart' as p;
import 'package:process_run/process_run.dart';

import '../../flavors.dart';

enum ScriptType { backup, restore }

class ShellService {
  Flavor flavor;
  final LogCubit logCubit;

  ShellService({required this.flavor, required this.logCubit});

  Future<List<void>> runScrcpyForMultipleDevices(
    List<String> serialNumbers,
  ) async {
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
            "--max-size",
            "960",
            "--video-bit-rate",
            "2M",
            "--max-fps",
            "30",
            "--no-audio",
            "--video-codec",
            "h264",
          ]);
        }).toList();

    return await Future.wait(tasks);
  }

  Future<CommandResult> runScrcpy(String serialNumber) async {
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
    var process = await Process.run(scrcpyPath, [
      '-s',
      serialNumber,
      '--window-title',
      serialNumber,
      "--max-size",
      "960",
      "--video-bit-rate",
      "2M",
      "--max-fps",
      "30",
      "--no-audio",
      "--video-codec",
      "h264",
    ]);

    if (process.exitCode == 0) {
      return logSuccess(serialNumber, process.stdout.toString());
    } else {
      return logError(
        serialNumber,
        process.stdout.toString(),
        process.stderr.toString(),
      );
    }
  }

  bool _isConnectionError(String output) {
    return output.contains('cannot resolve host') ||
        output.contains('no such host is known') ||
        output.contains('failed to respond') ||
        output.contains('cannot connect');
  }

  Future<CommandResult> runShell({
    required Future<List<ProcessResult>> Function() run,
    String? serialNumber,
    bool isLogged = true,
  }) async {
    try {
      var result = await run();
      String output = result.outText.trim();
      if (_isConnectionError(output)) {
        return logError(
          serialNumber,
          "Connection error detected.",
          result.errText,
        );
      }
      if (result.first.exitCode == 0) {
        if (!isLogged) {
          return CommandResult(
            success: true,
            message: output,
            serialNumber: serialNumber,
          );
        }
        return logSuccess(serialNumber, output);
      } else {
        if (!isLogged) {
          return CommandResult(
            success: false,
            message: output,
            error: result.errText,
            serialNumber: serialNumber,
          );
        }
        return logError(serialNumber, result.outText, result.errText);
      }
    } catch (e) {
      return logError(serialNumber, "Exception occurred", e.toString());
    }
  }

  CommandResult returnCommandResult({
    required CommandResult result,
    String? serialNumber,
    isLogged = true,
  }) {
    if (isLogged) {
      if (result.success) {
        logCubit.log(
          title: "Success ${serialNumber != null ? "for $serialNumber" : ""}",
          message: result.message,
        );
      } else {
        logCubit.log(
          title: "Error ${serialNumber != null ? "for $serialNumber" : ""}",
          message: result.message + (result.error ?? ""),
          type: LogType.ERROR,
        );
      }
    }
    return result;
  }

  CommandResult logError(String? serialNumber, String message, String? error) {
    logCubit.log(
      title: "Error ${serialNumber != null ? "for $serialNumber" : ""}",
      message: "$message\n$error",
      type: LogType.ERROR,
    );
    return CommandResult(
      success: false,
      message: message,
      error: error,
      serialNumber: serialNumber,
    );
  }

  CommandResult logSuccess(String? serialNumber, String message) {
    logCubit.log(title: "Success ${serialNumber != null ? "for $serialNumber" : ""}", message: message);
    return CommandResult(
      success: true,
      message: message,
      serialNumber: serialNumber,
    );
  }
}
