import 'dart:convert';

import 'package:android_tools/core/device_list/device.dart';
import 'package:android_tools/features/phone_details/presentation/screens/phone_details_screen.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'injection_container.dart' as di;

void main(List<String> args) async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  if (args.firstOrNull == 'multi_window') {
    final windowId = int.parse(args[1]);
    Map<String, dynamic> argument =
        args[2].isEmpty ? {} : jsonDecode(args[2]) as Map<String, dynamic>;

    final String subWindowType = argument['subWindowType'] ?? 'default';
    Widget subWindow;
    switch (subWindowType) {
      case 'phoneDetails':
        var device = Device.fromJson(argument["device"]);
        subWindow = PhoneDetailsScreen(
          windowController: WindowController.fromWindowId(windowId),
          device: device,
        );
        break;
      // case 'details':
      //   subWindow = DetailsWindow(windowController: WindowController.fromWindowId(windowId), args: argument);
      //   break;
      default:
        if (argument["device"] == null) {
          throw Exception("Device is required for phoneDetails window");
        }
        var device = Device.fromJson(argument["device"]);
        subWindow = PhoneDetailsScreen(
          windowController: WindowController.fromWindowId(windowId),
          device: device,
        );
    }

    runApp(subWindow);
  } else {
    runApp(const MyApp());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Android Tools',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: App(),
    );
  }
}
