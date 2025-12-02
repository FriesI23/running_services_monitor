import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';
import 'package:running_services_monitor/core/constants.dart';

@lazySingleton
class ShizukuService {
  ShizukuService();

  static const _channel = MethodChannel(AppConstants.shizukuChannelName);

  bool _isInitialized = false;
  bool _hasPermission = false;

  bool get isInitialized => _isInitialized;
  bool get hasPermission => _hasPermission;


  Future<bool> isShizukuRunning() async {
    try {
      debugPrint('Checking if Shizuku is running...');
      final bool isRunning = await _channel.invokeMethod('pingBinder');
      debugPrint('Shizuku running: $isRunning');
      return isRunning;
    } catch (e) {
      debugPrint('Error checking Shizuku status: $e');
      return false;
    }
  }


  Future<bool> checkPermission() async {
    try {
      debugPrint('Checking Shizuku permission...');
      final bool granted = await _channel.invokeMethod('checkPermission');
      _hasPermission = granted;
      debugPrint('Shizuku permission granted: $_hasPermission');
      return _hasPermission;
    } catch (e) {
      debugPrint('Error checking Shizuku permission: $e');
      return false;
    }
  }


  Future<bool> requestPermission() async {
    try {
      debugPrint('Requesting Shizuku permission...');
      final bool granted = await _channel.invokeMethod('requestPermission');
      _hasPermission = granted;
      debugPrint('Shizuku permission result: $_hasPermission');
      return _hasPermission;
    } catch (e) {
      debugPrint('Error requesting Shizuku permission: $e');
      return false;
    }
  }


  Future<bool> initialize() async {
    if (_isInitialized) {
      debugPrint('Shizuku already initialized');
      return true;
    }


    final isRunning = await isShizukuRunning();
    if (!isRunning) {
      debugPrint('Shizuku is not running');
      return false;
    }


    final hasPermission = await checkPermission();
    if (!hasPermission) {

      final granted = await requestPermission();
      if (!granted) {
        debugPrint('Shizuku permission not granted');
        return false;
      }
    }

    _isInitialized = true;
    _hasPermission = true;
    debugPrint('Shizuku initialized successfully');
    return true;
  }


  Future<String?> executeCommand(String command) async {
    if (!_isInitialized || !_hasPermission) {
      debugPrint('Shizuku not initialized or no permission');
      return null;
    }

    try {
      debugPrint('Executing command: $command');
      final String? result = await _channel.invokeMethod(AppConstants.cmdMethodRunCommand, {'command': command});
      debugPrint('Command result length: ${result?.length ?? 0} characters');
      return result;
    } catch (e) {
      debugPrint('Error executing command: $e');
      return null;
    }
  }
}
