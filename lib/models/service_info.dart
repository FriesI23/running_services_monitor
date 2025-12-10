import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:running_services_monitor/models/process_state_filter.dart';

part 'service_info.freezed.dart';
part 'service_info.g.dart';

@freezed
abstract class RunningServiceInfo with _$RunningServiceInfo {
  const factory RunningServiceInfo({
    required String user,
    int? pid,
    required String processName,
    required String serviceName,
    required String packageName,
    required bool isSystemApp,
    String? serviceClass,
    String? appName,
    String? ramUsage,
    double? ramInKb,
    String? intent,
    String? baseDir,
    String? dataDir,
    bool? isForeground,
    int? foregroundId,
    String? createTime,
    String? lastActivityTime,
    bool? startRequested,
    bool? createdFromFg,
    String? rawServiceRecord,
    int? uid,
    int? recentCallingUid,
    @Default([]) List<ConnectionRecord> connections,
  }) = _RunningServiceInfo;

  factory RunningServiceInfo.fromJson(Map<String, dynamic> json) => _$RunningServiceInfoFromJson(json);
}

@freezed
abstract class AppProcessInfo with _$AppProcessInfo {
  const AppProcessInfo._();
  const factory AppProcessInfo({
    required String packageName,
    required String appName,
    required List<RunningServiceInfo> services,
    required List<int> pids,
    required String totalRam,
    required double totalRamInKb,
    bool? isSystemApp,
    @Default([]) List<ConnectionRecord> connections,
    String? processState,
    String? adjLevel,
    @Default(true) bool hasServices,
    @Default([]) List<RamSourceInfo> ramSources,
    @Default(false) bool isCached,
    @Default(0) double cachedMemoryKb,
  }) = _AppProcessInfo;

  factory AppProcessInfo.fromJson(Map<String, dynamic> json) => _$AppProcessInfoFromJson(json);

  bool get isActive => isActiveState(processState, hasServices: hasServices);
  bool get isCachedProcess => isCachedState(processState) || isCached;
}

enum RamSourceType { pid, lru, processName, meminfoPss }

@freezed
abstract class RamSourceInfo with _$RamSourceInfo {
  const factory RamSourceInfo({required RamSourceType source, required double ramKb, int? pid, String? processName}) =
      _RamSourceInfo;

  factory RamSourceInfo.fromJson(Map<String, dynamic> json) => _$RamSourceInfoFromJson(json);
}

@freezed
abstract class RunningProcessInfo with _$RunningProcessInfo {
  const factory RunningProcessInfo({
    required String packageName,
    required String processName,
    required int pid,
    required int uid,
    String? appName,
    required bool isSystemApp,
    required String importance,
  }) = _RunningProcessInfo;

  factory RunningProcessInfo.fromJson(Map<String, dynamic> json) => _$RunningProcessInfoFromJson(json);
}

@freezed
abstract class ConnectionRecord with _$ConnectionRecord {
  const factory ConnectionRecord({
    required String packageName,
    required String serviceName,
    String? bindingPackage,
    String? bindingProcess,
    String? conn,
    String? flags,
    bool? isForeground,
    bool? isVisible,
    bool? hasCapabilities,
    String? rawConnectionRecord,
  }) = _ConnectionRecord;

  factory ConnectionRecord.fromJson(Map<String, dynamic> json) => _$ConnectionRecordFromJson(json);
}

class ProcessedAppsResult {
  final List<AppProcessInfo> allApps;
  final List<AppProcessInfo> userApps;
  final List<AppProcessInfo> systemApps;
  final double appsRam;
  final List<double>? ramInfo;

  ProcessedAppsResult({
    required this.allApps,
    required this.userApps,
    required this.systemApps,
    required this.appsRam,
    this.ramInfo,
  });
}
