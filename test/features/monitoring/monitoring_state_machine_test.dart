import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:mas7ool/core/permissions/app_permissions.dart';
import 'package:mas7ool/core/services/native_bridge_service.dart';
import 'package:mas7ool/features/monitored_apps/domain/entities/monitored_app.dart';
import 'package:mas7ool/features/monitored_apps/domain/repositories/monitored_apps_repository.dart';
import 'package:mas7ool/features/monitoring/domain/entities/foreground_event.dart';
import 'package:mas7ool/features/monitoring/domain/services/foreground_app_monitor.dart';
import 'package:mas7ool/features/monitoring/domain/services/monitoring_state_machine.dart';
import 'package:mas7ool/features/overlay/domain/services/overlay_controller.dart';
import 'package:mas7ool/features/sessions/domain/entities/app_usage_session.dart';
import 'package:mas7ool/features/sessions/domain/repositories/session_repository.dart';
import 'package:mas7ool/features/sessions/domain/services/session_engine.dart';

class FakePermissionManager implements PermissionManager {
  bool grantAll = true;

  @override
  Future<PermissionState> check(AppPermissionType type) async {
    return grantAll ? PermissionState.granted : PermissionState.denied;
  }

  @override
  Future<Map<AppPermissionType, PermissionState>> checkAll() async {
    return {
      AppPermissionType.usageAccess:
          grantAll ? PermissionState.granted : PermissionState.denied,
      AppPermissionType.overlay:
          grantAll ? PermissionState.granted : PermissionState.denied,
      AppPermissionType.notifications:
          grantAll ? PermissionState.granted : PermissionState.denied,
      AppPermissionType.batteryOptimization:
          grantAll ? PermissionState.granted : PermissionState.denied,
    };
  }

  @override
  Future<bool> request(AppPermissionType type) async => grantAll;

  @override
  Stream<Map<AppPermissionType, PermissionState>> watchStates() => Stream.empty();
}

