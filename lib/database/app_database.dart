import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('MonitoredAppData')
class MonitoredAppsTable extends Table {
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  BlobColumn get iconBytes => blob().nullable()();
  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();
  DateTimeColumn get addedAt => dateTime()();
  IntColumn get defaultDurationMinutes => integer().withDefault(const Constant(5))();

  @override
  Set<Column> get primaryKey => {packageName};
}

@DataClassName('AppUsageSessionData')
class AppUsageSessionsTable extends Table {
  TextColumn get id => text()();
  TextColumn get packageName => text()();
  TextColumn get appName => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
  TextColumn get status => text()(); // active, expired, extended, ended, cancelled
  IntColumn get extensionCount => integer().withDefault(const Constant(0))();
  IntColumn get totalDurationMinutes => integer().withDefault(const Constant(5))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('MonitoringSettingData')
class MonitoringSettingsTable extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [MonitoredAppsTable, AppUsageSessionsTable, MonitoringSettingsTable])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(monitoredAppsTable, monitoredAppsTable.iconBytes);
          }
        },
      );

  // Monitored Apps queries
  Future<List<MonitoredAppData>> getAllMonitoredApps() =>
      select(monitoredAppsTable).get();

  Stream<List<MonitoredAppData>> watchAllMonitoredApps() =>
      select(monitoredAppsTable).watch();

  Future<MonitoredAppData?> getMonitoredApp(String packageName) =>
      (select(monitoredAppsTable)..where((t) => t.packageName.equals(packageName)))
          .getSingleOrNull();

  Future<void> insertOrUpdateMonitoredApp(MonitoredAppsTableCompanion entry) =>
      into(monitoredAppsTable).insertOnConflictUpdate(entry);

  Future<int> deleteMonitoredApp(String packageName) =>
      (delete(monitoredAppsTable)..where((t) => t.packageName.equals(packageName)))
          .go();

  Future<void> setAppEnabled(String packageName, bool isEnabled) =>
      (update(monitoredAppsTable)..where((t) => t.packageName.equals(packageName)))
          .write(MonitoredAppsTableCompanion(isEnabled: Value(isEnabled)));

  Future<void> updateAppIcon(String packageName, Uint8List iconBytes) =>
      (update(monitoredAppsTable)..where((t) => t.packageName.equals(packageName)))
          .write(MonitoredAppsTableCompanion(iconBytes: Value(iconBytes)));

  // Sessions queries
  Future<List<AppUsageSessionData>> getAllSessions() =>
      (select(appUsageSessionsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .get();

  Stream<List<AppUsageSessionData>> watchAllSessions() =>
      (select(appUsageSessionsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]))
          .watch();

  Future<AppUsageSessionData?> getActiveSession(String packageName) =>
      (select(appUsageSessionsTable)
            ..where((t) =>
                t.packageName.equals(packageName) &
                (t.status.equals('active') | t.status.equals('extended'))))
          .getSingleOrNull();

  Future<AppUsageSessionData?> getLatestSession() =>
      (select(appUsageSessionsTable)
            ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
            ..limit(1))
          .getSingleOrNull();

  Future<void> insertOrUpdateSession(AppUsageSessionsTableCompanion session) =>
      into(appUsageSessionsTable).insertOnConflictUpdate(session);

  Future<int> clearOldSessions() => delete(appUsageSessionsTable).go();

  // Settings queries
  Future<String?> getSetting(String key) async {
    final row = await (select(monitoringSettingsTable)
          ..where((t) => t.key.equals(key)))
        .getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) =>
      into(monitoringSettingsTable).insertOnConflictUpdate(
        MonitoringSettingsTableCompanion(
          key: Value(key),
          value: Value(value),
        ),
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'mas7ool.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
