import 'package:bloc/bloc.dart';
import 'package:android_tools/core/logging/log_model.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'log_cubit.freezed.dart';
part 'log_state.dart';
const int maxLogs = 1000;
class LogCubit extends Cubit<LogState> {
  LogCubit() : super(const LogState());

  void log({required String title, String? message, LogType type = LogType.INFO}) {
    debugPrint("$title: $message");
    final newLog = Log(title: title, content: message, dateTime: DateTime.now(), logType: type);

    final updatedLogs = List<Log>.from(state.logs)..add(newLog);

    if (updatedLogs.length > maxLogs) {
      updatedLogs.removeAt(0);
    }

    emit(state.copyWith(logs: updatedLogs));
  }


  void clearLogs() {
    emit(state.copyWith(logs: []));
  }


}