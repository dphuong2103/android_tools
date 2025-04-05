part of 'install_apk_tab_cubit.dart';

@freezed
class InstallApkTabState with _$InstallApkTabState {
  const factory InstallApkTabState({
    @Default([]) List<ApkFile> apks,
    @Default(false) isLoading,
  }) = _InstallApkTabState;
}
