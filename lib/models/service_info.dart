// Model for running service information
class RunningServiceInfo {
  final String user;
  final int pid;
  final String processName;
  final String serviceName;
  final String packageName;
  final bool isSystemApp;
  final String? serviceClass;
  String? appName;
  String? ramUsage; // e.g. "25 MB"
  double? ramInKb; // Parsed value for aggregation

  RunningServiceInfo({
    required this.user,
    required this.pid,
    required this.processName,
    required this.serviceName,
    required this.packageName,
    required this.isSystemApp,
    this.serviceClass,
    this.appName,
    this.ramUsage,
    this.ramInKb,
  });

  @override
  String toString() {
    return 'Service: $serviceName (PID: $pid, Pkg: $packageName, App: $appName, RAM: $ramUsage)';
  }
}

// Model for running app/process information (Grouped)
class AppProcessInfo {
  final String packageName;
  final String appName;
  final List<RunningServiceInfo> services;
  final List<int> pids;
  final String totalRam; // Formatted string e.g. "150 MB"
  final double totalRamInKb; // For sorting/calculation
  final bool isSystemApp;
  final dynamic
  appInfo; // AppInfo from installed_apps package (dynamic to avoid circular dependency if possible, or just import)

  AppProcessInfo({
    required this.packageName,
    required this.appName,
    required this.services,
    required this.pids,
    required this.totalRam,
    required this.totalRamInKb,
    required this.isSystemApp,
    this.appInfo,
  });
}

// Model for running process information (Raw from ps/dumpsys if needed)
class RunningProcessInfo {
  final String packageName;
  final String processName;
  final int pid;
  final int uid;
  final String? appName;
  final bool isSystemApp;
  final String importance;

  RunningProcessInfo({
    required this.packageName,
    required this.processName,
    required this.pid,
    required this.uid,
    this.appName,
    required this.isSystemApp,
    required this.importance,
  });

  @override
  String toString() {
    return 'RunningProcessInfo(package: $packageName, process: $processName, pid: $pid, importance: $importance)';
  }
}
