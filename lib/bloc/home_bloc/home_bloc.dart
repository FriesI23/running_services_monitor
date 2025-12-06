import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:running_services_monitor/models/home_state_model.dart';
import 'package:running_services_monitor/models/process_state_filter.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'package:running_services_monitor/services/app_info_service.dart';
import 'package:running_services_monitor/services/process_service.dart';
import 'package:running_services_monitor/services/shizuku_service.dart';

part 'home_event.dart';
part 'home_state.dart';
part 'home_bloc.freezed.dart';

@lazySingleton
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final ShizukuService _shizukuService;
  final ProcessService _processService;
  final AppInfoService _appInfoService;
  Timer? _autoUpdateTimer;

  HomeBloc(this._shizukuService, this._processService, this._appInfoService)
    : super(const HomeState.initial(HomeStateModel())) {
    on<_InitializeShizuku>(_onInitializeShizuku);
    on<_LoadData>(_onLoadData);
    on<_ToggleAutoUpdate>(_onToggleAutoUpdate);
    on<_ToggleSearch>(_onToggleSearch);
    on<_UpdateSearchQuery>(_onUpdateSearchQuery);
    on<_RemoveApp>(_onRemoveApp);
    on<_RemoveService>(_onRemoveService);
    on<_AutoUpdateTick>(_onAutoUpdateTick);
    on<_UpdateAppInfoIcons>(_onUpdateAppInfoIcons);
    on<_SetProcessFilter>(_onSetProcessFilter);
    on<_ToggleSortOrder>(_onToggleSortOrder);
  }

  @override
  Future<void> close() {
    _autoUpdateTimer?.cancel();
    return super.close();
  }

  Future<void> _onInitializeShizuku(_InitializeShizuku event, Emitter<HomeState> emit) async {
    final isAlreadyReady = state.value.shizukuReady;

    if (!isAlreadyReady) {
      emit(HomeState.loading(state.value, 'Checking permissions...'));
    }

    try {
      final hasRoot = await _shizukuService.checkRootPermission();
      if (hasRoot) {
        final rootGranted = await _shizukuService.requestRootPermission();
        if (rootGranted) {
          final initialized = await _shizukuService.initialize();
          if (initialized) {
            emit(HomeState.success(state.value.copyWith(shizukuReady: true)));
            add(const HomeEvent.updateAppInfoIcons(startCache: true));
            add(const HomeEvent.loadData(updateAppInfoIcons: true));
            return;
          }
        }
      }

      final isRunning = await _shizukuService.isShizukuRunning();
      if (!isRunning) {
        emit(
          HomeState.failure(
            state.value.copyWith(shizukuReady: false),
            'Shizuku is not running. Please start Shizuku app.',
          ),
        );
        return;
      }

      final hasPermission = await _shizukuService.checkPermission();
      if (!hasPermission) {
        final granted = await _shizukuService.requestPermission();
        if (!granted) {
          emit(
            HomeState.failure(
              state.value.copyWith(shizukuReady: false),
              'Permission denied. Please grant Shizuku permission.',
            ),
          );
          return;
        }
      }

      final initialized = await _shizukuService.initialize();
      if (!initialized) {
        emit(
          HomeState.failure(
            state.value.copyWith(shizukuReady: false),
            'Failed to initialize. Please grant permission.',
          ),
        );
        return;
      }

      emit(HomeState.success(state.value.copyWith(shizukuReady: true)));

      add(const HomeEvent.updateAppInfoIcons(startCache: true));
      add(const HomeEvent.loadData(updateAppInfoIcons: true));
    } catch (e) {
      emit(HomeState.failure(state.value.copyWith(shizukuReady: false), 'Error initializing Shizuku: $e'));
    }
  }

  Future<void> _onLoadData(_LoadData event, Emitter<HomeState> emit) async {
    emit(HomeState.loading(state.value, 'Loading apps...'));
    try {
      final Map<String, AppProcessInfo> appsMap = {};
      var currentModel = state.value;

      final streamResult = _processService.streamAppProcessInfosWithRamInfo();
      final systemRamFuture = !event.silent ? streamResult.systemRamInfo : null;

      await for (final app in streamResult.apps) {
        appsMap[app.packageName] = app;

        final allApps = appsMap.values.toList();
        final userApps = allApps.where((a) => !a.isSystemApp).toList();
        final systemApps = allApps.where((a) => a.isSystemApp).toList();

        userApps.sort((a, b) => b.totalRamInKb.compareTo(a.totalRamInKb));
        systemApps.sort((a, b) => b.totalRamInKb.compareTo(a.totalRamInKb));

        double appsRam = 0;
        for (var appInfo in allApps) {
          appsRam += appInfo.totalRamInKb;
        }

        currentModel = currentModel.copyWith(
          allApps: allApps,
          userApps: userApps,
          systemApps: systemApps,
          appsRamKb: appsRam,
        );
        emit(HomeState.loading(currentModel));
      }

      if (systemRamFuture != null) {
        final ramInfo = await systemRamFuture;
        if (ramInfo != null) {
          currentModel = currentModel.copyWith(totalRamKb: ramInfo[0], freeRamKb: ramInfo[1], usedRamKb: ramInfo[2]);
          emit(HomeState.loading(currentModel));
        }
      }
      emit(HomeState.success(currentModel, 'Refreshed successfully', event.updateAppInfoIcons));
    } catch (e) {
      if (!event.silent) {
        emit(HomeState.failure(state.value, 'Error loading data: $e'));
      }
    }
  }

  Future<void> _onToggleAutoUpdate(_ToggleAutoUpdate event, Emitter<HomeState> emit) async {
    final newAutoUpdateState = !state.value.isAutoUpdateEnabled;

    if (newAutoUpdateState) {
      _autoUpdateTimer = Timer.periodic(const Duration(seconds: 3), (_) {
        add(const HomeEvent.autoUpdateTick());
      });
    } else {
      _autoUpdateTimer?.cancel();
      _autoUpdateTimer = null;
    }

    emit(HomeState.success(state.value.copyWith(isAutoUpdateEnabled: newAutoUpdateState)));
  }

  Future<void> _onAutoUpdateTick(_AutoUpdateTick event, Emitter<HomeState> emit) async {
    add(const HomeEvent.loadData(silent: true));
  }

  Future<void> _onToggleSearch(_ToggleSearch event, Emitter<HomeState> emit) async {
    final newSearchState = !state.value.isSearching;

    emit(
      HomeState.success(
        state.value.copyWith(isSearching: newSearchState, searchQuery: newSearchState ? state.value.searchQuery : ''),
      ),
    );
  }

  Future<void> _onUpdateSearchQuery(_UpdateSearchQuery event, Emitter<HomeState> emit) async {
    emit(HomeState.success(state.value.copyWith(searchQuery: event.query)));
  }

  Future<void> _onRemoveApp(_RemoveApp event, Emitter<HomeState> emit) async {
    final currentState = state.value;
    final updatedAllApps = currentState.allApps.where((app) => app.packageName != event.packageName).toList();
    final updatedUserApps = currentState.userApps.where((app) => app.packageName != event.packageName).toList();
    final updatedSystemApps = currentState.systemApps.where((app) => app.packageName != event.packageName).toList();

    double appsRam = 0;
    for (var app in updatedAllApps) {
      appsRam += app.totalRamInKb;
    }

    emit(
      HomeState.success(
        currentState.copyWith(
          allApps: updatedAllApps,
          userApps: updatedUserApps,
          systemApps: updatedSystemApps,
          appsRamKb: appsRam,
        ),
      ),
    );
  }

  Future<void> _onRemoveService(_RemoveService event, Emitter<HomeState> emit) async {
    final currentState = state.value;

    AppProcessInfo? updateApp(AppProcessInfo app) {
      if (app.packageName != event.packageName) return app;

      final updatedServices = app.services.where((s) => s.serviceName != event.serviceName).toList();

      if (updatedServices.isEmpty) return null;

      double totalRamKb = 0;
      final Set<int> pids = {};
      for (var service in updatedServices) {
        totalRamKb += service.ramInKb ?? 0;
        if (service.pid != null) pids.add(service.pid!);
      }

      return app.copyWith(
        services: updatedServices,
        pids: pids.toList(),
        totalRamInKb: totalRamKb,
        totalRam: _formatRam(totalRamKb),
      );
    }

    final updatedAllApps = currentState.allApps.map(updateApp).whereType<AppProcessInfo>().toList();
    final updatedUserApps = currentState.userApps.map(updateApp).whereType<AppProcessInfo>().toList();
    final updatedSystemApps = currentState.systemApps.map(updateApp).whereType<AppProcessInfo>().toList();

    double appsRam = 0;
    for (var app in updatedAllApps) {
      appsRam += app.totalRamInKb;
    }

    emit(
      HomeState.success(
        currentState.copyWith(
          allApps: updatedAllApps,
          userApps: updatedUserApps,
          systemApps: updatedSystemApps,
          appsRamKb: appsRam,
        ),
      ),
    );
  }

  String _formatRam(double kb) {
    if (kb > 1024 * 1024) {
      return '${(kb / (1024 * 1024)).toStringAsFixed(2)} GB';
    } else if (kb > 1024) {
      return '${(kb / 1024).toStringAsFixed(1)} MB';
    }
    return '${kb.toStringAsFixed(0)} KB';
  }

  Future<void> _onUpdateAppInfoIcons(_UpdateAppInfoIcons event, Emitter<HomeState> emit) async {
    try {
      if (event.startCache ?? false) {
        await _appInfoService.ensureCacheValid();
        return;
      }
      final cachedApps = _appInfoService.cachedAppsMap;
      if (cachedApps == null || cachedApps.isEmpty) return;

      final currentState = state.value;

      final updatedAllApps = currentState.allApps.map((app) {
        final cachedAppInfo = cachedApps[app.packageName];
        if (cachedAppInfo != null && app.appInfo?.icon == null) {
          return app.copyWith(appInfo: cachedAppInfo);
        }
        return app;
      }).toList();

      final updatedUserApps = currentState.userApps.map((app) {
        final cachedAppInfo = cachedApps[app.packageName];
        if (cachedAppInfo != null && app.appInfo?.icon == null) {
          return app.copyWith(appInfo: cachedAppInfo);
        }
        return app;
      }).toList();

      final updatedSystemApps = currentState.systemApps.map((app) {
        final cachedAppInfo = cachedApps[app.packageName];
        if (cachedAppInfo != null && app.appInfo?.icon == null) {
          return app.copyWith(appInfo: cachedAppInfo);
        }
        return app;
      }).toList();

      emit(
        HomeState.success(
          currentState.copyWith(allApps: updatedAllApps, userApps: updatedUserApps, systemApps: updatedSystemApps),
        ),
      );
    } catch (_) {}
  }

  Future<void> _onSetProcessFilter(_SetProcessFilter event, Emitter<HomeState> emit) async {
    emit(HomeState.success(state.value.copyWith(selectedProcessFilter: event.filter)));
  }

  Future<void> _onToggleSortOrder(_ToggleSortOrder event, Emitter<HomeState> emit) async {
    emit(HomeState.success(state.value.copyWith(sortAscending: !state.value.sortAscending)));
  }
}
