import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:running_services_monitor/core/constants.dart';
import 'package:running_services_monitor/models/service_info.dart';
import 'app_info_service.dart';
import 'shizuku_service.dart';

@lazySingleton
class ProcessService {
  final ShizukuService _shizukuService;
  final AppInfoService _appInfoService;

  ProcessService(this._shizukuService, this._appInfoService);

  Future<String?> fetchRawServicesData() async {
    try {
      final result = await _shizukuService.executeCommand(AppConstants.cmdDumpsysActivityServices);
      return result;
    } catch (e) {
      debugPrint('Error fetching raw services data: $e');
      return null;
    }
  }

  Future<List<AppProcessInfo>> processServiceData({required String services, required String meminfo}) async {
    try {
      if (services.isEmpty) return [];


      await _appInfoService.ensureCacheValid();
      final appMap = _appInfoService.cachedAppsMap ?? {};


      final Map<String, String> appNames = {};
      for (var entry in appMap.entries) {
        appNames[entry.key] = entry.value.name;
      }


      final isolateData = _IsolateData(servicesOutput: services, meminfoOutput: meminfo, appNames: appNames);

      final appProcessInfos = await compute(_processDataInIsolate, isolateData);


      final updatedAppProcessInfos = <AppProcessInfo>[];

      for (var info in appProcessInfos) {
        var updatedInfo = info;


        var appInfo = appMap[info.packageName];

        updatedInfo = updatedInfo.copyWith(appInfo: appInfo);


        final updatedServices = <RunningServiceInfo>[];
        for (var service in info.services) {
          var updatedService = service;

          if (service.packageName == info.packageName && appInfo != null && appInfo.icon != null) {
            updatedService = updatedService.copyWith(icon: appInfo.icon);
          } else {
            final serviceAppInfo = appMap[service.packageName];
            if (serviceAppInfo != null && serviceAppInfo.icon != null) {
              updatedService = updatedService.copyWith(icon: serviceAppInfo.icon);
            }
          }
          updatedServices.add(updatedService);
        }
        updatedInfo = updatedInfo.copyWith(services: updatedServices);
        updatedAppProcessInfos.add(updatedInfo);
      }

      final finalAppProcessInfos = updatedAppProcessInfos;

      return finalAppProcessInfos;
    } catch (e) {
      debugPrint('Error processing service data: $e');
      return [];
    }
  }

  Future<List<AppProcessInfo>> getAppProcessInfos() async {
    final results = await Future.wait([fetchRawServicesData(), meminfo()]);

    final servicesData = results[0];
    final memInfo = results[1];

    if (servicesData == null || memInfo == null) return [];
    return processServiceData(services: servicesData, meminfo: memInfo);
  }

  Future<String?> meminfo() async {
    try {
      final result = await _shizukuService.executeCommand(AppConstants.cmdDumpsysMeminfo);
      return result;
    } catch (e) {
      debugPrint('Error getting meminfo: $e');
      return null;
    }
  }



  Future<({List<double>? ramInfo, String? meminfo})> getSystemRamInfo() async {
    try {
      final result = await meminfo();
      if (result == null) return (meminfo: result, ramInfo: null);

      return (ramInfo: await compute(_parseSystemRamInfo, result), meminfo: result);
    } catch (e) {
      debugPrint('Error getting system RAM info: $e');
      return (ramInfo: null, meminfo: null);
    }
  }




  Future<bool> stopServiceByPid(int pid) async {
    try {
      debugPrint('Attempting to kill PID: $pid');
      final result = await _shizukuService.executeCommand('kill -9 $pid');


      if (result == null ||
          result.isEmpty ||
          !result.toLowerCase().contains('error') && !result.toLowerCase().contains('permission denied')) {
        debugPrint('Successfully killed PID: $pid');
        return true;
      } else {
        debugPrint('Failed to kill PID $pid: $result');
        return false;
      }
    } catch (e) {
      debugPrint('Error killing PID $pid: $e');
      return false;
    }
  }




