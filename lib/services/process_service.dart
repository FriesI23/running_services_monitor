import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:running_services_monitor/core/constants.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'app_info_service.dart';
import 'shizuku_service.dart';
import 'package:running_services_monitor/utils/format_utils.dart';

@lazySingleton
class ProcessService {
  final ShizukuService _shizukuService;
  final AppInfoService _appInfoService;

  ProcessService(this._shizukuService, this._appInfoService);

  Future<ProcessedAppsResult> getAppProcessInfosWithRamInfo() async {
    try {
      final appMap = _appInfoService.cachedAppsMap ?? {};

      Map<int, double> pidRamMap = {};
      Map<String, double> processNameRamMap = {};

      final data = await meminfo();
      if (data != null) {
        final ramMaps = _parseRamMaps(data);
        pidRamMap = ramMaps.pidMap;
        processNameRamMap = ramMaps.processNameMap;
      }

      final systemRamInfo = data != null ? await compute(_parseSystemRamInfo, data) : null;

      final servicesOutput = await _shizukuService.executeCommand(AppConstants.cmdDumpsysActivityServices);
      if (servicesOutput == null || servicesOutput.isEmpty) {
        return ProcessedAppsResult(allApps: [], userApps: [], systemApps: [], appsRam: 0, ramInfo: systemRamInfo);
      }

      final Map<String, AppProcessInfo> groupedApps = {};

      List<String> currentBlock = [];
      String? currentPackage;

      final lines = servicesOutput.split('\n');
      for (final line in lines) {
        final trimmedLine = line.trim();

        if (trimmedLine.isEmpty) {
          if (currentBlock.isNotEmpty && currentPackage != null) {
            _processServiceBlock(
              currentBlock: currentBlock,
              currentPackage: currentPackage,
              groupedApps: groupedApps,
              appMap: appMap,
              pidRamMap: pidRamMap,
              processNameRamMap: processNameRamMap,
            );
            currentBlock.clear();
            currentPackage = null;
          }
        } else if (trimmedLine.contains('* ServiceRecord{')) {
          final serviceMatch = RegExp(r'([a-z0-9.]+)/\.?([A-Za-z0-9.]+)').firstMatch(trimmedLine);
          if (serviceMatch != null) {
            currentPackage = serviceMatch.group(1);
            currentBlock.add(line);
          }
        } else if (currentPackage != null) {
          currentBlock.add(line);
        }
      }

      if (currentBlock.isNotEmpty && currentPackage != null) {
        _processServiceBlock(
          currentBlock: currentBlock,
          currentPackage: currentPackage,
          groupedApps: groupedApps,
          appMap: appMap,
          pidRamMap: pidRamMap,
          processNameRamMap: processNameRamMap,
        );
      }

      await _processLruApps(
        groupedApps: groupedApps,
        appMap: appMap,
        pidRamMap: pidRamMap,
        processNameRamMap: processNameRamMap,
      );

      final allApps = groupedApps.values.toList();
      return categorizeApps(allApps, systemRamInfo);
    } catch (e) {
      return ProcessedAppsResult(allApps: [], userApps: [], systemApps: [], appsRam: 0, ramInfo: null);
    }
  }

  Future<void> _processLruApps({
    required Map<String, AppProcessInfo> groupedApps,
    required Map<String, dynamic> appMap,
    required Map<int, double> pidRamMap,
    required Map<String, double> processNameRamMap,
  }) async {
    final lruProcesses = await _fetchLruProcesses();

    for (final entry in groupedApps.entries) {
      final packageName = entry.key;
      var app = entry.value;

      if (lruProcesses.containsKey(packageName)) {
        final lruInfo = lruProcesses[packageName]!;
        app = app.copyWith(processState: lruInfo.state, adjLevel: lruInfo.adj);
        groupedApps[packageName] = app;
      }
    }

    for (final entry in lruProcesses.entries) {
      final packageName = entry.key;
      if (!groupedApps.containsKey(packageName)) {
        final lruInfo = entry.value;
        final processOnlyApp = _createLruAppInfo(
          packageName: packageName,
          lruInfo: lruInfo,
          appMap: appMap,
          pidRamMap: pidRamMap,
          processNameRamMap: processNameRamMap,
        );
        groupedApps[packageName] = processOnlyApp;
      }
    }
  }

