part of 'home_bloc.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState.initial(HomeStateModel value) = _Initial;
  const factory HomeState.loading(HomeStateModel value, [String? message]) = _Loading;
  const factory HomeState.success(HomeStateModel value, [String? toast, bool? updateAppInfoIcons]) = _Success;
  const factory HomeState.failure(HomeStateModel value, String message) = _Failure;

  const HomeState._();

  @override
  HomeStateModel get value {
    return when(
      initial: (value) => value,
      loading: (value, message) => value,
      success: (value, toast, updateAppInfoIcons) => value,
      failure: (value, message) => value,
    );
  }
}
