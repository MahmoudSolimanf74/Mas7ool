import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mas7ool/core/permissions/app_permissions.dart';
import 'package:mas7ool/core/providers/app_providers.dart';
import 'package:mas7ool/core/utils/app_logger.dart';
import 'package:mas7ool/features/monitoring/domain/services/monitoring_state_machine.dart';
import 'package:mas7ool/shared/widgets/mas7ool_card.dart';
import 'package:mas7ool/shared/widgets/rtl_scaffold.dart';

class DiagnosticsScreen extends ConsumerStatefulWidget {
  const DiagnosticsScreen({super.key});

  @override
  ConsumerState<DiagnosticsScreen> createState() => _DiagnosticsScreenState();
}

class _DiagnosticsScreenState extends ConsumerState<DiagnosticsScreen> {
  String? _currentForegroundPackage;
  bool _isServiceRunning = false;

  @override
  void initState() {
    super.initState();
    _refreshDiagnostics();
  }

  Future<void> _refreshDiagnostics() async {
    final bridge = ref.read(nativeBridgeProvider);
    final pkg = await bridge.getCurrentForegroundPackage();
    final running = await bridge.isMonitoringServiceRunning();
    await ref.read(permissionManagerProvider).checkAll();

    if (mounted) {
      setState(() {
        _currentForegroundPackage = pkg;
        _isServiceRunning = running;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitoringState = ref.watch(monitoringStateStreamProvider).valueOrNull ??
        MonitoringState.stopped;
    final activeSession = ref.watch(activeSessionStreamProvider).valueOrNull;
    final permissions = ref.watch(permissionsStateStreamProvider).valueOrNull ?? {};
    final bridge = ref.watch(nativeBridgeProvider);

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('شاشة الفحص والتشخيص'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'تحديث',
            onPressed: _refreshDiagnostics,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Monitoring & Foreground State Card
          Mas7oolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حالة المراقبة والنظام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Divider(color: Color(0xFF334155), height: 20),
                _buildKeyValue(
                  'حالة الـ State Machine:',
                  monitoringState.name,
                  highlight: true,
                ),
                _buildKeyValue(
                  'خدمة Foreground Service:',
                  _isServiceRunning ? 'قيد التشغيل ✓' : 'متوقفة',
                  color: _isServiceRunning ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                ),
                _buildKeyValue(
                  'التطبيق الحالي في الـ Foreground:',
                  _currentForegroundPackage ?? 'غير محدد أو Launcher',
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Active Session Details
          Mas7oolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'الجلسة النشطة (Active Session)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Divider(color: Color(0xFF334155), height: 20),
                if (activeSession == null)
                  const Text(
                    'لا توجد جلسة نشطة مسجلة حالياً.',
                    style: TextStyle(color: Color(0xFF94A3B8)),
                  )
                else ...[
                  _buildKeyValue('اسم التطبيق:', activeSession.appName),
                  _buildKeyValue('الحزمة:', activeSession.packageName),
                  _buildKeyValue('الحالة:', activeSession.status.name),
                  _buildKeyValue(
                    'الوقت المتبقي:',
                    '${activeSession.remainingTime.inSeconds} ثانية',
                  ),
                  _buildKeyValue('مرات التمديد:', '${activeSession.extensionCount}'),
                  _buildKeyValue('تاريخ الانتهاء:', activeSession.expiresAt.toIso8601String()),
                ],
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Permissions Status Card
          Mas7oolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'حالات الصلاحيات (Live Permissions)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const Divider(color: Color(0xFF334155), height: 20),
                ...AppPermissionType.values.map((type) {
                  final state = permissions[type] ?? PermissionState.unknown;
                  return _buildKeyValue(
                    type.name,
                    state.name,
                    color: state.isGranted ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                  );
                }),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Interactive Testing Controls
          Mas7oolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'أدوات اختبار الـ Overlays والنظام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        bridge.showDurationPickerOverlay(
                          packageName: 'com.instagram.android',
                          appName: 'Instagram (تجريبي)',
                        );
                      },
                      child: const Text('اختبار نافذة المدة'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        bridge.showSessionExpiredOverlay(
                          packageName: 'com.instagram.android',
                          appName: 'Instagram (تجريبي)',
                        );
                      },
                      child: const Text('اختبار نافذة الانتهاء'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        side: const BorderSide(color: Color(0xFF38BDF8)),
                      ),
                      onPressed: () => bridge.sendToHomeScreen(),
                      child: const Text('العودة للـ Home'),
                    ),
                    OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF94A3B8),
                        side: const BorderSide(color: Color(0xFF64748B)),
                      ),
                      onPressed: () => bridge.closeOverlay(),
                      child: const Text('إغلاق الـ Overlay'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Logs Section
          Mas7oolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'سجل العمليات اللحظي (Logs)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          AppLogger.clearDiagnostics();
                        });
                      },
                      child: const Text('مسح السجل'),
                    ),
                  ],
                ),
                const Divider(color: Color(0xFF334155), height: 16),
                Container(
                  height: 220,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: AppLogger.diagnosticLogs.isEmpty
                      ? const Center(
                          child: Text(
                            'لا توجد سجلات مسجلة بعد.',
                            style: TextStyle(color: Color(0xFF64748B)),
                          ),
                        )
                      : ListView.builder(
                          itemCount: AppLogger.diagnosticLogs.length,
                          itemBuilder: (context, index) {
                            return Text(
                              AppLogger.diagnosticLogs[index],
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 11,
                                color: Color(0xFF94A3B8),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildKeyValue(
    String key,
    String value, {
    Color? color,
    bool highlight = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            key,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? (highlight ? const Color(0xFF38BDF8) : Colors.white),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
