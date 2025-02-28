import 'package:android_tools/core/logging/log_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/router/router_config.dart';
import 'injection_container.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return  BlocProvider<LogCubit>(create: (context) => sl(),
    child: MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    ));
  }
}
