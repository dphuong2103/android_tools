import 'dart:io';

import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/injection_container.dart';

import 'command_service.dart';

class EventService {
  final CommandService _commandService = sl();

  //Work but super slow
  // Future<CommandResult> convertEventFileToScript(String fileName) async {
  //   try {
  //     var eventFile = getScriptFile(scriptName: fileName);
  //     if (eventFile == null) throw Exception('File not found');
  //     String content = await eventFile.readAsString();
  //     List<String> lines = content.split('\n');
  //
  //     StringBuffer scriptContent = StringBuffer();
  //     scriptContent.writeln('#!/system/bin/sh');
  //     scriptContent.writeln('# Generated script to replay touch events');
  //     scriptContent.writeln(
  //       'echo "Start: \$(date +%s.%N)" > /data/local/tmp/time.log',
  //     );
  //
  //     double? firstTimestamp;
  //     double? lastTimestamp;
  //     double accumulatedDelay = 0;
  //     List<String> eventBatch = []; // Batch events between SYN_REPORTs
  //
  //     for (String line in lines) {
  //       line = line.trim();
  //       if (line.isEmpty || line.startsWith('add device')) continue;
  //
  //       RegExp eventPattern = RegExp(
  //         r'^\[\s*(\d+\.\d+)\]\s*(/dev/input/event\d+):\s*(\w+)\s+(\w+)\s+(\w+)$',
  //       );
  //       if (eventPattern.hasMatch(line)) {
  //         var match = eventPattern.firstMatch(line)!;
  //         String timestampStr = match.group(1)!;
  //         String devicePath = match.group(2)!;
  //         String typeHex = match.group(3)!;
  //         String codeHex = match.group(4)!;
  //         String valueHex = match.group(5)!;
  //
  //         int type = int.parse(typeHex, radix: 16);
  //         int code = int.parse(codeHex, radix: 16);
  //         int value = int.parse(valueHex, radix: 16);
  //         if (valueHex == "ffffffff") value = 4294967295;
  //
  //         double currentTimestamp = double.parse(timestampStr);
  //         if (firstTimestamp == null) firstTimestamp = currentTimestamp;
  //         currentTimestamp -= firstTimestamp; // Normalize to start at 0
  //
  //         if (lastTimestamp != null) {
  //           double delay = currentTimestamp - lastTimestamp;
  //           if (delay > 0) accumulatedDelay += delay;
  //         }
  //         lastTimestamp = currentTimestamp;
  //
  //         // Add event to batch
  //         eventBatch.add("sendevent $devicePath $type $code $value");
  //
  //         // If SYN_REPORT (type 0, code 0), flush the batch with accumulated delay
  //         if (type == 0 && code == 0) {
  //           if (accumulatedDelay >= 0.001) { // Apply delay before batch if ≥1ms
  //             int microseconds = (accumulatedDelay * 1000000).toInt();
  //             scriptContent.writeln("usleep $microseconds");
  //           }
  //           scriptContent.writeln(eventBatch.join('\n'));
  //           eventBatch.clear();
  //           accumulatedDelay = 0; // Reset after flushing
  //         }
  //       }
  //     }
  //
  //     // Flush any remaining events
  //     if (eventBatch.isNotEmpty) {
  //       if (accumulatedDelay > 0) {
  //         int microseconds = (accumulatedDelay * 1000000).toInt();
  //         scriptContent.writeln("usleep $microseconds");
  //       }
  //       scriptContent.writeln(eventBatch.join('\n'));
  //     }
  //
  //     scriptContent.writeln(
  //       'echo "End: \$(date +%s.%N)" >> /data/local/tmp/time.log',
  //     );
  //
  //     File outputFile = File('${getEventScriptDir().path}/$fileName.sh');
  //     await outputFile.writeAsString(scriptContent.toString());
  //     await Process.run('chmod', ['+x', outputFile.path]);
  //
  //     return CommandResult(
  //       success: true,
  //       message: 'Script converted successfully',
  //     );
  //   } catch (e) {
  //     throw Exception('Error converting event file: $e');
  //   }
  // }

