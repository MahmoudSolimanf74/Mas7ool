import 'dart:async';
import '../services/native_bridge_service.dart';
import '../utils/app_logger.dart';

enum AppPermissionType {
  usageAccess,
  overlay,
  notifications,
  batteryOptimization,
}

enum PermissionState {
  granted,
  denied,
  restricted,
  unknown;

  bool get isGranted => this == PermissionState.granted;
}

abstract class PermissionManager {
  Future<PermissionState> check(AppPermissionType type);
  Future<bool> request(AppPermissionType type);
  Future<Map<AppPermissionType, PermissionState>> checkAll();
  Stream<Map<AppPermissionType, PermissionState>> watchStates();
}

class PermissionManagerImpl implements PermissionManager {
  final NativeBridgeService _nativeBridge;
  final StreamController<Map<AppPermissionType, PermissionState>> _stateController =
      StreamController<Map<AppPermissionType, PermissionState>>.broadcast();

  PermissionManagerImpl(this._nativeBridge);

  @override
  Future<PermissionState> check(AppPermissionType type) async {
    final stateStr = await _nativeBridge.checkPermission(type.name);
    final state = _parseState(stateStr);
    AppLogger.d('PERMISSION', 'Check ${type.name} -> $state');
    return state;
  }

  @override
  Future<bool> request(AppPermissionType type) async {
    AppLogger.i('PERMISSION', 'Requesting setting for: ${type.name}');
    final success = await _nativeBridge.openSettings(type.name);
    // After opening settings, recheck state
    await Future.delayed(const Duration(milliseconds: 500));
    await checkAll();
    return success;
  }

  @override
  Future<Map<AppPermissionType, PermissionState>> checkAll() async {
    final results = <AppPermissionType, PermissionState>{};
    for (final type in AppPermissionType.values) {
      results[type] = await check(type);
    }
    _stateController.add(results);
    return results;
  }

  @override
  Stream<Map<AppPermissionType, PermissionState>> watchStates() {
    return _stateController.stream;
  }

  PermissionState _parseState(String stateStr) {
    switch (stateStr.toLowerCase()) {
      case 'granted':
        return PermissionState.granted;
      case 'denied':
        return PermissionState.denied;
      case 'restricted':
        return PermissionState.restricted;
      default:
        return PermissionState.unknown;
    }
  }

  void dispose() {
    _stateController.close();
  }
}
