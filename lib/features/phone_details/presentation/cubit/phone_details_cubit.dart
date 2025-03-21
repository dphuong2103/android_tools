import 'dart:io';

import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/features/phone_details/domain/backup_folder.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:path/path.dart' as path;

part 'phone_details_cubit.freezed.dart';

part 'phone_details_state.dart';

class PhoneDetailsCubit extends Cubit<PhoneDetailsState> {
  PhoneDetailsCubit() : super(const PhoneDetailsState());

  final DirectoryService _directoryService = sl();

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
    final newBackUpFolders = state.backUpFolders?.map((folder) {
      return folder.copyWith(isSelected: isSelectAll ?? false);
    }).toList();
    emit(state.copyWith(backUpFolders: newBackUpFolders));
  }
}
