part of 'device_list_cubit.dart';

@freezed
class DeviceListState with _$DeviceListState {
  const factory DeviceListState({
    @Default([]) List<Device> devices,
    String? error,
    @Default(false) bool isAddingDevice,
    @Default(false) bool isRefreshing,
    @Default(false) bool isConnectingAll,

  }) = _DeviceListState;
}
