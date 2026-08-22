// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MonitoredAppsTableTable extends MonitoredAppsTable
    with TableInfo<$MonitoredAppsTableTable, MonitoredAppData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitoredAppsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isEnabledMeta = const VerificationMeta(
    'isEnabled',
  );
  @override
  late final GeneratedColumn<bool> isEnabled = GeneratedColumn<bool>(
    'is_enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultDurationMinutesMeta =
      const VerificationMeta('defaultDurationMinutes');
  @override
  late final GeneratedColumn<int> defaultDurationMinutes = GeneratedColumn<int>(
    'default_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  @override
  List<GeneratedColumn> get $columns => [
    packageName,
    appName,
    isEnabled,
    addedAt,
    defaultDurationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitored_apps_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitoredAppData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('is_enabled')) {
      context.handle(
        _isEnabledMeta,
        isEnabled.isAcceptableOrUnknown(data['is_enabled']!, _isEnabledMeta),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    if (data.containsKey('default_duration_minutes')) {
      context.handle(
        _defaultDurationMinutesMeta,
        defaultDurationMinutes.isAcceptableOrUnknown(
          data['default_duration_minutes']!,
          _defaultDurationMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {packageName};
  @override
  MonitoredAppData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitoredAppData(
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      isEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_enabled'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      defaultDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_duration_minutes'],
      )!,
    );
  }

  @override
  $MonitoredAppsTableTable createAlias(String alias) {
    return $MonitoredAppsTableTable(attachedDatabase, alias);
  }
}

class MonitoredAppData extends DataClass
    implements Insertable<MonitoredAppData> {
  final String packageName;
  final String appName;
  final bool isEnabled;
  final DateTime addedAt;
  final int defaultDurationMinutes;
  const MonitoredAppData({
    required this.packageName,
    required this.appName,
    required this.isEnabled,
    required this.addedAt,
    required this.defaultDurationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    map['is_enabled'] = Variable<bool>(isEnabled);
    map['added_at'] = Variable<DateTime>(addedAt);
    map['default_duration_minutes'] = Variable<int>(defaultDurationMinutes);
    return map;
  }

  MonitoredAppsTableCompanion toCompanion(bool nullToAbsent) {
    return MonitoredAppsTableCompanion(
      packageName: Value(packageName),
      appName: Value(appName),
      isEnabled: Value(isEnabled),
      addedAt: Value(addedAt),
      defaultDurationMinutes: Value(defaultDurationMinutes),
    );
  }

  factory MonitoredAppData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitoredAppData(
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      isEnabled: serializer.fromJson<bool>(json['isEnabled']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      defaultDurationMinutes: serializer.fromJson<int>(
        json['defaultDurationMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'isEnabled': serializer.toJson<bool>(isEnabled),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'defaultDurationMinutes': serializer.toJson<int>(defaultDurationMinutes),
    };
  }

  MonitoredAppData copyWith({
    String? packageName,
    String? appName,
    bool? isEnabled,
    DateTime? addedAt,
    int? defaultDurationMinutes,
  }) => MonitoredAppData(
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    isEnabled: isEnabled ?? this.isEnabled,
    addedAt: addedAt ?? this.addedAt,
    defaultDurationMinutes:
        defaultDurationMinutes ?? this.defaultDurationMinutes,
  );
  MonitoredAppData copyWithCompanion(MonitoredAppsTableCompanion data) {
    return MonitoredAppData(
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      isEnabled: data.isEnabled.present ? data.isEnabled.value : this.isEnabled,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      defaultDurationMinutes: data.defaultDurationMinutes.present
          ? data.defaultDurationMinutes.value
          : this.defaultDurationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitoredAppData(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('addedAt: $addedAt, ')
          ..write('defaultDurationMinutes: $defaultDurationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    packageName,
    appName,
    isEnabled,
    addedAt,
    defaultDurationMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoredAppData &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.isEnabled == this.isEnabled &&
          other.addedAt == this.addedAt &&
          other.defaultDurationMinutes == this.defaultDurationMinutes);
}

class MonitoredAppsTableCompanion extends UpdateCompanion<MonitoredAppData> {
  final Value<String> packageName;
  final Value<String> appName;
  final Value<bool> isEnabled;
  final Value<DateTime> addedAt;
  final Value<int> defaultDurationMinutes;
  final Value<int> rowid;
  const MonitoredAppsTableCompanion({
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.isEnabled = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.defaultDurationMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitoredAppsTableCompanion.insert({
    required String packageName,
    required String appName,
    this.isEnabled = const Value.absent(),
    required DateTime addedAt,
    this.defaultDurationMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : packageName = Value(packageName),
       appName = Value(appName),
       addedAt = Value(addedAt);
  static Insertable<MonitoredAppData> custom({
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<bool>? isEnabled,
    Expression<DateTime>? addedAt,
    Expression<int>? defaultDurationMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (isEnabled != null) 'is_enabled': isEnabled,
      if (addedAt != null) 'added_at': addedAt,
      if (defaultDurationMinutes != null)
        'default_duration_minutes': defaultDurationMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitoredAppsTableCompanion copyWith({
    Value<String>? packageName,
    Value<String>? appName,
    Value<bool>? isEnabled,
    Value<DateTime>? addedAt,
    Value<int>? defaultDurationMinutes,
    Value<int>? rowid,
  }) {
    return MonitoredAppsTableCompanion(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      isEnabled: isEnabled ?? this.isEnabled,
      addedAt: addedAt ?? this.addedAt,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (isEnabled.present) {
      map['is_enabled'] = Variable<bool>(isEnabled.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (defaultDurationMinutes.present) {
      map['default_duration_minutes'] = Variable<int>(
        defaultDurationMinutes.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitoredAppsTableCompanion(')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('isEnabled: $isEnabled, ')
          ..write('addedAt: $addedAt, ')
          ..write('defaultDurationMinutes: $defaultDurationMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppUsageSessionsTableTable extends AppUsageSessionsTable
    with TableInfo<$AppUsageSessionsTableTable, AppUsageSessionData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppUsageSessionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  @override
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appNameMeta = const VerificationMeta(
    'appName',
  );
  @override
  late final GeneratedColumn<String> appName = GeneratedColumn<String>(
    'app_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _extensionCountMeta = const VerificationMeta(
    'extensionCount',
  );
  @override
  late final GeneratedColumn<int> extensionCount = GeneratedColumn<int>(
    'extension_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalDurationMinutesMeta =
      const VerificationMeta('totalDurationMinutes');
  @override
  late final GeneratedColumn<int> totalDurationMinutes = GeneratedColumn<int>(
    'total_duration_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(5),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    appName,
    startedAt,
    expiresAt,
    status,
    extensionCount,
    totalDurationMinutes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_usage_sessions_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppUsageSessionData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('app_name')) {
      context.handle(
        _appNameMeta,
        appName.isAcceptableOrUnknown(data['app_name']!, _appNameMeta),
      );
    } else if (isInserting) {
      context.missing(_appNameMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('extension_count')) {
      context.handle(
        _extensionCountMeta,
        extensionCount.isAcceptableOrUnknown(
          data['extension_count']!,
          _extensionCountMeta,
        ),
      );
    }
    if (data.containsKey('total_duration_minutes')) {
      context.handle(
        _totalDurationMinutesMeta,
        totalDurationMinutes.isAcceptableOrUnknown(
          data['total_duration_minutes']!,
          _totalDurationMinutesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AppUsageSessionData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppUsageSessionData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      appName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}app_name'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      extensionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extension_count'],
      )!,
      totalDurationMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_duration_minutes'],
      )!,
    );
  }

  @override
  $AppUsageSessionsTableTable createAlias(String alias) {
    return $AppUsageSessionsTableTable(attachedDatabase, alias);
  }
}

class AppUsageSessionData extends DataClass
    implements Insertable<AppUsageSessionData> {
  final String id;
  final String packageName;
  final String appName;
  final DateTime startedAt;
  final DateTime expiresAt;
  final String status;
  final int extensionCount;
  final int totalDurationMinutes;
  const AppUsageSessionData({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.startedAt,
    required this.expiresAt,
    required this.status,
    required this.extensionCount,
    required this.totalDurationMinutes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['package_name'] = Variable<String>(packageName);
    map['app_name'] = Variable<String>(appName);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['expires_at'] = Variable<DateTime>(expiresAt);
    map['status'] = Variable<String>(status);
    map['extension_count'] = Variable<int>(extensionCount);
    map['total_duration_minutes'] = Variable<int>(totalDurationMinutes);
    return map;
  }

  AppUsageSessionsTableCompanion toCompanion(bool nullToAbsent) {
    return AppUsageSessionsTableCompanion(
      id: Value(id),
      packageName: Value(packageName),
      appName: Value(appName),
      startedAt: Value(startedAt),
      expiresAt: Value(expiresAt),
      status: Value(status),
      extensionCount: Value(extensionCount),
      totalDurationMinutes: Value(totalDurationMinutes),
    );
  }

  factory AppUsageSessionData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppUsageSessionData(
      id: serializer.fromJson<String>(json['id']),
      packageName: serializer.fromJson<String>(json['packageName']),
      appName: serializer.fromJson<String>(json['appName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
      status: serializer.fromJson<String>(json['status']),
      extensionCount: serializer.fromJson<int>(json['extensionCount']),
      totalDurationMinutes: serializer.fromJson<int>(
        json['totalDurationMinutes'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'packageName': serializer.toJson<String>(packageName),
      'appName': serializer.toJson<String>(appName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
      'status': serializer.toJson<String>(status),
      'extensionCount': serializer.toJson<int>(extensionCount),
      'totalDurationMinutes': serializer.toJson<int>(totalDurationMinutes),
    };
  }

  AppUsageSessionData copyWith({
    String? id,
    String? packageName,
    String? appName,
    DateTime? startedAt,
    DateTime? expiresAt,
    String? status,
    int? extensionCount,
    int? totalDurationMinutes,
  }) => AppUsageSessionData(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    appName: appName ?? this.appName,
    startedAt: startedAt ?? this.startedAt,
    expiresAt: expiresAt ?? this.expiresAt,
    status: status ?? this.status,
    extensionCount: extensionCount ?? this.extensionCount,
    totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
  );
  AppUsageSessionData copyWithCompanion(AppUsageSessionsTableCompanion data) {
    return AppUsageSessionData(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      appName: data.appName.present ? data.appName.value : this.appName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
      status: data.status.present ? data.status.value : this.status,
      extensionCount: data.extensionCount.present
          ? data.extensionCount.value
          : this.extensionCount,
      totalDurationMinutes: data.totalDurationMinutes.present
          ? data.totalDurationMinutes.value
          : this.totalDurationMinutes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageSessionData(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('startedAt: $startedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('extensionCount: $extensionCount, ')
          ..write('totalDurationMinutes: $totalDurationMinutes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    appName,
    startedAt,
    expiresAt,
    status,
    extensionCount,
    totalDurationMinutes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppUsageSessionData &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.appName == this.appName &&
          other.startedAt == this.startedAt &&
          other.expiresAt == this.expiresAt &&
          other.status == this.status &&
          other.extensionCount == this.extensionCount &&
          other.totalDurationMinutes == this.totalDurationMinutes);
}

class AppUsageSessionsTableCompanion
    extends UpdateCompanion<AppUsageSessionData> {
  final Value<String> id;
  final Value<String> packageName;
  final Value<String> appName;
  final Value<DateTime> startedAt;
  final Value<DateTime> expiresAt;
  final Value<String> status;
  final Value<int> extensionCount;
  final Value<int> totalDurationMinutes;
  final Value<int> rowid;
  const AppUsageSessionsTableCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.appName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.status = const Value.absent(),
    this.extensionCount = const Value.absent(),
    this.totalDurationMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppUsageSessionsTableCompanion.insert({
    required String id,
    required String packageName,
    required String appName,
    required DateTime startedAt,
    required DateTime expiresAt,
    required String status,
    this.extensionCount = const Value.absent(),
    this.totalDurationMinutes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       packageName = Value(packageName),
       appName = Value(appName),
       startedAt = Value(startedAt),
       expiresAt = Value(expiresAt),
       status = Value(status);
  static Insertable<AppUsageSessionData> custom({
    Expression<String>? id,
    Expression<String>? packageName,
    Expression<String>? appName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? expiresAt,
    Expression<String>? status,
    Expression<int>? extensionCount,
    Expression<int>? totalDurationMinutes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (appName != null) 'app_name': appName,
      if (startedAt != null) 'started_at': startedAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (status != null) 'status': status,
      if (extensionCount != null) 'extension_count': extensionCount,
      if (totalDurationMinutes != null)
        'total_duration_minutes': totalDurationMinutes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppUsageSessionsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? packageName,
    Value<String>? appName,
    Value<DateTime>? startedAt,
    Value<DateTime>? expiresAt,
    Value<String>? status,
    Value<int>? extensionCount,
    Value<int>? totalDurationMinutes,
    Value<int>? rowid,
  }) {
    return AppUsageSessionsTableCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      extensionCount: extensionCount ?? this.extensionCount,
      totalDurationMinutes: totalDurationMinutes ?? this.totalDurationMinutes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (appName.present) {
      map['app_name'] = Variable<String>(appName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (extensionCount.present) {
      map['extension_count'] = Variable<int>(extensionCount.value);
    }
    if (totalDurationMinutes.present) {
      map['total_duration_minutes'] = Variable<int>(totalDurationMinutes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppUsageSessionsTableCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('appName: $appName, ')
          ..write('startedAt: $startedAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('status: $status, ')
          ..write('extensionCount: $extensionCount, ')
          ..write('totalDurationMinutes: $totalDurationMinutes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MonitoringSettingsTableTable extends MonitoringSettingsTable
    with TableInfo<$MonitoringSettingsTableTable, MonitoringSettingData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MonitoringSettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitoring_settings_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitoringSettingData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  MonitoringSettingData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitoringSettingData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $MonitoringSettingsTableTable createAlias(String alias) {
    return $MonitoringSettingsTableTable(attachedDatabase, alias);
  }
}

class MonitoringSettingData extends DataClass
    implements Insertable<MonitoringSettingData> {
  final String key;
  final String value;
  const MonitoringSettingData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  MonitoringSettingsTableCompanion toCompanion(bool nullToAbsent) {
    return MonitoringSettingsTableCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory MonitoringSettingData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitoringSettingData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  MonitoringSettingData copyWith({String? key, String? value}) =>
      MonitoringSettingData(key: key ?? this.key, value: value ?? this.value);
  MonitoringSettingData copyWithCompanion(
    MonitoringSettingsTableCompanion data,
  ) {
    return MonitoringSettingData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitoringSettingData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoringSettingData &&
          other.key == this.key &&
          other.value == this.value);
}

class MonitoringSettingsTableCompanion
    extends UpdateCompanion<MonitoringSettingData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const MonitoringSettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MonitoringSettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<MonitoringSettingData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MonitoringSettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return MonitoringSettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitoringSettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MonitoredAppsTableTable monitoredAppsTable =
      $MonitoredAppsTableTable(this);
  late final $AppUsageSessionsTableTable appUsageSessionsTable =
      $AppUsageSessionsTableTable(this);
  late final $MonitoringSettingsTableTable monitoringSettingsTable =
      $MonitoringSettingsTableTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    monitoredAppsTable,
    appUsageSessionsTable,
    monitoringSettingsTable,
  ];
}

typedef $$MonitoredAppsTableTableCreateCompanionBuilder =
    MonitoredAppsTableCompanion Function({
      required String packageName,
      required String appName,
      Value<bool> isEnabled,
      required DateTime addedAt,
      Value<int> defaultDurationMinutes,
      Value<int> rowid,
    });
typedef $$MonitoredAppsTableTableUpdateCompanionBuilder =
    MonitoredAppsTableCompanion Function({
      Value<String> packageName,
      Value<String> appName,
      Value<bool> isEnabled,
      Value<DateTime> addedAt,
      Value<int> defaultDurationMinutes,
      Value<int> rowid,
    });

class $$MonitoredAppsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonitoredAppsTableTable> {
  $$MonitoredAppsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultDurationMinutes => $composableBuilder(
    column: $table.defaultDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonitoredAppsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitoredAppsTableTable> {
  $$MonitoredAppsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isEnabled => $composableBuilder(
    column: $table.isEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultDurationMinutes => $composableBuilder(
    column: $table.defaultDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitoredAppsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitoredAppsTableTable> {
  $$MonitoredAppsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<bool> get isEnabled =>
      $composableBuilder(column: $table.isEnabled, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<int> get defaultDurationMinutes => $composableBuilder(
    column: $table.defaultDurationMinutes,
    builder: (column) => column,
  );
}

class $$MonitoredAppsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitoredAppsTableTable,
          MonitoredAppData,
          $$MonitoredAppsTableTableFilterComposer,
          $$MonitoredAppsTableTableOrderingComposer,
          $$MonitoredAppsTableTableAnnotationComposer,
          $$MonitoredAppsTableTableCreateCompanionBuilder,
          $$MonitoredAppsTableTableUpdateCompanionBuilder,
          (
            MonitoredAppData,
            BaseReferences<
              _$AppDatabase,
              $MonitoredAppsTableTable,
              MonitoredAppData
            >,
          ),
          MonitoredAppData,
          PrefetchHooks Function()
        > {
  $$MonitoredAppsTableTableTableManager(
    _$AppDatabase db,
    $MonitoredAppsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitoredAppsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MonitoredAppsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MonitoredAppsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<bool> isEnabled = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<int> defaultDurationMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitoredAppsTableCompanion(
                packageName: packageName,
                appName: appName,
                isEnabled: isEnabled,
                addedAt: addedAt,
                defaultDurationMinutes: defaultDurationMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String packageName,
                required String appName,
                Value<bool> isEnabled = const Value.absent(),
                required DateTime addedAt,
                Value<int> defaultDurationMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitoredAppsTableCompanion.insert(
                packageName: packageName,
                appName: appName,
                isEnabled: isEnabled,
                addedAt: addedAt,
                defaultDurationMinutes: defaultDurationMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonitoredAppsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitoredAppsTableTable,
      MonitoredAppData,
      $$MonitoredAppsTableTableFilterComposer,
      $$MonitoredAppsTableTableOrderingComposer,
      $$MonitoredAppsTableTableAnnotationComposer,
      $$MonitoredAppsTableTableCreateCompanionBuilder,
      $$MonitoredAppsTableTableUpdateCompanionBuilder,
      (
        MonitoredAppData,
        BaseReferences<
          _$AppDatabase,
          $MonitoredAppsTableTable,
          MonitoredAppData
        >,
      ),
      MonitoredAppData,
      PrefetchHooks Function()
    >;
typedef $$AppUsageSessionsTableTableCreateCompanionBuilder =
    AppUsageSessionsTableCompanion Function({
      required String id,
      required String packageName,
      required String appName,
      required DateTime startedAt,
      required DateTime expiresAt,
      required String status,
      Value<int> extensionCount,
      Value<int> totalDurationMinutes,
      Value<int> rowid,
    });
typedef $$AppUsageSessionsTableTableUpdateCompanionBuilder =
    AppUsageSessionsTableCompanion Function({
      Value<String> id,
      Value<String> packageName,
      Value<String> appName,
      Value<DateTime> startedAt,
      Value<DateTime> expiresAt,
      Value<String> status,
      Value<int> extensionCount,
      Value<int> totalDurationMinutes,
      Value<int> rowid,
    });

class $$AppUsageSessionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $AppUsageSessionsTableTable> {
  $$AppUsageSessionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extensionCount => $composableBuilder(
    column: $table.extensionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalDurationMinutes => $composableBuilder(
    column: $table.totalDurationMinutes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppUsageSessionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $AppUsageSessionsTableTable> {
  $$AppUsageSessionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get appName => $composableBuilder(
    column: $table.appName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extensionCount => $composableBuilder(
    column: $table.extensionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalDurationMinutes => $composableBuilder(
    column: $table.totalDurationMinutes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppUsageSessionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppUsageSessionsTableTable> {
  $$AppUsageSessionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get appName =>
      $composableBuilder(column: $table.appName, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get extensionCount => $composableBuilder(
    column: $table.extensionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalDurationMinutes => $composableBuilder(
    column: $table.totalDurationMinutes,
    builder: (column) => column,
  );
}

class $$AppUsageSessionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppUsageSessionsTableTable,
          AppUsageSessionData,
          $$AppUsageSessionsTableTableFilterComposer,
          $$AppUsageSessionsTableTableOrderingComposer,
          $$AppUsageSessionsTableTableAnnotationComposer,
          $$AppUsageSessionsTableTableCreateCompanionBuilder,
          $$AppUsageSessionsTableTableUpdateCompanionBuilder,
          (
            AppUsageSessionData,
            BaseReferences<
              _$AppDatabase,
              $AppUsageSessionsTableTable,
              AppUsageSessionData
            >,
          ),
          AppUsageSessionData,
          PrefetchHooks Function()
        > {
  $$AppUsageSessionsTableTableTableManager(
    _$AppDatabase db,
    $AppUsageSessionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppUsageSessionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$AppUsageSessionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$AppUsageSessionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String> appName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> extensionCount = const Value.absent(),
                Value<int> totalDurationMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsageSessionsTableCompanion(
                id: id,
                packageName: packageName,
                appName: appName,
                startedAt: startedAt,
                expiresAt: expiresAt,
                status: status,
                extensionCount: extensionCount,
                totalDurationMinutes: totalDurationMinutes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String packageName,
                required String appName,
                required DateTime startedAt,
                required DateTime expiresAt,
                required String status,
                Value<int> extensionCount = const Value.absent(),
                Value<int> totalDurationMinutes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppUsageSessionsTableCompanion.insert(
                id: id,
                packageName: packageName,
                appName: appName,
                startedAt: startedAt,
                expiresAt: expiresAt,
                status: status,
                extensionCount: extensionCount,
                totalDurationMinutes: totalDurationMinutes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppUsageSessionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppUsageSessionsTableTable,
      AppUsageSessionData,
      $$AppUsageSessionsTableTableFilterComposer,
      $$AppUsageSessionsTableTableOrderingComposer,
      $$AppUsageSessionsTableTableAnnotationComposer,
      $$AppUsageSessionsTableTableCreateCompanionBuilder,
      $$AppUsageSessionsTableTableUpdateCompanionBuilder,
      (
        AppUsageSessionData,
        BaseReferences<
          _$AppDatabase,
          $AppUsageSessionsTableTable,
          AppUsageSessionData
        >,
      ),
      AppUsageSessionData,
      PrefetchHooks Function()
    >;
typedef $$MonitoringSettingsTableTableCreateCompanionBuilder =
    MonitoringSettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$MonitoringSettingsTableTableUpdateCompanionBuilder =
    MonitoringSettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$MonitoringSettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $MonitoringSettingsTableTable> {
  $$MonitoringSettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MonitoringSettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $MonitoringSettingsTableTable> {
  $$MonitoringSettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MonitoringSettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $MonitoringSettingsTableTable> {
  $$MonitoringSettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$MonitoringSettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MonitoringSettingsTableTable,
          MonitoringSettingData,
          $$MonitoringSettingsTableTableFilterComposer,
          $$MonitoringSettingsTableTableOrderingComposer,
          $$MonitoringSettingsTableTableAnnotationComposer,
          $$MonitoringSettingsTableTableCreateCompanionBuilder,
          $$MonitoringSettingsTableTableUpdateCompanionBuilder,
          (
            MonitoringSettingData,
            BaseReferences<
              _$AppDatabase,
              $MonitoringSettingsTableTable,
              MonitoringSettingData
            >,
          ),
          MonitoringSettingData,
          PrefetchHooks Function()
        > {
  $$MonitoringSettingsTableTableTableManager(
    _$AppDatabase db,
    $MonitoringSettingsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MonitoringSettingsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MonitoringSettingsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MonitoringSettingsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MonitoringSettingsTableCompanion(
                key: key,
                value: value,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => MonitoringSettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MonitoringSettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MonitoringSettingsTableTable,
      MonitoringSettingData,
      $$MonitoringSettingsTableTableFilterComposer,
      $$MonitoringSettingsTableTableOrderingComposer,
      $$MonitoringSettingsTableTableAnnotationComposer,
      $$MonitoringSettingsTableTableCreateCompanionBuilder,
      $$MonitoringSettingsTableTableUpdateCompanionBuilder,
      (
        MonitoringSettingData,
        BaseReferences<
          _$AppDatabase,
          $MonitoringSettingsTableTable,
          MonitoringSettingData
        >,
      ),
      MonitoringSettingData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MonitoredAppsTableTableTableManager get monitoredAppsTable =>
      $$MonitoredAppsTableTableTableManager(_db, _db.monitoredAppsTable);
  $$AppUsageSessionsTableTableTableManager get appUsageSessionsTable =>
      $$AppUsageSessionsTableTableTableManager(_db, _db.appUsageSessionsTable);
  $$MonitoringSettingsTableTableTableManager get monitoringSettingsTable =>
      $$MonitoringSettingsTableTableTableManager(
        _db,
        _db.monitoringSettingsTable,
      );
}
