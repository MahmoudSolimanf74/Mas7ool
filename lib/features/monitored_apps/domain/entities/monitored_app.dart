import 'dart:typed_data';

class MonitoredApp {
  final String packageName;
  final String appName;
  final Uint8List? icon;
  final bool isEnabled;
  final DateTime addedAt;
  final int defaultDurationMinutes;

  const MonitoredApp({
    required this.packageName,
    required this.appName,
    this.icon,
    this.isEnabled = true,
    required this.addedAt,
    this.defaultDurationMinutes = 5,
  });

  MonitoredApp copyWith({
    String? packageName,
    String? appName,
    Uint8List? icon,
    bool? isEnabled,
    DateTime? addedAt,
    int? defaultDurationMinutes,
  }) {
    return MonitoredApp(
      packageName: packageName ?? this.packageName,
      appName: appName ?? this.appName,
      icon: icon ?? this.icon,
      isEnabled: isEnabled ?? this.isEnabled,
      addedAt: addedAt ?? this.addedAt,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonitoredApp &&
          runtimeType == other.runtimeType &&
          packageName == other.packageName;

  @override
  int get hashCode => packageName.hashCode;
}