  AppProcessInfo _createLruAppInfo({
    required String packageName,
    required ({String state, String adj, int pid, int uid}) lruInfo,
    required Map<String, dynamic> appMap,
    required Map<int, double> pidRamMap,
    required Map<String, double> processNameRamMap,
  }) {
    final isSystem = lruInfo.uid < 10000;

    String appName = packageName;
    final appInfo = appMap[packageName];
    if (appInfo != null) {
      appName = appInfo.name;
    } else {
      final parts = packageName.split('.');
      if (parts.isNotEmpty) {
        String name = parts.last;
        if (name.isNotEmpty) {
          name = name[0].toUpperCase() + name.substring(1);
        }
        appName = name;
      }
    }

    double ramKb = 0;
    final List<RamSourceInfo> ramSources = [];
    if (pidRamMap.containsKey(lruInfo.pid)) {
      ramKb = pidRamMap[lruInfo.pid]!;
      ramSources.add(RamSourceInfo(source: 'lru', ramKb: ramKb, pid: lruInfo.pid));
    } else if (processNameRamMap.containsKey(packageName)) {
      ramKb = processNameRamMap[packageName]!;
      ramSources.add(RamSourceInfo(source: 'process_name', ramKb: ramKb, processName: packageName));
    }

    return AppProcessInfo(
      packageName: packageName,
      appName: appName,
      services: [],
      pids: [lruInfo.pid],
      totalRam: formatRam(ramKb),
      totalRamInKb: ramKb,
      isSystemApp: isSystem,
      appInfo: appInfo,
      processState: lruInfo.state,
      adjLevel: lruInfo.adj,
      hasServices: false,
      ramSources: ramSources,
    );
  }

  ProcessedAppsResult categorizeApps(List<AppProcessInfo> allApps, [List<double>? ramInfo]) {
    List<AppProcessInfo> userApps = [];
    List<AppProcessInfo> systemApps = [];
    double appsRam = 0;

    for (var app in allApps) {
      if (app.isSystemApp) {
        systemApps.add(app);
      } else {
        userApps.add(app);
      }
      appsRam += app.totalRamInKb;
    }

    userApps.sort((a, b) => b.totalRamInKb.compareTo(a.totalRamInKb));
    systemApps.sort((a, b) => b.totalRamInKb.compareTo(a.totalRamInKb));

    return ProcessedAppsResult(
      allApps: allApps,
      userApps: userApps,
      systemApps: systemApps,
      appsRam: appsRam,
      ramInfo: ramInfo,
    );
  }

