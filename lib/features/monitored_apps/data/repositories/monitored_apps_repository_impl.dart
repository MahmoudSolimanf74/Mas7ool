import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../../../core/services/native_bridge_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/entities/monitored_app.dart';
import '../../domain/repositories/monitored_apps_repository.dart';

class MonitoredAppsRepositoryImpl implements MonitoredAppsRepository {
  final AppDatabase _db;
  final NativeBridgeService _nativeBridge;
  final Map<String, Uint8List?> _iconCache = {};

  MonitoredAppsRepositoryImpl(this._db, this._nativeBridge);

  @override
  Future<List<MonitoredApp>> getMonitoredApps() async {
    final rows = await _db.getAllMonitoredApps();
    return rows.map((r) => _mapRowToEntity(r)).toList();
  }

  @override
  Stream<List<MonitoredApp>> watchMonitoredApps() {
    return _db.watchAllMonitoredApps().map((rows) {
      return rows.map((r) => _mapRowToEntity(r)).toList();
    });
  }

  @override
  Future<void> addMonitoredApp(MonitoredApp app) async {
    _iconCache[app.packageName] = app.icon;
    await _db.insertOrUpdateMonitoredApp(
      MonitoredAppsTableCompanion(
        packageName: Value(app.packageName),
        appName: Value(app.appName),
        iconBytes: Value(app.icon),
        isEnabled: const Value(true), // Always enabled upon addition
        addedAt: Value(app.addedAt),
        defaultDurationMinutes: Value(app.defaultDurationMinutes),
      ),
    );
    await syncNativeList();
  }

  @override
  Future<void> removeMonitoredApp(String packageName) async {
    _iconCache.remove(packageName);
    await _db.deleteMonitoredApp(packageName);
    await syncNativeList();
  }

  @override
  Future<void> toggleAppEnabled(String packageName, bool isEnabled) async {
    await _db.setAppEnabled(packageName, isEnabled);
    await syncNativeList();
  }

  @override
  Future<List<MonitoredApp>> scanInstalledApps({
    bool includeSystem = false,
  }) async {
    AppLogger.d('MONITORED_APPS', 'Scanning installed apps from native...');
    final rawApps =
        await _nativeBridge.getInstalledApps(includeSystem: includeSystem);

    final List<MonitoredApp> apps = [];
    for (final raw in rawApps) {
      final pkg = raw['packageName'] as String;
      final name = raw['appName'] as String;
      final iconBytes = raw['iconBytes'] as Uint8List?;

      if (iconBytes != null) {
        _iconCache[pkg] = iconBytes;
      }

      apps.add(
        MonitoredApp(
          packageName: pkg,
          appName: name,
          icon: iconBytes,
          isEnabled: false,
          addedAt: DateTime.now(),
        ),
      );
    }
    return apps;
  }

  @override
  Future<void> syncNativeList() async {
    final apps = await _db.getAllMonitoredApps();
    final enabledPackages =
        apps.where((a) => a.isEnabled).map((a) => a.packageName).toList();
    await _nativeBridge.syncMonitoredPackages(enabledPackages);
  }

  MonitoredApp _mapRowToEntity(MonitoredAppData row) {
    final icon = row.iconBytes ?? _iconCache[row.packageName];
    if (icon != null) {
      _iconCache[row.packageName] = icon;
    }
    return MonitoredApp(
      packageName: row.packageName,
      appName: row.appName,
      icon: icon,
      isEnabled: row.isEnabled,
      addedAt: row.addedAt,
      defaultDurationMinutes: row.defaultDurationMinutes,
    );
  }
}
