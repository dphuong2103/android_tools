import 'package:android_tools/features/home/domain/entity/device.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'sub_window.freezed.dart';
part 'sub_window.g.dart';

@freezed
sealed class SubWindow with _$SubWindow {
  const factory SubWindow.base({required String title}) = _BaseSubWindow;

  const factory SubWindow.phoneDetails({required Device device}) = _PhoneDetailsWindow;

  factory SubWindow.fromJson(Map<String, dynamic> json) => _$SubWindowFromJson(json);
}
