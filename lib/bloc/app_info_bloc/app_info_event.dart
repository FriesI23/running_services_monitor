part of 'app_info_bloc.dart';

@freezed
class AppInfoEvent with _$AppInfoEvent {
  const factory AppInfoEvent.loadAllApps() = _LoadAllApps;
  const factory AppInfoEvent.loadAppInfo(String packageName) = _LoadAppInfo;
  const factory AppInfoEvent.updateAppsInfo(List<String> packageNames) = _UpdateAppsInfo;
}
