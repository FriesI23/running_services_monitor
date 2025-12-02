import 'package:bloc/bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/services/app_info_service.dart';

part 'app_details_event.dart';

part 'app_details_state.dart';

part 'app_details_bloc.freezed.dart';

@injectable
class AppDetailsBloc extends Bloc<AppDetailsEvent, AppDetailsState> {
  final AppInfoService _appInfoService;

  AppDetailsBloc(this._appInfoService) : super(const AppDetailsState.initial()) {
    on<_LoadDetails>(_onLoadDetails);
  }

  Future<void> _onLoadDetails(_LoadDetails event, Emitter<AppDetailsState> emit) async {
    emit(AppDetailsState.loading(event.appInfo));

    try {
      var appInfo = event.appInfo;

      if (appInfo.appInfo == null || appInfo.appInfo!.icon == null) {
        try {
          final fetchedAppInfo = await _appInfoService.getAppInfo(appInfo.packageName);
          if (fetchedAppInfo != null) {
            appInfo = appInfo.copyWith(appInfo: fetchedAppInfo);
          }
        } catch (e) {
          // Ignore error fetching app info
        }
      }

      final updatedServices = <RunningServiceInfo>[];
      for (var service in appInfo.services) {
        var updatedService = service;
        if (service.icon == null) {
          try {
            final fetchedAppInfo = await _appInfoService.getAppInfo(service.packageName);
            if (fetchedAppInfo != null && fetchedAppInfo.icon != null) {
              updatedService = service.copyWith(icon: fetchedAppInfo.icon);
            }
          } catch (_) {}
        }
        updatedServices.add(updatedService);
      }

      appInfo = appInfo.copyWith(services: updatedServices);

      emit(AppDetailsState.success(appInfo));
    } catch (e) {
      emit(AppDetailsState.failure(event.appInfo, e.toString()));
    }
  }
}
