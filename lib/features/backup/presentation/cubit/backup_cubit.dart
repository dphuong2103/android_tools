import 'dart:io';

import 'package:android_tools/core/service/backup_service.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/event_service.dart';
import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/features/home/domain/entity/command.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;
import 'package:process_run/process_run.dart';

import '../../domain/backup_file.dart';

part 'backup_cubit.freezed.dart';

part 'backup_state.dart';

class BackupCubit extends Cubit<BackupState> {
  BackupCubit() : super(const BackupStateList());

  final DirectoryService _directoryService = sl();
  final BackUpService _backupService = sl();
  final CommandService _commandService = sl();
  final EventService _eventService = sl();
  final Shell _shell = sl();
  List<BackUpFile> backupFiles = List.empty(growable: true);

  void init() {
    getBackupFiles();
  }

  Future<void> getBackupFiles() async {
    List<String> serialNumbers = [];
    backupFiles.clear();
    final rootDir = Directory(_backupService.rootBackupFolder);

    try {
      // Check if root directory exists
      if (!await rootDir.exists()) {
        return; // Return empty list if root doesn't exist
      }

      // Get all serial number folders
      await for (final serialFolder in rootDir.list()) {
        if (serialFolder is Directory) {
          final serialNumber = path.basename(serialFolder.path);
          serialNumbers.add(serialNumber);
          // Get all ZIP files within serial number folder
          await for (final backupEntity in serialFolder.list()) {
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
                  serialNumber: serialNumber,
                  size: stat.size / (1024 * 1024), // Size in MB
                ),
              );
            }
          }
        }
      }

      emit(
        BackupStateList(
          filteredBackUpFiles: backupFiles,
          serialNumbers: serialNumbers,
        ),
      );
    } catch (e) {
      emit(BackupStateError(e.toString()));
    }

    return;
  }

  void onToggleSelectFile({required String filePath, bool? selected}) {
    var currentState = state;
    if (currentState is BackupStateList) {
      final newBackupFiles =
          currentState.filteredBackUpFiles.map((folder) {
            if (folder.path == filePath) {
              return folder.copyWith(
                isSelected: selected ?? !folder.isSelected,
              );
            }
            return folder;
          }).toList();
      emit(currentState.copyWith(filteredBackUpFiles: newBackupFiles));
    }
  }

  void sortFolderByCreatedAt() {}

  void onSelectAll(bool? isSelectAll) {
    var currentState = state;
    if (currentState is BackupStateList) {
      final newBackupFiles =
          currentState.filteredBackUpFiles.map((folder) {
            return folder.copyWith(isSelected: isSelectAll ?? false);
          }).toList();
      emit(currentState.copyWith(filteredBackUpFiles: newBackupFiles));
    }
  }

  void onSearch(String value) {
    //filter the list of backup files based on value
    var currentState = state;
    if (currentState is BackupStateList) {
      final newBackupFiles =
          backupFiles
              .where(
                (file) =>
                    file.name.toLowerCase().contains(value.toLowerCase()) ||
                    file.serialNumber.toLowerCase().contains(
                      value.toLowerCase(),
                    ),
              )
              .toList();
      emit(currentState.copyWith(filteredBackUpFiles: newBackupFiles));
    }
  }

  void onRefresh() {
    getBackupFiles();
  }

  Future<void> onDeleteSelected() async {
    var currentState = state;
    if (currentState is BackupStateList) {
      final selectedFiles =
          currentState.filteredBackUpFiles
              .where((file) => file.isSelected)
              .toList();

      if (selectedFiles.isNotEmpty) {
        for (var selectedFile in selectedFiles) {
          File file = File(selectedFile.path);
          if (await file.exists()) {
            await file.delete();
          }
        }
        getBackupFiles();
      }
      //update the state
      emit(
        currentState.copyWith(
          filteredBackUpFiles:
              currentState.filteredBackUpFiles
                  .where((file) => !file.isSelected)
                  .toList(),
        ),
      );
    }
  }

  bool hasSelectedFiles() {
    var currentState = state;
    if (currentState is BackupStateList) {
      return currentState.filteredBackUpFiles.any((file) => file.isSelected);
    }
    return false;
  }

  void onFilterBySerialNumber(String serialNumber) {
    var currentState = state;
    if (currentState is BackupStateList) {
      final newBackupFiles =
          backupFiles
              .where(
                (file) => file.serialNumber.toLowerCase().contains(
                  serialNumber.toLowerCase(),
                ),
              )
              .toList();
      emit(currentState.copyWith(filteredBackUpFiles: newBackupFiles));
    }
  }

  Future<void> onRestoreSelect() async {
    var currentState = state;
    if (currentState is BackupStateList) {
      List<Future<CommandResult>> tasks = [];
      List<CommandResult> results = [];
      final selectedFiles =
          currentState.filteredBackUpFiles
              .where((file) => file.isSelected)
              .toList();

      if (selectedFiles.isNotEmpty) {
        tasks =
            selectedFiles.map((selectedFile) {
              return _commandService.runCommand(
                command: RestoreBackupCommand(backupName: selectedFile.name),
                serialNumber: selectedFile.serialNumber,
              );
            }).toList();
      }
      await Future.wait(tasks).then((value) {
        results = value;
      });
      Map<String, CommandResult> resultMap = results.asMap().map((
        index,
        result,
      ) {
        return MapEntry(result.serialNumber ?? "", result);
      });


      var backupFiles = currentState.filteredBackUpFiles;
      backupFiles = backupFiles.map((file) {
        debugPrint("file serial: ${file.serialNumber}");
        debugPrint("result serial: ${resultMap[file.serialNumber]}");
        var result = resultMap[file.serialNumber];
        if(result == null){
          return file;
        }
        debugPrint("result: ${result.success}, ${result.error}, ${result.message}, ${result.serialNumber}");
        if(result.success){
          return file.copyWith(
            restoreStatus: "Restore Success",
          );
        } else {
          return file.copyWith(
            restoreStatus: "Restore Failed: ${result.error}, ${result.message}",
          );
        }
      }).toList();
      emit(
        currentState.copyWith(
          filteredBackUpFiles: backupFiles,
        ),
      );
    }
  }
}