  void _processServiceBlock({
    required List<String> currentBlock,
    required String currentPackage,
    required Map<String, AppProcessInfo> groupedApps,
    required Map<String, dynamic> appMap,
    required Map<int, double> pidRamMap,
    required Map<String, double> processNameRamMap,
  }) {
    final services = _parseServiceBlock(currentBlock);

    if (services.isEmpty) return;

    if (groupedApps.containsKey(currentPackage)) {
      final existingApp = groupedApps[currentPackage]!;
      final mergedServices = [...existingApp.services, ...services];
      final Set<int> mergedPids = {...existingApp.pids, ...services.where((s) => s.pid != null).map((s) => s.pid!)};

      double totalRamKb = 0;
      final Set<int> countedPids = {};
      bool usedProcessNameFallback = false;
      for (var s in mergedServices) {
        if (s.pid != null && !countedPids.contains(s.pid)) {
          countedPids.add(s.pid!);
          if (pidRamMap.containsKey(s.pid)) {
            totalRamKb += pidRamMap[s.pid]!;
          } else if (s.ramInKb != null) {
            totalRamKb += s.ramInKb!;
          }
        }
      }
      if (totalRamKb <= 0 && !usedProcessNameFallback && processNameRamMap.containsKey(currentPackage)) {
        totalRamKb = processNameRamMap[currentPackage]!;
      }

      final enrichedServices = <RunningServiceInfo>[];
      for (var s in mergedServices) {
        var enriched = s;
        if (pidRamMap.containsKey(s.pid) && s.ramInKb == null) {
          final ramKb = pidRamMap[s.pid]!;
          enriched = enriched.copyWith(ramInKb: ramKb, ramUsage: formatRam(ramKb));
        }
        if (existingApp.appInfo?.icon != null && s.icon == null) {
          enriched = enriched.copyWith(icon: existingApp.appInfo!.icon);
        }
        enrichedServices.add(enriched);
      }

      final updatedApp = existingApp.copyWith(
        services: enrichedServices,
        pids: mergedPids.toList(),
        totalRam: formatRam(totalRamKb),
        totalRamInKb: totalRamKb,
      );
      groupedApps[currentPackage] = updatedApp;
    } else {
      final appProcessInfo = _createAppProcessInfo(
        packageName: currentPackage,
        services: services,
        appMap: appMap,
        pidRamMap: pidRamMap,
        processNameRamMap: processNameRamMap,
      );
      groupedApps[currentPackage] = appProcessInfo;
    }
  }

  ({Stream<AppProcessInfo> apps, Future<List<double>?> systemRamInfo}) streamAppProcessInfosWithRamInfo() {
    final meminfoCompleter = Completer<String?>();

    Stream<AppProcessInfo> appStream() async* {
      final appMap = _appInfoService.cachedAppsMap ?? {};

      Map<int, double> pidRamMap = {};
      Map<String, double> processNameRamMap = {};

      final data = await meminfo();
      meminfoCompleter.complete(data);
      if (data != null) {
        final ramMaps = _parseRamMaps(data);
        pidRamMap = ramMaps.pidMap;
        processNameRamMap = ramMaps.processNameMap;
      }

      final Map<String, AppProcessInfo> groupedApps = {};

      List<String> currentBlock = [];
      String? currentPackage;

      await for (final line in _shizukuService.executeCommandStream(AppConstants.cmdDumpsysActivityServices)) {
        final trimmedLine = line.trim();

        if (trimmedLine.isEmpty) {
          if (currentBlock.isNotEmpty && currentPackage != null) {
            final app = _processServiceBlockForStream(
              currentBlock: currentBlock,
              currentPackage: currentPackage,
              groupedApps: groupedApps,
              appMap: appMap,
              pidRamMap: pidRamMap,
              processNameRamMap: processNameRamMap,
            );
            if (app != null) yield app;
            currentBlock.clear();
            currentPackage = null;
          }
        } else if (trimmedLine.contains('* ServiceRecord{')) {
          final serviceMatch = RegExp(r'([a-z0-9.]+)/\.?([A-Za-z0-9.]+)').firstMatch(trimmedLine);
          if (serviceMatch != null) {
            currentPackage = serviceMatch.group(1);
            currentBlock.add(line);
          }
        } else if (currentPackage != null) {
          currentBlock.add(line);
        }
      }

      if (currentBlock.isNotEmpty && currentPackage != null) {
        final app = _processServiceBlockForStream(
          currentBlock: currentBlock,
          currentPackage: currentPackage,
          groupedApps: groupedApps,
          appMap: appMap,
          pidRamMap: pidRamMap,
          processNameRamMap: processNameRamMap,
        );
        if (app != null) yield app;
      }

      final lruProcesses = await _fetchLruProcesses();

      for (final entry in groupedApps.entries) {
        final packageName = entry.key;
        var app = entry.value;

        if (lruProcesses.containsKey(packageName)) {
          final lruInfo = lruProcesses[packageName]!;
          app = app.copyWith(processState: lruInfo.state, adjLevel: lruInfo.adj);
          groupedApps[packageName] = app;
          yield app;
        }
      }

      for (final entry in lruProcesses.entries) {
        final packageName = entry.key;
        if (!groupedApps.containsKey(packageName)) {
          final lruInfo = entry.value;
          final processOnlyApp = _createLruAppInfo(
            packageName: packageName,
            lruInfo: lruInfo,
            appMap: appMap,
            pidRamMap: pidRamMap,
            processNameRamMap: processNameRamMap,
          );
          groupedApps[packageName] = processOnlyApp;
          yield processOnlyApp;
        }
      }
    }

    final systemRamFuture = meminfoCompleter.future.then((data) async {
      if (data == null) return null;
      return _parseSystemRamInfo(data);
    });

    return (apps: appStream(), systemRamInfo: systemRamFuture);
  }

