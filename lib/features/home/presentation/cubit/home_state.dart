part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default([]) List<Device> devices,
    String? error,
    @Default(false) bool isAddingDevice,
    @Default(false) bool isRefreshing,
    @Default(false) bool isConnectingAll,
  }) = _HomeState;
}
