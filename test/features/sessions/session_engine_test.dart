import 'package:flutter_test/flutter_test.dart';
import 'package:mas7ool/core/services/native_bridge_service.dart';
import 'package:mas7ool/features/sessions/domain/entities/app_usage_session.dart';
import 'package:mas7ool/features/sessions/domain/repositories/session_repository.dart';
import 'package:mas7ool/features/sessions/domain/services/session_engine.dart';

class FakeSessionRepository implements SessionRepository {
  final Map<String, AppUsageSession> sessions = {};

  @override
  Future<void> clearHistory() async => sessions.clear();

  @override
  Future<List<AppUsageSession>> getAllSessions() async => sessions.values.toList();

  @override
  Future<AppUsageSession?> getActiveSession(String packageName) async {
    return sessions.values.firstWhere(
      (s) => s.packageName == packageName && s.status.isRunning,
      orElse: () => throw Exception('Not found'),
    );
  }

  @override
  Future<AppUsageSession?> getLatestSession() async {
    if (sessions.isEmpty) return null;
    return sessions.values.last;
  }

  @override
  Future<void> saveSession(AppUsageSession session) async {
    sessions[session.id] = session;
  }

  @override
  Stream<List<AppUsageSession>> watchAllSessions() {
    return Stream.value(sessions.values.toList());
  }
}

class FakeNativeBridgeService extends NativeBridgeService {
  String? lastSyncedPackage;
  int? lastSyncedExpiresAt;
  bool homeSent = false;
  bool overlayClosed = false;

  @override
  Future<void> syncActiveSession({
    required String packageName,
    required int expiresAtMs,
  }) async {
    lastSyncedPackage = packageName;
    lastSyncedExpiresAt = expiresAtMs;
  }

  @override
  Future<void> removeActiveSession(String packageName) async {
    lastSyncedPackage = null;
    lastSyncedExpiresAt = null;
  }

  @override
  Future<bool> sendToHomeScreen() async {
    homeSent = true;
    return true;
  }

  @override
  Future<bool> closeOverlay() async {
    overlayClosed = true;
    return true;
  }
}

void main() {
  group('SessionEngine Unit Tests', () {
    late FakeSessionRepository repo;
    late FakeNativeBridgeService bridge;
    late SessionEngine engine;

    setUp(() {
      repo = FakeSessionRepository();
      bridge = FakeNativeBridgeService();
      engine = SessionEngine(
        sessionRepository: repo,
        nativeBridge: bridge,
      );
    });

    tearDown(() {
      engine.dispose();
    });

    test('startSession creates active session with absolute expiresAt timestamp', () async {
      final session = await engine.startSession(
        packageName: 'com.instagram.android',
        appName: 'Instagram',
        durationMinutes: 5,
      );

      expect(session.packageName, 'com.instagram.android');
      expect(session.appName, 'Instagram');
      expect(session.status, SessionStatus.active);
      expect(session.totalDurationMinutes, 5);
      expect(session.extensionCount, 0);
      expect(session.expiresAt.isAfter(session.startedAt), isTrue);

      expect(bridge.lastSyncedPackage, 'com.instagram.android');
      expect(bridge.lastSyncedExpiresAt, isNotNull);
      expect(bridge.overlayClosed, isTrue);
    });

    test('extendSession increases expiry by 1 minute and increments extensionCount', () async {
      await engine.startSession(
        packageName: 'com.tiktok.android',
        appName: 'TikTok',
        durationMinutes: 1,
      );

      final initialExpiry = engine.activeSession!.expiresAt;

      await engine.extendSession('com.tiktok.android', additionalMinutes: 1);

      final extendedSession = engine.activeSession!;
      expect(extendedSession.status, SessionStatus.extended);
      expect(extendedSession.extensionCount, 1);
      expect(extendedSession.totalDurationMinutes, 2);
      expect(
        extendedSession.expiresAt.difference(initialExpiry).inSeconds,
        greaterThanOrEqualTo(59),
      );
    });

    test('endSession ends session and safely calls sendToHomeScreen', () async {
      await engine.startSession(
        packageName: 'com.facebook.katana',
        appName: 'Facebook',
        durationMinutes: 5,
      );

      await engine.endSession('com.facebook.katana', sendHome: true);

      expect(engine.activeSession, isNull);
      expect(bridge.homeSent, isTrue);
      expect(bridge.lastSyncedPackage, isNull);
    });

    test('remainingTime calculation handles zero correctly', () {
      final expiredSession = AppUsageSession(
        id: 'test-1',
        packageName: 'com.twitter.android',
        appName: 'X',
        startedAt: DateTime.now().subtract(const Duration(minutes: 10)),
        expiresAt: DateTime.now().subtract(const Duration(minutes: 5)),
        status: SessionStatus.expired,
        totalDurationMinutes: 5,
      );

      expect(expiredSession.isExpired, isTrue);
      expect(expiredSession.remainingTime, Duration.zero);
      expect(expiredSession.progressFraction, 1.0);
    });
  });
}