  AppProcessInfo? _processServiceBlockForStream({
    required List<String> currentBlock,
    required String currentPackage,
    required Map<String, AppProcessInfo> groupedApps,
    required Map<String, dynamic> appMap,
    required Map<int, double> pidRamMap,
    required Map<String, double> processNameRamMap,
  }) {
    final services = _parseServiceBlock(currentBlock);

    if (services.isEmpty) return null;

    if (groupedApps.containsKey(currentPackage)) {
      final existingApp = groupedApps[currentPackage]!;
      final mergedServices = [...existingApp.services, ...services];
      final Set<int> mergedPids = {...existingApp.pids, ...services.where((s) => s.pid != null).map((s) => s.pid!)};

      double totalRamKb = 0;
      final Set<int> countedPids = {};
      for (var s in mergedServices) {
        if (s.pid != null && !countedPids.contains(s.pid)) {
          countedPids.add(s.pid!);
          if (pidRamMap.containsKey(s.pid)) {
            totalRamKb += pidRamMap[s.pid]!;
          } else if (s.ramInKb != null) {
            totalRamKb += s.ramInKb!;
          }
        }
      }
      if (totalRamKb <= 0 && processNameRamMap.containsKey(currentPackage)) {
        totalRamKb = processNameRamMap[currentPackage]!;
      }

      final enrichedServices = <RunningServiceInfo>[];
      for (var s in mergedServices) {
        var enriched = s;
        if (pidRamMap.containsKey(s.pid) && s.ramInKb == null) {
          final ramKb = pidRamMap[s.pid]!;
          enriched = enriched.copyWith(ramInKb: ramKb, ramUsage: formatRam(ramKb));
        }
        if (existingApp.appInfo?.icon != null && s.icon == null) {
          enriched = enriched.copyWith(icon: existingApp.appInfo!.icon);
        }
        enrichedServices.add(enriched);
      }

      final updatedApp = existingApp.copyWith(
        services: enrichedServices,
        pids: mergedPids.toList(),
        totalRam: formatRam(totalRamKb),
        totalRamInKb: totalRamKb,
      );
      groupedApps[currentPackage] = updatedApp;
      return updatedApp;
    } else {
      final appProcessInfo = _createAppProcessInfo(
        packageName: currentPackage,
        services: services,
        appMap: appMap,
        pidRamMap: pidRamMap,
        processNameRamMap: processNameRamMap,
      );
      groupedApps[currentPackage] = appProcessInfo;
      return appProcessInfo;
    }
  }

  Future<Map<String, ({String state, String adj, int pid, int uid})>> _fetchLruProcesses() async {
    final Map<String, ({String state, String adj, int pid, int uid})> processes = {};

    try {
      final result = await _shizukuService.executeCommand(AppConstants.cmdDumpsysActivityLru);
      if (result == null || result.isEmpty) return processes;

      final lines = result.split('\n');
      for (final line in lines) {
        final parsed = _parseLruLine(line);
        if (parsed != null) {
          processes[parsed.packageName] = (state: parsed.state, adj: parsed.adj, pid: parsed.pid, uid: parsed.uid);
        }
      }
    } catch (_) {}

    return processes;
  }

