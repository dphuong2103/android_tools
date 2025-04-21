part of 'phone_details_cubit.dart';

@freezed
class PhoneDetailsState with _$PhoneDetailsState {
  const factory PhoneDetailsState({
    List<BackUpFile>? backupFiles,
    @Default("")String error,
    @Default(false) bool isRecordingEvents,

}) = _PhoneDetailsState;
}