  Future<bool> stopService(String packageName) async {
    try {
      debugPrint('Attempting to stop service: $packageName');
      final result = await _shizukuService.executeCommand('am force-stop $packageName');


      if (result == null || result.isEmpty || !result.toLowerCase().contains('error')) {
        debugPrint('Successfully stopped: $packageName');
        return true;
      } else {
        debugPrint('Failed to stop $packageName: $result');
        return false;
      }
    } catch (e) {
      debugPrint('Error stopping service $packageName: $e');
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

  static Future<List<AppProcessInfo>> _processDataInIsolate(_IsolateData data) async {

    final services = _parseServices(data.servicesOutput);
    if (services.isEmpty) return [];


    final ramMap = _parseRamMap(data.meminfoOutput);


    final Map<String, List<RunningServiceInfo>> grouped = {};


    String formatRam(double kb) {
      if (kb > 1024 * 1024) {
        return '${(kb / (1024 * 1024)).toStringAsFixed(2)} GB';
      } else if (kb > 1024) {
        return '${(kb / 1024).toStringAsFixed(1)} MB';
      }
      return '${kb.toStringAsFixed(0)} KB';
    }


    final enrichedServices = services.map((service) {
      var updatedService = service;


      if (ramMap.containsKey(service.pid)) {
        final ramKb = ramMap[service.pid]!;
        updatedService = updatedService.copyWith(ramInKb: ramKb, ramUsage: formatRam(ramKb));
      }


      final cachedAppName = data.appNames[service.packageName];
      if (cachedAppName != null) {
        updatedService = updatedService.copyWith(appName: cachedAppName);
      } else {

        final parts = service.packageName.split('.');
        if (parts.isNotEmpty) {
          String name = parts.last;
          if (name.isNotEmpty) {
            name = name[0].toUpperCase() + name.substring(1);
          }
          updatedService = updatedService.copyWith(appName: name);
        } else {
          updatedService = updatedService.copyWith(appName: service.packageName);
        }
      }
      return updatedService;
    }).toList();


    for (var service in enrichedServices) {
      if (!grouped.containsKey(service.packageName)) {
        grouped[service.packageName] = [];
      }
      grouped[service.packageName]!.add(service);
    }


    final List<AppProcessInfo> appProcessInfos = [];

    grouped.forEach((packageName, serviceList) {
      double totalRamKb = 0;
      final Set<int> pids = {};
      String appName = packageName;
      bool isSystem = false;


      final cachedAppName = data.appNames[packageName];
      if (cachedAppName != null) {
        appName = cachedAppName;
      } else if (serviceList.isNotEmpty && serviceList.first.appName != null) {
        appName = serviceList.first.appName!;
      }

      for (var service in serviceList) {
        totalRamKb += service.ramInKb ?? 0;
        pids.add(service.pid);
        if (service.isSystemApp) isSystem = true;
      }

      appProcessInfos.add(
        AppProcessInfo(
          packageName: packageName,
          appName: appName,
          services: serviceList,
          pids: pids.toList(),
          totalRam: formatRam(totalRamKb),
          totalRamInKb: totalRamKb,
          isSystemApp: isSystem,
          appInfo: null,
        ),
      );
    });


    appProcessInfos.sort((a, b) => b.totalRamInKb.compareTo(a.totalRamInKb));

    return appProcessInfos;
  }

  static List<RunningServiceInfo> _parseServices(String dumpsysOutput) {
    final List<RunningServiceInfo> services = [];
    final lines = dumpsysOutput.split('\n');

    String? currentPackage;
    String? currentProcess;
    int? currentPid;
    String? currentService;
    String? currentRamUsage;
    double? currentRamInKb;
    int? currentUid;


    String formatRam(double kb) {
      if (kb > 1024 * 1024) {
        return '${(kb / (1024 * 1024)).toStringAsFixed(2)} GB';
      } else if (kb > 1024) {
        return '${(kb / 1024).toStringAsFixed(1)} MB';
      }
      return '${kb.toStringAsFixed(0)} KB';
    }

    for (var line in lines) {
      line = line.trim();

      if (line.contains('ServiceRecord{')) {
        final serviceMatch = RegExp(r'([a-z0-9.]+)/\.?([A-Za-z0-9.]+)').firstMatch(line);
        if (serviceMatch != null) {
          currentPackage = serviceMatch.group(1);
          currentService = serviceMatch.group(2);
        }
      } else if (line.contains('app=ProcessRecord{')) {
        final pidMatch = RegExp(r'(\d+):([^/]+)/(\d+)').firstMatch(line);
        if (pidMatch != null) {
          currentPid = int.tryParse(pidMatch.group(1) ?? '');
          currentProcess = pidMatch.group(2);
          currentUid = int.tryParse(pidMatch.group(3) ?? '');
        } else {
          final simplePidMatch = RegExp(r'(\d+):([^/]+)').firstMatch(line);
          if (simplePidMatch != null) {
            currentPid = int.tryParse(simplePidMatch.group(1) ?? '');
            currentProcess = simplePidMatch.group(2);
          }
        }

        final pssMatch = RegExp(r'lastPss=(\d+)').firstMatch(line);
        if (pssMatch != null) {
          final pssKb = int.tryParse(pssMatch.group(1) ?? '');
          if (pssKb != null) {
            currentRamInKb = pssKb.toDouble();
            currentRamUsage = formatRam(currentRamInKb);
          }
        }
      }

      if (currentPackage != null && currentPid != null && currentService != null) {
        final isSystem =
            (currentUid != null && currentUid < 10000) ||
            currentPackage.startsWith('com.android') ||
            currentPackage.startsWith('android') ||
            currentPackage.startsWith('com.google.android');

        services.add(
          RunningServiceInfo(
            user: '0',
            pid: currentPid,
            processName: currentProcess ?? currentPackage,
            serviceName: currentService,
            packageName: currentPackage,
            isSystemApp: isSystem,
            ramUsage: currentRamUsage,
            ramInKb: currentRamInKb,
          ),
        );

        currentPackage = null;
        currentProcess = null;
        currentPid = null;
        currentService = null;
        currentRamUsage = null;
        currentRamInKb = null;
        currentUid = null;
      }
    }

    return services;
  }

  static Map<int, double> _parseRamMap(String meminfoOutput) {
    final Map<int, double> ramMap = {};
    if (meminfoOutput.isEmpty) return ramMap;

    final lines = meminfoOutput.split('\n');
    final regex = RegExp(r'^\s*([\d,]+)K:\s+(\S+)\s+\(pid\s+(\d+)\)');

    for (var line in lines) {
      final match = regex.firstMatch(line);
      if (match != null) {
        final ramStr = match.group(1)?.replaceAll(',', '') ?? '0';
        final pidStr = match.group(3) ?? '0';

        final ramKb = double.tryParse(ramStr) ?? 0;
        final pid = int.tryParse(pidStr) ?? 0;

        if (pid > 0) {
          ramMap[pid] = ramKb;
        }
      }
    }
    return ramMap;
  }
}

class _IsolateData {
  final String servicesOutput;
  final String meminfoOutput;
  final Map<String, String> appNames;

  _IsolateData({required this.servicesOutput, required this.meminfoOutput, required this.appNames});
}