  ({String packageName, String state, String adj, int pid, int uid})? _parseLruLine(String line) {
    final trimmed = line.trim();
    if (!trimmed.startsWith('#')) return null;

    final regex = RegExp(r'#\s*\d+:\s*(\S+)\s+(\S+)\s+\S+\s+(\d+):([^/]+)/u(\d+)a(\d+)');

    final match = regex.firstMatch(trimmed);
    if (match == null) return null;

    final state = match.group(1) ?? '';
    final adj = match.group(2) ?? '';
    final pid = int.tryParse(match.group(3) ?? '') ?? 0;
    final processName = match.group(4) ?? '';
    final userId = int.tryParse(match.group(5) ?? '0') ?? 0;
    final appId = int.tryParse(match.group(6) ?? '0') ?? 0;
    final uid = userId * 100000 + 10000 + appId;

    String packageName = processName;
    if (processName.contains(':')) {
      packageName = processName.split(':').first;
    }

    return (packageName: packageName, state: state, adj: adj, pid: pid, uid: uid);
  }

  List<RunningServiceInfo> _parseServiceBlock(List<String> lines) {
    final services = <RunningServiceInfo>[];

    String? packageName;
    String? serviceName;
    String? processName;
    int? pid;
    int? uid;
    String? intent;
    String? baseDir;
    String? dataDir;
    bool? isForeground;
    int? foregroundId;
    String? createTime;
    String? lastActivityTime;
    bool? startRequested;
    bool? createdFromFg;
    int? recentCallingUid;
    final connections = <ConnectionRecord>[];

    final rawBlock = lines.join('\n');

    for (var line in lines) {
      final trimmedLine = line.trim();

      if (trimmedLine.startsWith('* ConnectionRecord{') || trimmedLine.startsWith('ConnectionRecord{')) {
        final connMatch = RegExp(
          r'([a-z0-9.]+)/\.?([A-Za-z0-9.$]+):@([a-f0-9]+)\s+flags=(0x[a-f0-9]+)',
        ).firstMatch(trimmedLine);
        if (connMatch != null) {
          final connPackageName = connMatch.group(1) ?? '';
          final connServiceName = connMatch.group(2) ?? '';
          final conn = connMatch.group(3);
          final flags = connMatch.group(4);

          final connIsForeground = trimmedLine.contains(' FGS ') || trimmedLine.contains(' FG ');
          final isVisible = trimmedLine.contains(' VIS ');
          final hasCapabilities = trimmedLine.contains(' CAPS ');

          connections.add(
            ConnectionRecord(
              packageName: connPackageName,
              serviceName: connServiceName,
              conn: conn,
              flags: flags,
              isForeground: connIsForeground,
              isVisible: isVisible,
              hasCapabilities: hasCapabilities,
              rawConnectionRecord: trimmedLine,
            ),
          );
        }
        continue;
      }

      if (trimmedLine.startsWith('* ServiceRecord{')) {
        final serviceMatch = RegExp(r'([a-z0-9.]+)/\.?([A-Za-z0-9.]+)').firstMatch(trimmedLine);
        if (serviceMatch != null) {
          serviceName = serviceMatch.group(2);
        }
      } else if (trimmedLine.startsWith('intent=')) {
        intent = trimmedLine.substring('intent='.length);
      } else if (trimmedLine.startsWith('packageName=')) {
        packageName = trimmedLine.substring('packageName='.length);
      } else if (trimmedLine.startsWith('processName=')) {
        processName = trimmedLine.substring('processName='.length);
      } else if (trimmedLine.startsWith('baseDir=')) {
        baseDir = trimmedLine.substring('baseDir='.length);
      } else if (trimmedLine.startsWith('dataDir=')) {
        dataDir = trimmedLine.substring('dataDir='.length);
      } else if (trimmedLine.startsWith('isForeground=')) {
        isForeground = trimmedLine.substring('isForeground='.length) == 'true';
      } else if (trimmedLine.startsWith('foregroundId=')) {
        foregroundId = int.tryParse(trimmedLine.substring('foregroundId='.length));
      } else if (trimmedLine.startsWith('createTime=')) {
        createTime = trimmedLine.substring('createTime='.length);
      } else if (trimmedLine.startsWith('lastActivity=')) {
        lastActivityTime = trimmedLine.substring('lastActivity='.length);
      } else if (trimmedLine.startsWith('startRequested=')) {
        startRequested = trimmedLine.substring('startRequested='.length) == 'true';
      } else if (trimmedLine.startsWith('createdFromFg=')) {
        createdFromFg = trimmedLine.substring('createdFromFg='.length) == 'true';
      } else if (trimmedLine.startsWith('recentCallingUid=')) {
        recentCallingUid = int.tryParse(trimmedLine.substring('recentCallingUid='.length));
      } else if (trimmedLine.startsWith('app=ProcessRecord{')) {
        final pidMatch = RegExp(r'(\d+):([^/]+)/u(\d+)a(\d+)').firstMatch(trimmedLine);
        if (pidMatch != null) {
          pid = int.tryParse(pidMatch.group(1) ?? '');
          final userId = int.tryParse(pidMatch.group(3) ?? '0') ?? 0;
          final appId = int.tryParse(pidMatch.group(4) ?? '0') ?? 0;
          uid = userId * 100000 + 10000 + appId;
        }
      }
    }

    if (packageName != null && serviceName != null) {
      final isSystem =
          (uid != null && uid < 10000) ||
          (baseDir != null &&
              (baseDir.startsWith('/system') || baseDir.startsWith('/product') || baseDir.startsWith('/system_ext')));

      services.add(
        RunningServiceInfo(
          user: '0',
          pid: pid,
          processName: processName ?? packageName,
          serviceName: serviceName,
          packageName: packageName,
          isSystemApp: isSystem,
          intent: intent,
          baseDir: baseDir,
          dataDir: dataDir,
          isForeground: isForeground,
          foregroundId: foregroundId,
          createTime: createTime,
          lastActivityTime: lastActivityTime,
          startRequested: startRequested,
          createdFromFg: createdFromFg,
          rawServiceRecord: rawBlock,
          uid: uid,
          recentCallingUid: recentCallingUid,
          connections: connections,
        ),
      );
    }

    return services;
  }

