import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../database/app_database.dart';
import '../permissions/app_permissions.dart';
import '../services/native_bridge_service.dart';
import '../../features/monitored_apps/domain/entities/monitored_app.dart';
import '../../features/monitored_apps/domain/repositories/monitored_apps_repository.dart';
import '../../features/monitored_apps/data/repositories/monitored_apps_repository_impl.dart';
import '../../features/sessions/domain/entities/app_usage_session.dart';
import '../../features/sessions/domain/repositories/session_repository.dart';
import '../../features/sessions/data/repositories/session_repository_impl.dart';
import '../../features/sessions/domain/services/session_engine.dart';
import '../../features/monitoring/domain/services/foreground_app_monitor.dart';
import '../../features/monitoring/data/services/foreground_app_monitor_impl.dart';
import '../../features/monitoring/domain/services/monitoring_state_machine.dart';
import '../../features/overlay/domain/services/overlay_controller.dart';
import '../../features/overlay/data/services/overlay_controller_impl.dart';

// Database Provider
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});

// Native Bridge Provider
final nativeBridgeProvider = Provider<NativeBridgeService>((ref) {
  return NativeBridgeService();
});

// Permission Manager Provider
final permissionManagerProvider = Provider<PermissionManager>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  final manager = PermissionManagerImpl(bridge);
  ref.onDispose(() => manager.dispose());
  return manager;
});

// Repositories
final monitoredAppsRepositoryProvider = Provider<MonitoredAppsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final bridge = ref.watch(nativeBridgeProvider);
  return MonitoredAppsRepositoryImpl(db, bridge);
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return SessionRepositoryImpl(db);
});

// Session Engine
final sessionEngineProvider = Provider<SessionEngine>((ref) {
  final sessionRepo = ref.watch(sessionRepositoryProvider);
  final bridge = ref.watch(nativeBridgeProvider);
  final engine = SessionEngine(
    sessionRepository: sessionRepo,
    nativeBridge: bridge,
  );
  engine.initialize();
  ref.onDispose(() => engine.dispose());
  return engine;
});

// Foreground App Monitor
final foregroundAppMonitorProvider = Provider<ForegroundAppMonitor>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  final monitor = ForegroundAppMonitorImpl(bridge);
  ref.onDispose(() => monitor.dispose());
  return monitor;
});

// Overlay Controller
final overlayControllerProvider = Provider<OverlayController>((ref) {
  final bridge = ref.watch(nativeBridgeProvider);
  return OverlayControllerImpl(bridge);
});

// Monitoring State Machine
final monitoringStateMachineProvider = Provider<MonitoringStateMachine>((ref) {
  final permManager = ref.watch(permissionManagerProvider);
  final appsRepo = ref.watch(monitoredAppsRepositoryProvider);
  final foregroundMonitor = ref.watch(foregroundAppMonitorProvider);
  final sessionEngine = ref.watch(sessionEngineProvider);
  final overlayController = ref.watch(overlayControllerProvider);
  final bridge = ref.watch(nativeBridgeProvider);
  final db = ref.watch(databaseProvider);

  final sm = MonitoringStateMachine(
    permissionManager: permManager,
    monitoredAppsRepo: appsRepo,
    foregroundMonitor: foregroundMonitor,
    sessionEngine: sessionEngine,
    overlayController: overlayController,
    nativeBridge: bridge,
    db: db,
  );
  ref.onDispose(() => sm.dispose());
  return sm;
});

// Streams & State Providers
final monitoredAppsStreamProvider = StreamProvider<List<MonitoredApp>>((ref) {
  final repo = ref.watch(monitoredAppsRepositoryProvider);
  return repo.watchMonitoredApps();
});

final activeSessionStreamProvider = StreamProvider<AppUsageSession?>((ref) {
  final engine = ref.watch(sessionEngineProvider);
  return engine.sessionStream;
});

final sessionHistoryStreamProvider = StreamProvider<List<AppUsageSession>>((ref) {
  final repo = ref.watch(sessionRepositoryProvider);
  return repo.watchAllSessions();
});

final monitoringStateStreamProvider = StreamProvider<MonitoringState>((ref) {
  final sm = ref.watch(monitoringStateMachineProvider);
  return sm.stateStream;
});

final permissionsStateStreamProvider =
    StreamProvider<Map<AppPermissionType, PermissionState>>((ref) {
  final manager = ref.watch(permissionManagerProvider);
  return manager.watchStates();
});
