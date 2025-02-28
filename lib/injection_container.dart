import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/service/adb_service.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/database_service.dart';
import 'package:android_tools/core/service/text_file_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/flavors.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory<AdbService>(()=>AdbService());
  sl.registerSingleton<DatabaseService>(DatabaseService());
  sl.registerSingleton<ShellService>(ShellService(flavor: flavor));
  sl.registerSingleton<TextFileService>(TextFileService(flavor: flavor));
  sl.registerSingleton<ApkFileService>(ApkFileService(flavor: flavor));

  //Register Cubit
  sl.registerSingleton<LogCubit>(LogCubit());
  sl.registerSingleton<HomeCubit>(HomeCubit());

}