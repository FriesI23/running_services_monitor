part of 'app_info_bloc.dart';

@freezed
class AppInfoState with _$AppInfoState {
  const factory AppInfoState.initial(AppInfoStateModel value) = _Initial;
  const factory AppInfoState.loading(AppInfoStateModel value) = _Loading;
  const factory AppInfoState.success(AppInfoStateModel value) = _Success;
  const factory AppInfoState.failure(AppInfoStateModel value, String message) = _Failure;

  const AppInfoState._();

  @override
  AppInfoStateModel get value {
    return when(
      initial: (value) => value,
      loading: (value) => value,
      success: (value) => value,
      failure: (value, message) => value,
    );
  }
}
