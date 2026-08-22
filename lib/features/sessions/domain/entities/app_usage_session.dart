enum SessionStatus {
  idle,
  waitingForDuration,
  active,
  expired,
  extended,
  ended,
  cancelled;

  bool get isRunning =>
      this == SessionStatus.active || this == SessionStatus.extended;
}

class AppUsageSession {
  final String id;
  final String packageName;
  final String appName;
  final DateTime startedAt;
  final DateTime expiresAt;
  final SessionStatus status;
  final int extensionCount;
  final int totalDurationMinutes;

  const AppUsageSession({
    required this.id,
    required this.packageName,
    required this.appName,
    required this.startedAt,
    required this.expiresAt,
    required this.status,
    this.extensionCount = 0,
    required this.totalDurationMinutes,
  });

  Duration get remainingTime {
    final diff = expiresAt.difference(DateTime.now());
    return diff.isNegative ? Duration.zero : diff;
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  double get progressFraction {
    final totalDuration = expiresAt.difference(startedAt).inMilliseconds;
    if (totalDuration <= 0) return 1.0;
    final elapsed = DateTime.now().difference(startedAt).inMilliseconds;
    return (elapsed / totalDuration).clamp(0.0, 1.0);
  }

  AppUsageSession copyWith({
    String? id,
    String? packageName,
    String? appName,
    DateTime? startedAt,
    DateTime? expiresAt,
    SessionStatus? status,
    int? extensionCount,
    int? totalDurationMinutes,
  }) {
    return AppUsageSession(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      startedAt: startedAt ?? this.startedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      extensionCount: extensionCount ?? this.extensionCount,
      totalDurationMinutes:
          totalDurationMinutes ?? this.totalDurationMinutes,
    );
  }

  @override
  String toString() {
    return 'AppUsageSession(id: $id, pkg: $packageName, status: ${status.name}, expires: $expiresAt, remaining: ${remainingTime.inSeconds}s)';
  }
}
