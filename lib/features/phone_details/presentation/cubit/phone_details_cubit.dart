import 'dart:convert';
import 'dart:io';

import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/event_service.dart';
import 'package:flutter/material.dart';
import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/features/phone_details/domain/backup_folder.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

part 'phone_details_cubit.freezed.dart';

part 'phone_details_state.dart';

class PhoneDetailsCubit extends Cubit<PhoneDetailsState> {
  PhoneDetailsCubit() : super(const PhoneDetailsState());


  final DirectoryService _directoryService = sl();
  final CommandService _commandService = sl();
  final EventService _eventService = sl();
  final Shell _shell = sl();

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
}
