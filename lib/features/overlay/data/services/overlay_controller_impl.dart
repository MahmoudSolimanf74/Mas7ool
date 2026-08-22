import 'package:mas7ool/core/services/native_bridge_service.dart';
import 'package:mas7ool/core/utils/app_logger.dart';
import 'package:mas7ool/features/monitored_apps/domain/entities/monitored_app.dart';
import 'package:mas7ool/features/overlay/domain/services/overlay_controller.dart';

class OverlayControllerImpl implements OverlayController {
  final NativeBridgeService _nativeBridge;
  bool _isOverlayOpen = false;

  OverlayControllerImpl(this._nativeBridge);

  @override
  Future<void> showStartSessionOverlay({
    required MonitoredApp app,
  }) async {
    if (_isOverlayOpen) {
      AppLogger.w('OVERLAY', 'Overlay already showing. Closing previous.');
      await close();
    }
    _isOverlayOpen = true;
    AppLogger.i('OVERLAY', 'Triggering duration picker overlay for: ${app.packageName}');
    await _nativeBridge.showDurationPickerOverlay(
      packageName: app.packageName,
      appName: app.appName,
    );
  }

  @override
  Future<void> showSessionExpiredOverlay({
    required MonitoredApp app,
  }) async {
    if (_isOverlayOpen) {
      await close();
    }
    _isOverlayOpen = true;
    AppLogger.i('OVERLAY', 'Triggering session expired overlay for: ${app.packageName}');
    await _nativeBridge.showSessionExpiredOverlay(
      packageName: app.packageName,
      appName: app.appName,
    );
  }

  @override
  Future<void> close() async {
    _isOverlayOpen = false;
    await _nativeBridge.closeOverlay();
  }
}
