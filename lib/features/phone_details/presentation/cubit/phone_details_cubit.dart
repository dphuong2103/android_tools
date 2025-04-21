import 'dart:io';

import 'package:android_tools/core/service/backup_service.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/event_service.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:flutter/material.dart';
import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/features/phone_details/domain/backup_file.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:process_run/process_run.dart';

part 'phone_details_cubit.freezed.dart';

part 'phone_details_state.dart';

class PhoneDetailsCubit extends Cubit<PhoneDetailsState> {
  PhoneDetailsCubit() : super(const PhoneDetailsState());

  final CommandService _commandService = sl();
  final EventService _eventService = sl();
  final BackUpService _backupService = sl();
  final Shell _shell = sl();

  Future<void> init({required String serialNumber}) async {
    getBackupFiles(serialNumber);
  }

  Future<void> getBackupFiles(String serialNumber) async {
    List<BackUpFile> backupFiles = [];
    final dir = await _backupService.getDeviceLocalBackupDir(
      serialNumber: serialNumber,
    );

    try {
      await for (final backupEntity in dir.list()){
        if (backupEntity is File && backupEntity.path.endsWith('.zip')) {
          final stat = await backupEntity.stat();
          final backupName = backupEntity.uri.pathSegments.last.replaceAll(
            '.zip',
            '',
          );

          backupFiles.add(
            BackUpFile(
              path: backupEntity.path,
              name: backupName,
              // e.g., "backup.zip" or "test2.zip"
              isSelected: false,
              createdAt: stat.changed,
              modifiedAt: stat.modified,
              size: stat.size / (1024 * 1024), // Size in MB
            ),
          );
        }
      }

      emit(state.copyWith(backupFiles: backupFiles));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }

    return;
  }

  void onToggleSelect({required String path, bool? selected}) {
    final backupFiles =
        state.backupFiles?.map((x) {
          if (x.path == path) {
            return x.copyWith(isSelected: selected ?? !x.isSelected);
          }
          return x;
        }).toList();
    emit(state.copyWith(backupFiles: backupFiles));
  }

  void onSelectAll(bool? isSelectAll) {
    final newBackUpFolders =
        state.backupFiles?.map((folder) {
          return folder.copyWith(isSelected: isSelectAll ?? false);
        }).toList();
    emit(state.copyWith(backupFiles: newBackUpFolders));
  }

  void deleteSelectedFolder() {
    final selectedFolders =
        state.backupFiles?.where((folder) => folder.isSelected).toList();
    if (selectedFolders != null) {
      for (var folder in selectedFolders) {
        Directory(folder.path).deleteSync(recursive: true);
      }
      emit(
        state.copyWith(
          backupFiles:
              state.backupFiles?.where((folder) => !folder.isSelected).toList(),
        ),
      );
    }
  }

  //TODO: Implement sortFolderByCreatedAt
  void sortFolderByCreatedAt() {
    final newBackUpFolders =
        state.backupFiles?.toList()
          ?..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    emit(state.copyWith(backupFiles: newBackUpFolders));
  }

  Future<void> startRecordingEvents({
    required String serialNumber,
    required String eventsScriptName,
  }) async {
    if (state.isRecordingEvents) return;
    try {
      _eventService.startRecordingEvents(
        serialNumber: serialNumber,
        traceFileName: eventsScriptName,
      );
      emit(state.copyWith(isRecordingEvents: true));
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
  }

  Future<void> stopRecordingEvents() async {
    if (!state.isRecordingEvents) return;
    try {
      await _eventService.stopRecordEvents();
      emit(state.copyWith(isRecordingEvents: false));
    } catch (e) {
      debugPrint("Error stopping recording: $e");
    }
  }

  Future<void> replayEventFile2({
    required String eventsScriptName,
    required String serialNumber,
  }) async {
    try {
      await _eventService.replayEvents(
        shell: _shell,
        serialNumber: serialNumber,
        replayScriptName: eventsScriptName,
      );
    } catch (e) {
      debugPrint("Error replaying events: $e");
    }
  }

  Future<CommandResult> flashRom({required String serialNumber}) async {
    return await _commandService.flashRom(serialNumber: serialNumber);
  }

  Future<CommandResult> flashMagisk({required String serialNumber}) async {
    return await _commandService.flashMagisk(serialNumber: serialNumber);
  }

  Future<CommandResult> installApks({required String serialNumber}) async {
    return await _commandService.installInitApks(serialNumber: serialNumber);
  }

  Future<CommandResult> flashGApp({required String serialNumber}) async {
    return await _commandService.flashGApp(serialNumber: serialNumber);
  }

  Future<CommandResult> flashTwrp({required String serialNumber}) async {
    return await _commandService.flashTwrp(serialNumber: serialNumber);
  }

  Future<CommandResult> installEdXposed({required String serialNumber}) async {
    return await _commandService.installEdXposed(serialNumber: serialNumber);
  }

  Future<CommandResult> systemizePackages({
    required String serialNumber,
  }) async {
    return await _commandService.runCommand(
      command: SystemizeCommand(["com.midouz.change_phone"]),
      serialNumber: serialNumber,
    );
  }

  Future<CommandResult> installSystemize({required String serialNumber}) async {
    return await _commandService.installSystemize(serialNumber: serialNumber);
  }
}
