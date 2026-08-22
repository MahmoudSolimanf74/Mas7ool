import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/mas7ool_card.dart';
import '../../../main/presentation/screens/main_navigation_screen.dart';
import '../widgets/monitoring_status_header.dart';
import '../widgets/active_session_card.dart';
import '../widgets/quick_stats_section.dart';
import '../widgets/permission_warning_banner.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-check permissions on launch
    Future.microtask(() {
      ref.read(permissionManagerProvider).checkAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final monitoredApps = ref.watch(monitoredAppsStreamProvider).valueOrNull ?? [];

    return RtlScaffold(
      appBar: AppBar(
        title: const Text(
          'Mas7ool',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(permissionManagerProvider).checkAll();
        },
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Warning Banner if permissions missing
            const PermissionWarningBanner(),

            // Monitoring Service Status & Quick Switch
            const MonitoringStatusHeader(),
            const SizedBox(height: 16),

            // Active Session Live Card
            const ActiveSessionCard(),
            const SizedBox(height: 16),

            // Quick Stats
            const QuickStatsSection(),
            const SizedBox(height: 20),

            // Monitored Apps Header & Preview
            const Text(
              'التطبيقات الخاضعة للتحكم',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),

            if (monitoredApps.isEmpty)
              Mas7oolCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_to_home_screen_rounded,
                      size: 40,
                      color: Color(0xFF38BDF8),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'لم تختر أي تطبيق للمراقبة بعد',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'اختر تطبيقات التواصل كـ Instagram وTikTok لبدء التحكم بوقتك.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => context.push('/monitored-apps/add'),
                      child: const Text('+ إضافة تطبيقات للمراقبة'),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: monitoredApps.take(4).map((app) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Mas7oolCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: app.icon != null
                                ? Image.memory(
                                    app.icon!,
                                    width: 38,
                                    height: 38,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 38,
                                    height: 38,
                                    color: const Color(0xFF334155),
                                    child: const Icon(
                                      Icons.android_rounded,
                                      color: Colors.white70,
                                      size: 20,
                                    ),
                                  ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  app.appName,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  app.isEnabled ? 'المراقبة مفعلة' : 'متوقف مؤقتاً',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: app.isEnabled
                                        ? const Color(0xFF34D399)
                                        : const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            app.isEnabled
                                ? Icons.check_circle_rounded
                                : Icons.pause_circle_outline_rounded,
                            color: app.isEnabled
                                ? const Color(0xFF10B981)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
