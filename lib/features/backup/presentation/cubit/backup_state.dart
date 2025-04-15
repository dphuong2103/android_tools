part of 'backup_cubit.dart';

@freezed
class BackupState with _$BackupState {
  const factory BackupState.list({@Default([])List<BackUpFile> filteredBackUpFiles,@Default([]) List<String> serialNumbers}) = BackupStateList;
  const factory BackupState.error(String errorMessage) = BackupStateError;
}