class FakeMonitoredAppsRepository implements MonitoredAppsRepository {
  List<MonitoredApp> apps = [
    MonitoredApp(
      packageName: 'com.instagram.android',
      appName: 'Instagram',
      isEnabled: true,
      addedAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<MonitoredApp>> getMonitoredApps() async => apps;

  @override
  Stream<List<MonitoredApp>> watchMonitoredApps() => Stream.value(apps);

  @override
  Future<void> addMonitoredApp(MonitoredApp app) async => apps.add(app);

  @override
  Future<void> removeMonitoredApp(String packageName) async =>
      apps.removeWhere((a) => a.packageName == packageName);

  @override
  Future<void> toggleAppEnabled(String packageName, bool isEnabled) async {}

  @override
  Future<List<MonitoredApp>> scanInstalledApps({bool includeSystem = false}) async => apps;

  @override
  Future<void> syncNativeList() async {}

  @override
  Future<void> syncMissingIcons() async {}
}

class FakeForegroundAppMonitor implements ForegroundAppMonitor {
  final StreamController<ForegroundAppEvent> controller =
      StreamController<ForegroundAppEvent>.broadcast();

  @override
  Stream<ForegroundAppEvent> watch() => controller.stream;

  @override
  Future<String?> getCurrentForegroundPackage() async => 'com.instagram.android';
}

class FakeOverlayController implements OverlayController {
  bool isDurationOverlayOpen = false;
  bool isExpiredOverlayOpen = false;

  @override
  Future<void> showStartSessionOverlay({required MonitoredApp app}) async {
    isDurationOverlayOpen = true;
  }

  @override
  Future<void> showSessionExpiredOverlay({required MonitoredApp app}) async {
    isExpiredOverlayOpen = true;
  }

  @override
  Future<void> close() async {
    isDurationOverlayOpen = false;
    isExpiredOverlayOpen = false;
  }
}

class FakeSessionRepository implements SessionRepository {
  @override
  Future<void> clearHistory() async {}

  @override
  Future<AppUsageSession?> getActiveSession(String packageName) async => null;

  @override
  Future<List<AppUsageSession>> getAllSessions() async => [];

  @override
  Future<AppUsageSession?> getLatestSession() async => null;

  @override
  Future<void> saveSession(AppUsageSession session) async {}

  @override
  Stream<List<AppUsageSession>> watchAllSessions() => Stream.value([]);
}

class FakeNativeBridgeService extends NativeBridgeService {
  final StreamController<dynamic> eventsController =
      StreamController<dynamic>.broadcast();

  @override
  Stream<dynamic> get monitoringEventsStream => eventsController.stream;

  @override
  Future<bool> startMonitoringService() async => true;

  @override
  Future<bool> stopMonitoringService() async => true;

  @override
  Future<bool> closeOverlay() async => true;

  @override
  Future<bool> sendToHomeScreen() async => true;

  @override
  Future<void> syncMonitoredPackages(List<String> packages) async {}

  @override
  Future<void> syncActiveSession({
    required String packageName,
    String appName = '',
    required int expiresAtMs,
  }) async {}

  @override
  Future<bool> isSessionActiveInNative(String packageName) async => true;

  @override
  Future<Uint8List?> getAppIcon(String packageName) async => null;

  @override
  Future<void> removeActiveSession(String packageName) async {}
}

void main() {
  group('MonitoringStateMachine Unit Tests', () {
    late FakePermissionManager permManager;
    late FakeMonitoredAppsRepository appsRepo;
    late FakeForegroundAppMonitor monitor;
    late FakeOverlayController overlayController;
    late FakeSessionRepository sessionRepo;
    late FakeNativeBridgeService bridge;
    late SessionEngine sessionEngine;
    late MonitoringStateMachine stateMachine;

    setUp(() {
      permManager = FakePermissionManager();
      appsRepo = FakeMonitoredAppsRepository();
      monitor = FakeForegroundAppMonitor();
      overlayController = FakeOverlayController();
      sessionRepo = FakeSessionRepository();
      bridge = FakeNativeBridgeService();

      sessionEngine = SessionEngine(
        sessionRepository: sessionRepo,
        nativeBridge: bridge,
      );

      stateMachine = MonitoringStateMachine(
        permissionManager: permManager,
        monitoredAppsRepo: appsRepo,
        foregroundMonitor: monitor,
        sessionEngine: sessionEngine,
        overlayController: overlayController,
        nativeBridge: bridge,
      );
    });

    tearDown(() {
      stateMachine.dispose();
      sessionEngine.dispose();
    });

    test('Initial state is stopped', () {
      expect(stateMachine.currentState, MonitoringState.stopped);
    });

    test('startMonitoring succeeds when permissions are granted and moves to watching', () async {
      final success = await stateMachine.startMonitoring();
      expect(success, isTrue);
      expect(stateMachine.currentState, MonitoringState.watching);
    });

    test('startMonitoring fails when permissions are denied', () async {
      permManager.grantAll = false;
      final success = await stateMachine.startMonitoring();
      expect(success, isFalse);
      expect(stateMachine.currentState, MonitoringState.stopped);
    });

    test('Opening monitored app triggers overlay and transition to showingDurationOverlay', () async {
      await stateMachine.startMonitoring();

      monitor.controller.add(
        ForegroundAppEvent(
          packageName: 'com.instagram.android',
          appName: 'Instagram',
          timestamp: DateTime.now(),
          eventType: 'ACTIVITY_RESUMED',
        ),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      expect(stateMachine.currentState, MonitoringState.showingDurationOverlay);
      expect(overlayController.isDurationOverlayOpen, isTrue);
    });

    test('Selecting duration starts session and transitions to sessionActive', () async {
      await stateMachine.startMonitoring();

      bridge.eventsController.add({
        'action': 'durationSelected',
        'packageName': 'com.instagram.android',
        'durationMinutes': 5,
      });

      await Future.delayed(const Duration(milliseconds: 50));

      expect(stateMachine.currentState, MonitoringState.sessionActive);
      expect(sessionEngine.activeSession, isNotNull);
      expect(sessionEngine.activeSession!.packageName, 'com.instagram.android');
    });
  });
}
