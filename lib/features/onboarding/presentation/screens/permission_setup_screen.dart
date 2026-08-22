import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/mas7ool_card.dart';

class PermissionSetupScreen extends ConsumerStatefulWidget {
  const PermissionSetupScreen({super.key});

  @override
  ConsumerState<PermissionSetupScreen> createState() =>
      _PermissionSetupScreenState();
}

class _PermissionSetupScreenState extends ConsumerState<PermissionSetupScreen>
    with WidgetsBindingObserver {
  Map<AppPermissionType, PermissionState> _permissions = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAllPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAllPermissions();
    }
  }

  Future<void> _checkAllPermissions() async {
    final manager = ref.read(permissionManagerProvider);
    final results = await manager.checkAll();
    if (mounted) {
      setState(() {
        _permissions = results;
        _isLoading = false;
      });
    }
  }

  Future<void> _requestPermission(AppPermissionType type) async {
    final manager = ref.read(permissionManagerProvider);
    await manager.request(type);
    await _checkAllPermissions();
  }

  @override
  Widget build(BuildContext context) {
    final isUsageGranted =
        _permissions[AppPermissionType.usageAccess]?.isGranted ?? false;
    final isOverlayGranted =
        _permissions[AppPermissionType.overlay]?.isGranted ?? false;
    final isNotificationGranted =
        _permissions[AppPermissionType.notifications]?.isGranted ?? false;
    final isBatteryGranted =
        _permissions[AppPermissionType.batteryOptimization]?.isGranted ?? false;

    final canProceed = isUsageGranted && isOverlayGranted;

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('إعداد الصلاحيات المطلوبة'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      children: [
                        const Text(
                          'يحتاج تطبيق مسؤول إلى بعض الصلاحيات الأساسية ليعمل بشكل صحيح وموثوق على نظام Android.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF94A3B8),
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Step 1: Usage Access (Mandatory)
                        _buildPermissionCard(
                          title: '1. الوصول لبيانات الاستخدام',
                          subtitle:
                              'نحتاج الوصول لإحصاءات استخدام التطبيقات لمعرفة متى يتم فتح التطبيقات التي اخترتها للمراقبة.',
                          icon: Icons.data_usage_rounded,
                          isGranted: isUsageGranted,
                          isMandatory: true,
                          onTap: () =>
                              _requestPermission(AppPermissionType.usageAccess),
                        ),

                        const SizedBox(height: 14),

                        // Step 2: Overlay (Mandatory)
                        _buildPermissionCard(
                          title: '2. الظهور فوق التطبيقات الأخرى',
                          subtitle:
                              'نحتاج إذن الظهور فوق التطبيقات الأخرى لعرض اختيار مدة الاستخدام وتنبيه انتهاء الوقت.',
                          icon: Icons.layers_rounded,
                          isGranted: isOverlayGranted,
                          isMandatory: true,
                          onTap: () =>
                              _requestPermission(AppPermissionType.overlay),
                        ),

                        const SizedBox(height: 14),

                        // Step 3: Notifications (Recommended)
                        _buildPermissionCard(
                          title: '3. الإشعارات والتنبيهات',
                          subtitle:
                              'لعرض إشعار خدمة المراقبة الدائمة وتنبيهك عند انتهاء وقت الجلسة.',
                          icon: Icons.notifications_active_rounded,
                          isGranted: isNotificationGranted,
                          isMandatory: false,
                          onTap: () => _requestPermission(
                            AppPermissionType.notifications,
                          ),
                        ),

                        const SizedBox(height: 14),

                        // Step 4: Battery Optimization (Optional)
                        _buildPermissionCard(
                          title: '4. استثناء توفير الطاقة',
                          subtitle:
                              'يمنع نظام Android من إيقاف خدمة المراقبة في الخلفية لضمان عملها بدقة.',
                          icon: Icons.battery_charging_full_rounded,
                          isGranted: isBatteryGranted,
                          isMandatory: false,
                          onTap: () => _requestPermission(
                            AppPermissionType.batteryOptimization,
                          ),
                        ),

                        const SizedBox(height: 20),

                        if (!canProceed)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withAlpha(25),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xFFEF4444).withAlpha(76),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline, color: Color(0xFFEF4444), size: 20),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'الصلاحيتان (1 و 2) إلزاميتان لبدء استخدام التطبيق.',
                                    style: TextStyle(
                                      color: Color(0xFFFCA5A5),
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Bottom Action
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      label: canProceed ? 'المتابعة إلى لوحة التحكم' : 'يرجى منح الصلاحيات الإلزامية',
                      icon: canProceed ? Icons.check_circle_outline : Icons.lock_outline,
                      onPressed: canProceed
                          ? () async {
                              // Start monitoring automatically on setup complete
                              final stateMachine = ref.read(monitoringStateMachineProvider);
                              await stateMachine.startMonitoring();
                              if (context.mounted) {
                                if (context.canPop()) {
                                  context.pop();
                                } else {
                                  context.go('/');
                                }
                              }
                            }
                          : null,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPermissionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isGranted,
    required bool isMandatory,
    required VoidCallback onTap,
  }) {
    return Mas7oolCard(
      color: isGranted
          ? const Color(0xFF10B981).withAlpha(20)
          : const Color(0xFF1E293B),
      border: Border.all(
        color: isGranted
            ? const Color(0xFF10B981).withAlpha(128)
            : const Color(0xFF334155),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isGranted
                      ? const Color(0xFF10B981).withAlpha(51)
                      : const Color(0xFF3B82F6).withAlpha(38),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isGranted
                      ? const Color(0xFF10B981)
                      : const Color(0xFF3B82F6),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        if (isMandatory) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withAlpha(51),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'إلزامي',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isGranted)
                const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF94A3B8),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 36,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isGranted
                      ? const Color(0xFF10B981).withAlpha(38)
                      : const Color(0xFF2563EB),
                  foregroundColor:
                      isGranted ? const Color(0xFF10B981) : Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: onTap,
                child: Text(
                  isGranted ? 'تم التفعيل ✓' : 'منح الإذن الآن',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
