import 'dart:async';
import 'package:mas7ool/core/permissions/app_permissions.dart';
import 'package:mas7ool/core/services/native_bridge_service.dart';
import 'package:mas7ool/core/utils/app_logger.dart';
import 'package:mas7ool/features/monitored_apps/domain/entities/monitored_app.dart';
import 'package:mas7ool/features/monitored_apps/domain/repositories/monitored_apps_repository.dart';
import 'package:mas7ool/features/overlay/domain/services/overlay_controller.dart';
import 'package:mas7ool/features/sessions/domain/entities/app_usage_session.dart';
import 'package:mas7ool/features/sessions/domain/services/session_engine.dart';
import '../entities/foreground_event.dart';
import 'foreground_app_monitor.dart';

enum MonitoringState {
  stopped,
  checkingPermissions,
  ready,
  watching,
  monitoredAppDetected,
  showingDurationOverlay,
  sessionActive,
  sessionExpired,
  showingExpiredOverlay;

  bool get isMonitoring =>
      this != MonitoringState.stopped &&
      this != MonitoringState.checkingPermissions;
}

class MonitoringStateMachine {
  final PermissionManager _permissionManager;
  final MonitoredAppsRepository _monitoredAppsRepo;
  final ForegroundAppMonitor _foregroundMonitor;
  final SessionEngine _sessionEngine;
  final OverlayController _overlayController;
  final NativeBridgeService _nativeBridge;

  MonitoringState _currentState = MonitoringState.stopped;
  final StreamController<MonitoringState> _stateController =
      StreamController<MonitoringState>.broadcast();

  StreamSubscription? _foregroundSub;
  StreamSubscription? _overlayActionsSub;
  StreamSubscription? _sessionSub;

  String? _lastPromptedPackage;
  DateTime _lastPromptTime = DateTime.fromMillisecondsSinceEpoch(0);

  MonitoringStateMachine({
    required PermissionManager permissionManager,
    required MonitoredAppsRepository monitoredAppsRepo,
    required ForegroundAppMonitor foregroundMonitor,
    required SessionEngine sessionEngine,
    required OverlayController overlayController,
    required NativeBridgeService nativeBridge,
  })  : _permissionManager = permissionManager,
        _monitoredAppsRepo = monitoredAppsRepo,
        _foregroundMonitor = foregroundMonitor,
        _sessionEngine = sessionEngine,
        _overlayController = overlayController,
        _nativeBridge = nativeBridge {
    _initListeners();
  }

  MonitoringState get currentState => _currentState;
  Stream<MonitoringState> get stateStream => _stateController.stream;

  void _transitionTo(MonitoringState newState, [String reason = '']) {
    if (_currentState == newState) return;
    AppLogger.i('STATE_MACHINE', 'Transition: ${_currentState.name} -> ${newState.name} ${reason.isNotEmpty ? "($reason)" : ""}');
    _currentState = newState;
    _stateController.add(_currentState);
  }

  void _initListeners() {
    // Listen to session engine updates
    _sessionSub = _sessionEngine.sessionStream.listen((session) {
      if (session == null) {
        if (_currentState.isMonitoring && _currentState != MonitoringState.watching) {
          _transitionTo(MonitoringState.watching, 'No active session');
        }
      } else if (session.status == SessionStatus.active || session.status == SessionStatus.extended) {
        _transitionTo(MonitoringState.sessionActive, 'Session running');
      } else if (session.status == SessionStatus.expired) {
        _transitionTo(MonitoringState.showingExpiredOverlay, 'Session expired');
      }
    });

    // Listen to native overlay responses from EventChannel
    _overlayActionsSub = _nativeBridge.monitoringEventsStream.listen((data) {
      if (data is Map && data.containsKey('action')) {
        _handleNativeAction(Map<String, dynamic>.from(data));
      }
    });
  }

  Future<bool> startMonitoring() async {
    _transitionTo(MonitoringState.checkingPermissions, 'Starting monitoring check');

    final permMap = await _permissionManager.checkAll();
    final usageOk = permMap[AppPermissionType.usageAccess]?.isGranted ?? false;
    final overlayOk = permMap[AppPermissionType.overlay]?.isGranted ?? false;

    if (!usageOk || !overlayOk) {
      AppLogger.w('STATE_MACHINE', 'Permissions missing: usage=$usageOk, overlay=$overlayOk');
      _transitionTo(MonitoringState.stopped, 'Missing permissions');
      return false;
    }

    _transitionTo(MonitoringState.ready, 'Permissions validated');

    // Start native Foreground Service
    await _nativeBridge.startMonitoringService();
    await _monitoredAppsRepo.syncNativeList();

    // Start Foreground App event watcher
    _foregroundSub?.cancel();
    _foregroundSub = _foregroundMonitor.watch().listen(_onForegroundEvent);

    final currentSession = _sessionEngine.activeSession;
    if (currentSession != null && currentSession.status.isRunning) {
      _transitionTo(MonitoringState.sessionActive, 'Restored ongoing session');
    } else {
      _transitionTo(MonitoringState.watching, 'Watching foreground apps');
    }

    return true;
  }

