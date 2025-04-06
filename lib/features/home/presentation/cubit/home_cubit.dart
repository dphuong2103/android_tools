import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'home_cubit.freezed.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(const HomeState());

  Future<void> init() async {

  }

  void setIsProxyEnabled(bool? isEnabled) {
    emit(state.copyWith(isProxyEnabled: isEnabled));
  }

}