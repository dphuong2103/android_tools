part of 'phone_details_cubit.dart';

@freezed
class PhoneDetailsState with _$PhoneDetailsState {
  const factory PhoneDetailsState({
    List<BackUpFolder>? backUpFolders,
    @Default(false) bool isRecordingEvents
}) = _PhoneDetailsState;
}