  Future<void> stopMonitoring() async {
    AppLogger.i('STATE_MACHINE', 'Stopping monitoring...');
    _foregroundSub?.cancel();
    _foregroundSub = null;
    await _nativeBridge.stopMonitoringService();
    await _overlayController.close();
    _transitionTo(MonitoringState.stopped, 'User stopped monitoring');
  }

  Future<void> _onForegroundEvent(ForegroundAppEvent event) async {
    if (_currentState == MonitoringState.stopped) return;

    if (_currentState == MonitoringState.showingDurationOverlay ||
        _currentState == MonitoringState.showingExpiredOverlay) {
      return;
    }

    final monitoredApps = await _monitoredAppsRepo.getMonitoredApps();
    final targetApp = monitoredApps.firstWhere(
      (a) => a.packageName == event.packageName && a.isEnabled,
      orElse: () => MonitoredApp(
        packageName: '',
        appName: '',
        isEnabled: false,
        addedAt: DateTime.now(),
      ),
    );

    if (targetApp.packageName.isEmpty) {
      AppLogger.d('STATE_MACHINE', 'App not monitored or disabled: ${event.packageName} (Total monitored: ${monitoredApps.length})');
      return;
    }

    AppLogger.i('STATE_MACHINE', 'MATCHED Monitored App: ${targetApp.appName} (${targetApp.packageName})');
    _transitionTo(MonitoringState.monitoredAppDetected, 'Opened ${targetApp.appName}');

    final activeSession = _sessionEngine.activeSession;
    if (activeSession != null && activeSession.packageName == targetApp.packageName) {
      if (activeSession.status.isRunning && !activeSession.isExpired) {
        // App has an active running unexpired session -> allow usage without popup
        _transitionTo(MonitoringState.sessionActive, 'Active session already running for ${targetApp.appName}');
        return;
      }
    }

    // Debounce duplicate overlay prompts for the same app within 3 seconds
    final now = DateTime.now();
    if (_lastPromptedPackage == targetApp.packageName &&
        now.difference(_lastPromptTime).inSeconds < 3) {
      return;
    }

    _lastPromptedPackage = targetApp.packageName;
    _lastPromptTime = now;

    // Show duration overlay
    _transitionTo(MonitoringState.showingDurationOverlay, 'Displaying picker for ${targetApp.appName}');
    await _overlayController.showStartSessionOverlay(app: targetApp);
  }

  Future<void> _handleNativeAction(Map<String, dynamic> actionMap) async {
    final action = actionMap['action'] as String? ?? '';
    final packageName = actionMap['packageName'] as String? ?? '';

    AppLogger.i('STATE_MACHINE', 'Received overlay action: $action for $packageName');

    switch (action) {
      case 'durationSelected':
        final durationMinutes = actionMap['durationMinutes'] as int? ?? 5;
        final apps = await _monitoredAppsRepo.getMonitoredApps();
        final app = apps.firstWhere(
          (a) => a.packageName == packageName,
          orElse: () => MonitoredApp(
            packageName: packageName,
            appName: packageName,
            addedAt: DateTime.now(),
          ),
        );
        await _sessionEngine.startSession(
          packageName: packageName,
          appName: app.appName,
          durationMinutes: durationMinutes,
        );
        _transitionTo(MonitoringState.sessionActive, 'User selected $durationMinutes mins');
        break;

      case 'extendSession':
        final additionalMinutes = actionMap['additionalMinutes'] as int? ?? 1;
        await _sessionEngine.extendSession(packageName, additionalMinutes: additionalMinutes);
        _transitionTo(MonitoringState.sessionActive, 'User extended +$additionalMinutes mins');
        break;

      case 'closeApp':
        await _sessionEngine.endSession(packageName, sendHome: true);
        _transitionTo(MonitoringState.watching, 'User closed monitored app');
        break;

      case 'overlayDismissed':
        if (_currentState == MonitoringState.showingDurationOverlay ||
            _currentState == MonitoringState.showingExpiredOverlay) {
          _transitionTo(MonitoringState.watching, 'Overlay dismissed');
        }
        break;
    }
  }

  void dispose() {
    _foregroundSub?.cancel();
    _overlayActionsSub?.cancel();
    _sessionSub?.cancel();
    _stateController.close();
  }
}
