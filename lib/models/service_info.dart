import 'dart:typed_data';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:installed_apps/app_info.dart';

part 'service_info.freezed.dart';

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
    Uint8List? icon,
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
}

@freezed
abstract class AppProcessInfo with _$AppProcessInfo {
  const factory AppProcessInfo({
    required String packageName,
    required String appName,
    required List<RunningServiceInfo> services,
    required List<int> pids,
    required String totalRam,
    required double totalRamInKb,
    required bool isSystemApp,
    AppInfo? appInfo,
    @Default([]) List<ConnectionRecord> connections,
    String? processState,
    String? adjLevel,
    @Default(true) bool hasServices,
    @Default([]) List<RamSourceInfo> ramSources,
  }) = _AppProcessInfo;
}

@freezed
abstract class RamSourceInfo with _$RamSourceInfo {
  const factory RamSourceInfo({required String source, required double ramKb, int? pid, String? processName}) =
      _RamSourceInfo;
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
}
