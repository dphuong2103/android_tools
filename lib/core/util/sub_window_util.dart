import 'dart:convert';

import 'package:android_tools/core/sub_window/sub_window.dart';
import 'package:android_tools/features/phone_details/presentation/screens/phone_details_screen.dart';
import 'package:desktop_multi_window/desktop_multi_window.dart';
import 'package:flutter/material.dart';
import 'package:window_manager_plus/window_manager_plus.dart';

Map<String, WindowController> _openWindows = {};

Future<void> openSubWindow({
  required String windowId,
  required SubWindow subWindow,
  required String title,
  Offset? offset,
  Size? size,
}) async {
  var args = subWindow.toJson();
  if (_openWindows.containsKey(windowId)) {
    _openWindows[windowId]!.show();
    return;
  }
  switch (subWindow.runtimeType) {
    case PhoneDetailsScreen _:
      args["subWindowType"] = "phoneDetails";
      break;
    case ():
      // TODO: Handle this case.
      throw UnimplementedError();
  }

  final window = await DesktopMultiWindow.createWindow(jsonEncode(args));
  _openWindows[windowId] = window;
  window
    ..setFrame((offset ?? const Offset(0, 0)) & (size ?? const Size(680, 480)))
    ..center()
    ..setTitle(title)
    ..show();
}

void closeSubWindow(String windowId) {
  if (_openWindows.containsKey(windowId)) {
    _openWindows[windowId]!.close();
    _openWindows.remove(windowId);
  }
}


Future<void> openSubWindow2() async {
  final newWindow = await WindowManagerPlus.createWindow(['my test arg 1', 'my test arg 2']);
  if (newWindow != null) {
    print('New Created Window: $newWindow');
  }
}