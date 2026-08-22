import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../../core/services/native_bridge_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/utils/app_logger.dart';
import '../entities/app_usage_session.dart';
import '../repositories/session_repository.dart';

class SessionEngine {
  final SessionRepository _sessionRepository;
  final NativeBridgeService _nativeBridge;
  final _uuid = const Uuid();

  AppUsageSession? _activeSession;
  Timer? _tickerTimer;
  final StreamController<AppUsageSession?> _sessionStreamController =
      StreamController<AppUsageSession?>.broadcast();

  // Callback to trigger expired overlay
  void Function(AppUsageSession session)? onSessionExpired;

  SessionEngine({
    required SessionRepository sessionRepository,
    required NativeBridgeService nativeBridge,
    this.onSessionExpired,
  })  : _sessionRepository = sessionRepository,
        _nativeBridge = nativeBridge;

  AppUsageSession? get activeSession => _activeSession;
  Stream<AppUsageSession?> get sessionStream => _sessionStreamController.stream;

  Future<void> initialize() async {
    AppLogger.i('SESSION', 'Initializing Session Engine...');
    final latestSession = await _sessionRepository.getLatestSession();
    if (latestSession != null && latestSession.status.isRunning) {
      if (latestSession.isExpired) {
        AppLogger.w('SESSION', 'Found expired session from previous run: ${latestSession.packageName}');
        _activeSession = latestSession.copyWith(status: SessionStatus.expired);
        await _sessionRepository.saveSession(_activeSession!);
        await _nativeBridge.removeActiveSession(_activeSession!.packageName);
      } else {
        AppLogger.i('SESSION', 'Restoring active session for: ${latestSession.packageName}, remaining: ${latestSession.remainingTime.inSeconds}s');
        _activeSession = latestSession;
        _startTicker();
        await _nativeBridge.syncActiveSession(
          packageName: _activeSession!.packageName,
          expiresAtMs: _activeSession!.expiresAt.millisecondsSinceEpoch,
        );
      }
    }
    _sessionStreamController.add(_activeSession);
  }

  Future<AppUsageSession> startSession({
    required String packageName,
    required String appName,
    required int durationMinutes,
  }) async {
    // End any existing session first
    if (_activeSession != null && _activeSession!.status.isRunning) {
      await endSession(_activeSession!.packageName, sendHome: false);
    }

    final now = DateTime.now();
    final expiresAt = now.add(Duration(minutes: durationMinutes));

    final session = AppUsageSession(
      id: _uuid.v4(),
      packageName: packageName,
      appName: appName,
      startedAt: now,
      expiresAt: expiresAt,
      status: SessionStatus.active,
      extensionCount: 0,
      totalDurationMinutes: durationMinutes,
    );

    _activeSession = session;
    await _sessionRepository.saveSession(session);
    await _nativeBridge.syncActiveSession(
      packageName: packageName,
      expiresAtMs: expiresAt.millisecondsSinceEpoch,
    );
    await _nativeBridge.closeOverlay();

    AppLogger.i('SESSION', 'Started session for $packageName, duration=${durationMinutes}m, expiresAt=$expiresAt');

    _startTicker();
    _sessionStreamController.add(_activeSession);
    return session;
  }

  Future<void> extendSession(
    String packageName, {
    int additionalMinutes = 1,
  }) async {
    if (_activeSession == null || _activeSession!.packageName != packageName) {
      AppLogger.w('SESSION', 'Cannot extend session: no matching active session for $packageName');
      return;
    }

    final currentExpires = _activeSession!.expiresAt;
    final baseTime = currentExpires.isAfter(DateTime.now()) ? currentExpires : DateTime.now();
    final newExpiresAt = baseTime.add(Duration(minutes: additionalMinutes));

    _activeSession = _activeSession!.copyWith(
      expiresAt: newExpiresAt,
      status: SessionStatus.extended,
      extensionCount: _activeSession!.extensionCount + 1,
      totalDurationMinutes: _activeSession!.totalDurationMinutes + additionalMinutes,
    );

    await _sessionRepository.saveSession(_activeSession!);
    await _nativeBridge.syncActiveSession(
      packageName: packageName,
      expiresAtMs: newExpiresAt.millisecondsSinceEpoch,
    );
    await _nativeBridge.closeOverlay();

    AppLogger.i('SESSION', 'Extended session for $packageName by ${additionalMinutes}m. New expiry: $newExpiresAt');

    _startTicker();
    _sessionStreamController.add(_activeSession);
  }

  Future<void> endSession(String packageName, {bool sendHome = true}) async {
    if (_activeSession != null && _activeSession!.packageName == packageName) {
      _tickerTimer?.cancel();
      _activeSession = _activeSession!.copyWith(status: SessionStatus.ended);
      await _sessionRepository.saveSession(_activeSession!);
      await _nativeBridge.removeActiveSession(packageName);
      await _nativeBridge.closeOverlay();

      if (sendHome) {
        await _nativeBridge.sendToHomeScreen();
      }

      AppLogger.i('SESSION', 'Ended session for $packageName (sendHome=$sendHome)');
      _activeSession = null;
      _sessionStreamController.add(null);
    }
  }

  Future<void> cancelSession(String packageName) async {
    if (_activeSession != null && _activeSession!.packageName == packageName) {
      _tickerTimer?.cancel();
      _activeSession = _activeSession!.copyWith(status: SessionStatus.cancelled);
      await _sessionRepository.saveSession(_activeSession!);
      await _nativeBridge.removeActiveSession(packageName);
      await _nativeBridge.closeOverlay();
      AppLogger.i('SESSION', 'Cancelled session for $packageName');
      _activeSession = null;
      _sessionStreamController.add(null);
    }
  }

  void _startTicker() {
    _tickerTimer?.cancel();
    _tickerTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_activeSession == null) {
        timer.cancel();
        return;
      }

      if (_activeSession!.isExpired && _activeSession!.status.isRunning) {
        _handleExpiration();
      } else {
        _sessionStreamController.add(_activeSession);
      }
    });
  }

  Future<void> _handleExpiration() async {
    if (_activeSession == null) return;
    AppLogger.w('SESSION', 'Session expired for ${_activeSession!.packageName}');

    _activeSession = _activeSession!.copyWith(status: SessionStatus.expired);
    await _sessionRepository.saveSession(_activeSession!);
    await _nativeBridge.removeActiveSession(_activeSession!.packageName);

    // Trigger local notification
    await NotificationService.showSessionExpiredNotification(
      appName: _activeSession!.appName,
    );

    // Trigger Native / Flutter overlay
    await _nativeBridge.showSessionExpiredOverlay(
      packageName: _activeSession!.packageName,
      appName: _activeSession!.appName,
    );

    onSessionExpired?.call(_activeSession!);
    _sessionStreamController.add(_activeSession);
  }

  void dispose() {
    _tickerTimer?.cancel();
    _sessionStreamController.close();
  }
}
