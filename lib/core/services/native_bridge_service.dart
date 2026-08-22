import 'package:flutter/services.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';

class NativeBridgeService {
  static const MethodChannel _methodChannel =
      MethodChannel(AppConstants.methodChannelName);
  static const EventChannel _eventChannel =
      EventChannel(AppConstants.eventChannelName);

  Stream<dynamic>? _eventStream;

  Stream<dynamic> get monitoringEventsStream {
    _eventStream ??= _eventChannel.receiveBroadcastStream();
    return _eventStream!;
  }

  Future<String> checkPermission(String type) async {
    try {
      final result = await _methodChannel.invokeMethod<String>(
        'checkPermission',
        {'type': type},
      );
      return result ?? 'unknown';
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'checkPermission failed: $type', e, st);
      return 'unknown';
    }
  }

  Future<bool> openSettings(String type) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'openSettings',
        {'type': type},
      );
      return result ?? false;
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'openSettings failed: $type', e, st);
      return false;
    }
  }

  Future<bool> startMonitoringService() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'startMonitoringService',
      );
      AppLogger.i('NATIVE_BRIDGE', 'Foreground monitoring service started');
      return result ?? false;
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'startMonitoringService failed', e, st);
      return false;
    }
  }

  Future<bool> stopMonitoringService() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'stopMonitoringService',
      );
      AppLogger.i('NATIVE_BRIDGE', 'Foreground monitoring service stopped');
      return result ?? false;
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'stopMonitoringService failed', e, st);
      return false;
    }
  }

  Future<bool> isMonitoringServiceRunning() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'isMonitoringServiceRunning',
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getInstalledApps({
    bool includeSystem = false,
  }) async {
    try {
      final result = await _methodChannel.invokeListMethod<dynamic>(
        'getInstalledApps',
        {'includeSystem': includeSystem},
      );
      if (result == null) return [];

      return result.map((item) {
        final map = Map<String, dynamic>.from(item as Map);
        return {
          'packageName': map['packageName'] as String,
          'appName': map['appName'] as String,
          'isSystemApp': map['isSystemApp'] as bool? ?? false,
          'iconBytes': map['iconBytes'] as Uint8List?,
        };
      }).toList();
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'getInstalledApps failed', e, st);
      return [];
    }
  }

  Future<bool> sendToHomeScreen() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('sendToHomeScreen');
      AppLogger.i('NATIVE_BRIDGE', 'Sent user safely to Home Screen');
      return result ?? false;
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'sendToHomeScreen failed', e, st);
      return false;
    }
  }

  Future<bool> showDurationPickerOverlay({
    required String packageName,
    required String appName,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'showDurationPickerOverlay',
        {
          'packageName': packageName,
          'appName': appName,
        },
      );
      return result ?? false;
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'showDurationPickerOverlay failed', e, st);
      return false;
    }
  }

  Future<bool> showSessionExpiredOverlay({
    required String packageName,
    required String appName,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'showSessionExpiredOverlay',
        {
          'packageName': packageName,
          'appName': appName,
        },
      );
      return result ?? false;
    } catch (e, st) {
      AppLogger.e('NATIVE_BRIDGE', 'showSessionExpiredOverlay failed', e, st);
      return false;
    }
  }

  Future<bool> closeOverlay() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('closeOverlay');
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> syncMonitoredPackages(List<String> packages) async {
    try {
      await _methodChannel.invokeMethod('syncMonitoredPackages', {
        'packages': packages,
      });
    } catch (e) {
      AppLogger.w('NATIVE_BRIDGE', 'syncMonitoredPackages failed: $e');
    }
  }

  Future<void> syncActiveSession({
    required String packageName,
    required int expiresAtMs,
  }) async {
    try {
      await _methodChannel.invokeMethod('syncActiveSession', {
        'packageName': packageName,
        'expiresAt': expiresAtMs,
      });
    } catch (e) {
      AppLogger.w('NATIVE_BRIDGE', 'syncActiveSession failed: $e');
    }
  }

  Future<void> removeActiveSession(String packageName) async {
    try {
      await _methodChannel.invokeMethod('removeActiveSession', {
        'packageName': packageName,
      });
    } catch (e) {
      AppLogger.w('NATIVE_BRIDGE', 'removeActiveSession failed: $e');
    }
  }

  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final result = await _methodChannel.invokeMapMethod<String, dynamic>(
        'getDeviceInfo',
      );
      return result ?? {};
    } catch (e) {
      return {};
    }
  }

  Future<bool> openManufacturerAutostart() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'openManufacturerAutostart',
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> openXiaomiBackgroundPopup() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'openXiaomiBackgroundPopup',
      );
      return result ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<String?> getCurrentForegroundPackage() async {
    try {
      final result = await _methodChannel.invokeMethod<String>(
        'getCurrentForegroundPackage',
      );
      return result;
    } catch (e) {
      return null;
    }
  }
}
