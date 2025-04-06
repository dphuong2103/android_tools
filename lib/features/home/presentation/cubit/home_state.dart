part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    String? proxyIp,
    String? proxyPort,
    bool? isProxyEnabled,
  }) = _HomeState;
}
