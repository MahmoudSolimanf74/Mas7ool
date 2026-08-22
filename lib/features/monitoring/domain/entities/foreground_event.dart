class ForegroundAppEvent {
  final String packageName;
  final String appName;
  final DateTime timestamp;
  final String eventType;

  const ForegroundAppEvent({
    required this.packageName,
    required this.appName,
    required this.timestamp,
    required this.eventType,
  });

  factory ForegroundAppEvent.fromMap(Map<dynamic, dynamic> map) {
    return ForegroundAppEvent(
      packageName: map['packageName'] as String? ?? '',
      appName: map['appName'] as String? ?? '',
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      eventType: map['eventType'] as String? ?? 'UNKNOWN',
    );
  }

  @override
  String toString() =>
      'ForegroundAppEvent(pkg: $packageName, app: $appName, type: $eventType)';
}
