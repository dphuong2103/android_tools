import 'dart:convert';
import 'dart:io';

import 'dart:ffi';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/event_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/flavors.dart';
import 'package:flutter/material.dart';
import 'package:win32/win32.dart';
import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/features/phone_details/domain/backup_folder.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:ffi/ffi.dart';

part 'phone_details_cubit.freezed.dart';

part 'phone_details_state.dart';

class PhoneDetailsCubit extends Cubit<PhoneDetailsState> {
  PhoneDetailsCubit() : super(const PhoneDetailsState());

  Process? _recordingProcess;
  String? _eventsScriptName;

  final DirectoryService _directoryService = sl();
  final CommandService _commandService = sl();
  final EventService _eventService = sl();

  Future<void> init({required String serialNumber}) async {
    List<BackUpFolder> backUpFolders = [];
    final directory = _directoryService.getDeviceBackUpDirectory(
      serialNumber: serialNumber,
    );
    if (await directory.exists()) {
      final entities = directory.list();

      await for (var entity in entities) {
        if (entity is Directory) {
          FileStat stats = await directory.stat();
          backUpFolders.add(
            BackUpFolder(
              name: path.basename(entity.path),
              path: entity.path,
              isSelected: false,
              createdAt: stats.changed,
              modifiedAt: stats.modified,
              // type: stats.type,
            ),
          );
        }
      }
    }
    emit(state.copyWith(backUpFolders: backUpFolders));
  }

  void onToggleSelectFolder({required String folderName, bool? selected}) {
    final newBackUpFolders =
        state.backUpFolders?.map((folder) {
          if (folder.name == folderName) {
            return folder.copyWith(isSelected: selected ?? !folder.isSelected);
          }
          return folder;
        }).toList();
    emit(state.copyWith(backUpFolders: newBackUpFolders));
  }

  void onSelectAll(bool? isSelectAll) {
    final newBackUpFolders =
        state.backUpFolders?.map((folder) {
          return folder.copyWith(isSelected: isSelectAll ?? false);
        }).toList();
    emit(state.copyWith(backUpFolders: newBackUpFolders));
  }

  void deleteSelectedFolder() {
    final selectedFolders =
        state.backUpFolders?.where((folder) => folder.isSelected).toList();
    if (selectedFolders != null) {
      for (var folder in selectedFolders) {
        Directory(folder.path).deleteSync(recursive: true);
      }
      emit(
        state.copyWith(
          backUpFolders:
              state.backUpFolders
                  ?.where((folder) => !folder.isSelected)
                  .toList(),
        ),
      );
    }
  }

  //TODO: Implement sortFolderByCreatedAt
  void sortFolderByCreatedAt() {
    final newBackUpFolders =
        state.backUpFolders?.toList()
          ?..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    emit(state.copyWith(backUpFolders: newBackUpFolders));
  }

  void embedScrcpy(String scrcpyTitle) async {
    // Step 1: Start scrcpy process with the given title
    var shellService = ShellService(flavor: flavor);
    shellService.runScrcpy([scrcpyTitle]).then((process) async {
      await Future.delayed(Duration(seconds: 2)); // Wait for Scrcpy to open

      // Step 2: Find scrcpy window handle using the given title
      final hwndScrcpy = FindWindow(nullptr, scrcpyTitle.toNativeUtf16());

      if (hwndScrcpy == 0) {
        print("Scrcpy window with title '$scrcpyTitle' not found!");
        return;
      }

      // Step 3: Find the Flutter window handle (Assuming the main Flutter window is active)
      final hwndFlutter = GetForegroundWindow();

      if (hwndFlutter == 0) {
        print("Flutter window not found!");
        return;
      }

      // Step 4: Reparent scrcpy to Flutter window
      SetParent(hwndScrcpy, hwndFlutter);

      // Step 5: Resize scrcpy window to fit inside Flutter
      SetWindowPos(
        hwndScrcpy,
        0,
        50,
        50,
        800,
        600,
        SWP_NOZORDER | SWP_SHOWWINDOW,
      );
      print("Scrcpy with title '$scrcpyTitle' embedded successfully!");
    });
  }

  Future<void> startRecordingEvents({
    required String serialNumber,
    required String eventsScriptName,
  }) async {
    if (state.isRecordingEvents) return;

    _eventsScriptName = eventsScriptName.trim();
    _eventService.getEventScriptDir();
    final eventScriptPath = _eventService.getEventScriptPath(
      eventsScriptName: eventsScriptName,
    );
    debugPrint("Event script path: $eventScriptPath");

    try {
      // Start the adb process without shell redirection
      _recordingProcess = await Process.start('adb', [
        '-s',
        serialNumber,
        'shell',
        'getevent',
        '-t',
      ], mode: ProcessStartMode.normal);

      // Open the file for writing
      final file = File(eventScriptPath).openWrite();

      // Capture and write stdout to the file
      _recordingProcess!.stdout
          .transform(utf8.decoder)
          .listen(
            (data) {
              debugPrint("Captured event data: $data"); // Debug the output
              file.write(data); // Write to file
            },
            onError: (error) {
              debugPrint("Stream error: $error");
            },
            onDone: () {
              debugPrint("Stream closed, finalizing file...");
              file.close(); // Ensure the file is closed when done
            },
          );

      // Log stderr for debugging
      _recordingProcess!.stderr.transform(utf8.decoder).listen((data) {
        debugPrint("Process error: $data");
      });

      emit(state.copyWith(isRecordingEvents: true));
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<void> stopRecordingEvents() async {
    if (_recordingProcess == null ||
        _eventsScriptName == null ||
        _eventsScriptName!.trim().isEmpty) {
      return;
    }
    try {
      _recordingProcess?.kill(ProcessSignal.sigint); // Send Ctrl+C equivalent
      await _recordingProcess?.exitCode; // Wait for the process to exit
      _recordingProcess = null;
      emit(state.copyWith(isRecordingEvents: false));
      await _eventService.convertEventFileToScript(_eventsScriptName!);
      debugPrint("Recording stopped successfully");

    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  Future<void> replayEventFile({
    required String eventsScriptName,
    required String serialNumber,
  }) async {
    try {
      await _eventService.playEventsOnAndroid(
        serialNumber: serialNumber,
        eventsScriptName: eventsScriptName,
      );
    } catch (e) {
      debugPrint("Error replaying events: $e");
    }
  }
}
