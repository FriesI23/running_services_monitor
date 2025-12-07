part of 'home_bloc.dart';

@freezed
class HomeEvent with _$HomeEvent {
  const factory HomeEvent.initializeShizuku() = _InitializeShizuku;
  const factory HomeEvent.loadData({@Default(false) bool silent, @Default(false) bool updateAppInfoIcons}) = _LoadData;
  const factory HomeEvent.toggleAutoUpdate() = _ToggleAutoUpdate;
  const factory HomeEvent.toggleSearch() = _ToggleSearch;
  const factory HomeEvent.updateSearchQuery(String query) = _UpdateSearchQuery;
  const factory HomeEvent.removeApp(String packageName) = _RemoveApp;
  const factory HomeEvent.removeService({required String packageName, required String serviceName}) = _RemoveService;
  const factory HomeEvent.updateAppInfoIcons({@Default(false) bool? startCache}) = _UpdateAppInfoIcons;
  const factory HomeEvent.setProcessFilter(ProcessStateFilter filter) = _SetProcessFilter;
  const factory HomeEvent.toggleSortOrder() = _ToggleSortOrder;
}
