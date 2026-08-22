import 'package:mas7ool/features/monitored_apps/domain/entities/monitored_app.dart';

abstract class OverlayController {
  Future<void> showStartSessionOverlay({
    required MonitoredApp app,
  });

  Future<void> showSessionExpiredOverlay({
    required MonitoredApp app,
  });

  Future<void> close();
}