  AppProcessInfo _createAppProcessInfo({
    required String packageName,
    required List<RunningServiceInfo> services,
    required Map<String, dynamic> appMap,
    required Map<int, double> pidRamMap,
    required Map<String, double> processNameRamMap,
  }) {
    double totalRamKb = 0;
    final Set<int> pids = {};
    bool isSystem = false;
    String appName = packageName;
    final List<RamSourceInfo> ramSources = [];

    final appInfo = appMap[packageName];
    if (appInfo != null) {
      appName = appInfo.name;
    } else {
      final parts = packageName.split('.');
      if (parts.isNotEmpty) {
        String name = parts.last;
        if (name.isNotEmpty) {
          name = name[0].toUpperCase() + name.substring(1);
        }
        appName = name;
      }
    }

    final enrichedServices = <RunningServiceInfo>[];
    for (var service in services) {
      if (service.pid != null) {
        final isNewPid = pids.add(service.pid!);
        if (isNewPid && pidRamMap.containsKey(service.pid)) {
          final ramKb = pidRamMap[service.pid]!;
          totalRamKb += ramKb;
          ramSources.add(RamSourceInfo(source: 'pid', ramKb: ramKb, pid: service.pid));
        }
      }
      if (service.isSystemApp) isSystem = true;

      var enrichedService = service;

      if (pidRamMap.containsKey(service.pid)) {
        final ramKb = pidRamMap[service.pid]!;
        enrichedService = enrichedService.copyWith(ramInKb: ramKb, ramUsage: formatRam(ramKb));
      }

      if (appInfo != null && appInfo.icon != null) {
        enrichedService = enrichedService.copyWith(icon: appInfo.icon);
      }

      enrichedService = enrichedService.copyWith(appName: appName);
      enrichedServices.add(enrichedService);
    }

    if (totalRamKb <= 0 && processNameRamMap.containsKey(packageName)) {
      totalRamKb = processNameRamMap[packageName]!;
      ramSources.add(RamSourceInfo(source: 'process_name', ramKb: totalRamKb, processName: packageName));
    }

    return AppProcessInfo(
      packageName: packageName,
      appName: appName,
      services: enrichedServices,
      pids: pids.toList(),
      totalRam: formatRam(totalRamKb),
      totalRamInKb: totalRamKb,
      isSystemApp: isSystem,
      appInfo: appInfo,
      ramSources: ramSources,
    );
  }

