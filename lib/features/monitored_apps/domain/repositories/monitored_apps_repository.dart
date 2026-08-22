import '../entities/monitored_app.dart';

abstract class MonitoredAppsRepository {
  Future<List<MonitoredApp>> getMonitoredApps();
  Stream<List<MonitoredApp>> watchMonitoredApps();
  Future<void> addMonitoredApp(MonitoredApp app);
  Future<void> removeMonitoredApp(String packageName);
  Future<void> toggleAppEnabled(String packageName, bool isEnabled);
  Future<List<MonitoredApp>> scanInstalledApps({bool includeSystem = false});
  Future<void> syncNativeList();
}
