import 'dart:async';
import 'package:mas7ool/core/services/native_bridge_service.dart';
import 'package:mas7ool/core/utils/app_logger.dart';
import 'package:mas7ool/features/monitoring/domain/entities/foreground_event.dart';
import 'package:mas7ool/features/monitoring/domain/services/foreground_app_monitor.dart';

class ForegroundAppMonitorImpl implements ForegroundAppMonitor {
  final NativeBridgeService _nativeBridge;
  final StreamController<ForegroundAppEvent> _eventsController =
      StreamController<ForegroundAppEvent>.broadcast();
  StreamSubscription? _nativeSubscription;

  ForegroundAppMonitorImpl(this._nativeBridge) {
    _initNativeStream();
  }

  void _initNativeStream() {
    _nativeSubscription = _nativeBridge.monitoringEventsStream.listen(
      (data) {
        if (data is Map) {
          // Check if this is an app foreground event or an overlay action
          if (data.containsKey('eventType') && data.containsKey('packageName')) {
            final event = ForegroundAppEvent.fromMap(data);
            AppLogger.d('MONITOR', 'Detected foreground event: ${event.packageName}');
            _eventsController.add(event);
          }
        }
      },
      onError: (err, st) {
        AppLogger.e('MONITOR', 'Error in native event stream', err, st);
      },
    );
  }

  @override
  Stream<ForegroundAppEvent> watch() => _eventsController.stream;

  @override
  Future<String?> getCurrentForegroundPackage() =>
      _nativeBridge.getCurrentForegroundPackage();

  void dispose() {
    _nativeSubscription?.cancel();
    _eventsController.close();
  }
}
