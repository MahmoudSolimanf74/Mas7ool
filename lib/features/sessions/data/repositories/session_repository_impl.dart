import 'package:drift/drift.dart';
import '../../../../database/app_database.dart';
import '../../domain/entities/app_usage_session.dart';
import '../../domain/repositories/session_repository.dart';

class SessionRepositoryImpl implements SessionRepository {
  final AppDatabase _db;

  SessionRepositoryImpl(this._db);

  @override
  Future<List<AppUsageSession>> getAllSessions() async {
    final rows = await _db.getAllSessions();
    return rows.map((r) => _mapRowToEntity(r)).toList();
  }

  @override
  Stream<List<AppUsageSession>> watchAllSessions() {
    return _db.watchAllSessions().map((rows) {
      return rows.map((r) => _mapRowToEntity(r)).toList();
    });
  }

  @override
  Future<AppUsageSession?> getActiveSession(String packageName) async {
    final row = await _db.getActiveSession(packageName);
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<AppUsageSession?> getLatestSession() async {
    final row = await _db.getLatestSession();
    return row != null ? _mapRowToEntity(row) : null;
  }

  @override
  Future<void> saveSession(AppUsageSession session) async {
    await _db.insertOrUpdateSession(
      AppUsageSessionsTableCompanion(
        id: Value(session.id),
        packageName: Value(session.packageName),
        appName: Value(session.appName),
        startedAt: Value(session.startedAt),
        expiresAt: Value(session.expiresAt),
        status: Value(session.status.name),
        extensionCount: Value(session.extensionCount),
        totalDurationMinutes: Value(session.totalDurationMinutes),
      ),
    );
  }

  @override
  Future<void> clearHistory() async {
    await _db.clearOldSessions();
  }

  AppUsageSession _mapRowToEntity(AppUsageSessionData row) {
    return AppUsageSession(
      id: row.id,
      packageName: row.packageName,
      appName: row.appName,
      startedAt: row.startedAt,
      expiresAt: row.expiresAt,
      status: _parseStatus(row.status),
      extensionCount: row.extensionCount,
      totalDurationMinutes: row.totalDurationMinutes,
    );
  }

  SessionStatus _parseStatus(String statusStr) {
    return SessionStatus.values.firstWhere(
      (s) => s.name == statusStr,
      orElse: () => SessionStatus.ended,
    );
  }
}