  Future<CommandResult> convertEventFileToScript(String fileName) async {
    try {
      var eventFile = getScriptFile(scriptName: fileName);
      if (eventFile == null) throw Exception('File not found');

      String content = await eventFile.readAsString();
      List<String> lines = content.split('\n');

      StringBuffer scriptContent = StringBuffer();
      scriptContent.writeln('#!/system/bin/sh');
      scriptContent.writeln('echo "Start: \$(date +%s.%N)" > /data/local/tmp/time.log');

      double? firstTimestamp;
      double lastTimestamp = 0;

      for (String line in lines) {
        line = line.trim();
        if (line.isEmpty || line.startsWith('add device')) continue;

        RegExp eventPattern = RegExp(
          r'^\[\s*(\d+\.\d+)\]\s*(/dev/input/event\d+):\s*(\w+)\s+(\w+)\s+(\w+)$',
        );

        if (eventPattern.hasMatch(line)) {
          var match = eventPattern.firstMatch(line)!;
          String timestampStr = match.group(1)!;
          String devicePath = match.group(2)!;
          String typeHex = match.group(3)!;
          String codeHex = match.group(4)!;
          String valueHex = match.group(5)!;

          int type = int.parse(typeHex, radix: 16);
          int code = int.parse(codeHex, radix: 16);
          int value = int.parse(valueHex, radix: 16);
          if (valueHex == "ffffffff") value = 4294967295;

          double currentTimestamp = double.parse(timestampStr);
          firstTimestamp ??= currentTimestamp;
          double delay = currentTimestamp - lastTimestamp;
          lastTimestamp = currentTimestamp;

          // Add delay between events (convert seconds to microseconds)
          int microDelay = (delay * 1000000).toInt();
          if (microDelay > 0) {
            scriptContent.writeln("usleep ${microDelay.clamp(500, 2000)}"); // Limit delay to 0.5 - 2ms
          }

          scriptContent.writeln("sendevent $devicePath $type $code $value");
        }
      }

      // Ensure proper touch release
      scriptContent.writeln("sendevent /dev/input/event2 3 58 0");
      scriptContent.writeln("sendevent /dev/input/event2 0 0 0");

      scriptContent.writeln('echo "End: \$(date +%s.%N)" >> /data/local/tmp/time.log');

      File outputFile = File('${getEventScriptDir().path}/$fileName.sh');
      await outputFile.writeAsString(scriptContent.toString());
      await Process.run('chmod', ['+x', outputFile.path]);

      return CommandResult(success: true, message: 'Script converted successfully');
    } catch (e) {
      throw Exception('Error converting event file: $e');
    }
  }


  Future<void> playEventsOnAndroid({
    required String serialNumber,
    required String eventsScriptName,
  }) async {
    File? scriptFile = getConvertedScriptFile(scriptName: eventsScriptName);
    if (scriptFile == null) {
      throw Exception('Script file not found');
    }
    try {
      // Push the script to the device
      var destinationPath =
          "/data/local/tmp/event_scripts/$eventsScriptName.sh";
      var result = await _commandService.runCommand(
        command: PushFileCommand(
          sourcePath: scriptFile.path,
          destinationPath: destinationPath,
        ),
        serialNumber: serialNumber,
      );

      if (!result.success) {
        throw Exception('Failed to push script to device: ${result.message}');
      }

      // Ensure executable permissions and run as root
      result = await _commandService.runCommand(
        command: CustomCommand(
          command:
              'shell su -c "setenforce 0 && chmod +x \'$destinationPath\' && \'$destinationPath\'"',
        ),
        serialNumber: serialNumber,
      );

      if (!result.success) {
        throw Exception('Failed to execute script: ${result.message}');
      }
      result = await _commandService.runCommand(
        command: RemoveFilesCommand(filePaths: [destinationPath]),
        serialNumber: serialNumber,
      );
    } catch (e) {
      throw Exception('Error playing events: $e');
    }
  }

  Directory getEventScriptDir() {
    Directory dir = Directory("${Directory.current.path}/file/event_scripts");
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return dir;
  }

  File? getScriptFile({required String scriptName}) {
    File file = File(getEventScriptPath(eventsScriptName: scriptName));
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  File? getConvertedScriptFile({required String scriptName}) {
    File file = File(getConvertedEventScriptPath(eventsScriptName: scriptName));
    if (file.existsSync()) {
      return file;
    }
    return null;
  }

  String getEventScriptPath({required String eventsScriptName}) {
    return "${getEventScriptDir().path}/$eventsScriptName.txt";
  }

  String getConvertedEventScriptPath({required String eventsScriptName}) {
    return "${getEventScriptDir().path}/$eventsScriptName.sh";
  }
}
