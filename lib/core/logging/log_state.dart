part of 'log_cubit.dart';

@freezed
class LogState with _$LogState {
  const factory LogState({
    @Default([]) List<Log> logs,
  }) = _LogState;
}
