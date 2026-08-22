import '../entities/app_usage_session.dart';

abstract class SessionRepository {
  Future<List<AppUsageSession>> getAllSessions();
  Stream<List<AppUsageSession>> watchAllSessions();
  Future<AppUsageSession?> getActiveSession(String packageName);
  Future<AppUsageSession?> getLatestSession();
  Future<void> saveSession(AppUsageSession session);
  Future<void> clearHistory();
}
