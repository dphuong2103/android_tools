import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:android_tools/core/service/backup_service.dart';
import 'package:android_tools/core/service/command_service.dart';
import 'package:android_tools/core/service/apk_file_service.dart';
import 'package:android_tools/core/service/database_service.dart';
import 'package:android_tools/core/service/directory_service.dart';
import 'package:android_tools/core/service/event_service.dart';
import 'package:android_tools/core/service/text_file_service.dart';
import 'package:android_tools/core/service/shell_service.dart';
import 'package:android_tools/features/home/presentation/cubit/home_cubit.dart';
import 'package:android_tools/features/home/presentation/cubit/install_apk_tab_cubit.dart';
import 'package:android_tools/features/phone_details/presentation/cubit/phone_details_cubit.dart';
import 'package:android_tools/flavors.dart';
import 'package:get_it/get_it.dart';
import 'package:process_run/process_run.dart';

import 'core/device_list/device_list_cubit.dart';

final sl = GetIt.instance;

Future<void> init() async {
  sl.registerFactory<Shell>(()=>Shell());

  sl.registerSingleton<LogCubit>(LogCubit());
  sl.registerFactory<EventService>(() => EventService());

  sl.registerFactory<CommandService>(() => CommandService());
  sl.registerSingleton<DatabaseService>(DatabaseService());
  sl.registerSingleton<ShellService>(ShellService(flavor: flavor, logCubit: sl<LogCubit>()));
  sl.registerSingleton<TextFileService>(TextFileService(flavor: flavor));
  sl.registerSingleton<ApkFileService>(ApkFileService(flavor: flavor));
  sl.registerSingleton<DirectoryService>(DirectoryService());
  sl.registerSingleton<BackUpService>(BackUpService());

  //Register Cubit
  sl.registerSingleton<DeviceListCubit>(DeviceListCubit());
  sl.registerSingleton<HomeCubit>(HomeCubit());
  sl.registerFactory<PhoneDetailsCubit>(() => PhoneDetailsCubit());
  sl.registerFactory<InstallApkTabCubit>(() => InstallApkTabCubit());

}
