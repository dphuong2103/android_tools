import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/features/home/domain/entity/apk_file.dart';
import 'package:android_tools/injection_container.dart';
import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'install_apk_tab_cubit.freezed.dart';
part 'install_apk_tab_state.dart';

class InstallApkTabCubit extends Cubit<InstallApkTabState> {
  InstallApkTabCubit() : super(const InstallApkTabState());

  final ApkFileService _apkFileService = sl();

  Future<void> init() async {
    getApks();
  }

  Future<void> getApks()async{
    emit(state.copyWith(isLoading: true));
    var apks = await _apkFileService.getApkFiles();
    emit(state.copyWith(apks: apks, isLoading: false));
  }

  Future<void> refresh()async{
    await getApks();
  }

  Future<void> install()async{
    await getApks();
  }

  void onToggleSelectFile({required String apkName, bool? selected}) {
    final newBackUpFolders =
    state.apks.map((apk) {
      if (apk.name == apkName) {
        return apk.copyWith(isSelected: selected ?? !apk.isSelected);
      }
      return apk;
    }).toList();
    emit(state.copyWith(apks: newBackUpFolders));
  }

  void onSelectAll(bool? isSelectAll) {
    final newData =
    state.apks.map((apk) {
      return apk.copyWith(isSelected: isSelectAll ?? false);
    }).toList();
    emit(state.copyWith(apks: newData));
  }
}