  Future<String?> meminfo({void Function(String)? onProgress}) async {
    try {
      final result = await _shizukuService.executeCommand(AppConstants.cmdDumpsysMeminfo);
      if (result != null) {
        onProgress?.call(result);
      }
      return result;
    } catch (e) {
      return null;
    }
  }

  Future<bool> stopServiceByComponent({required String packageName, required String serviceName}) async {
    try {
      final serviceComponent = serviceName.startsWith('.')
          ? '$packageName/$packageName$serviceName'
          : '$packageName/$serviceName';
      final result = await _shizukuService.executeCommand('am stop-service $serviceComponent');
      if (result == null || result.isEmpty || !result.toLowerCase().contains('error')) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopServiceByPid(int pid) async {
    try {
      final result = await _shizukuService.executeCommand('kill -9 $pid');
      if (result == null ||
          result.isEmpty ||
          !result.toLowerCase().contains('error') && !result.toLowerCase().contains('permission denied')) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> stopService(String packageName) async {
    try {
      final result = await _shizukuService.executeCommand('am force-stop $packageName');

      if (result == null || result.isEmpty || !result.toLowerCase().contains('error')) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  static List<double> _parseSystemRamInfo(String result) {
    double totalRam = 0;
    double freeRam = 0;

    final totalMatch = RegExp(r'Total RAM:\s+([\d,]+)K').firstMatch(result);
    if (totalMatch != null) {
      totalRam = double.tryParse(totalMatch.group(1)!.replaceAll(',', '')) ?? 0;
    }

    final freeMatch = RegExp(r'Free RAM:\s+([\d,]+)K').firstMatch(result);
    if (freeMatch != null) {
      freeRam = double.tryParse(freeMatch.group(1)!.replaceAll(',', '')) ?? 0;
    }

    double usedRam = totalRam - freeRam;

    return [totalRam, freeRam, usedRam];
  }

  static ({Map<int, double> pidMap, Map<String, double> processNameMap}) _parseRamMaps(String meminfoOutput) {
    final Map<int, double> pidMap = {};
    final Map<String, double> processNameMap = {};
    if (meminfoOutput.isEmpty) return (pidMap: pidMap, processNameMap: processNameMap);

    final lines = meminfoOutput.split('\n');
    final regex = RegExp(r'^\s*([\d,]+)K:\s+(\S+)\s+\(pid\s+(\d+)');

    for (var line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final ramStr = match.group(1)?.replaceAll(',', '') ?? '0';
        final processName = match.group(2) ?? '';
        final pidStr = match.group(3) ?? '0';

        final ramKb = double.tryParse(ramStr) ?? 0;
        final pid = int.tryParse(pidStr) ?? 0;

        if (pid > 0 && !pidMap.containsKey(pid)) {
          pidMap[pid] = ramKb;
        }
        if (processName.isNotEmpty) {
          if (!processNameMap.containsKey(processName)) {
            processNameMap[processName] = ramKb;
          }
          if (processName.contains(':')) {
            final basePackageName = processName.split(':').first;
            if (!processNameMap.containsKey(basePackageName)) {
              processNameMap[basePackageName] = ramKb;
            }
          }
        }
      }
    }
    return (pidMap: pidMap, processNameMap: processNameMap);
  }
}