import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/mas7ool_card.dart';
import '../../domain/entities/monitored_app.dart';

class MonitoredAppsScreen extends ConsumerWidget {
  const MonitoredAppsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appsAsync = ref.watch(monitoredAppsStreamProvider);
    final repo = ref.watch(monitoredAppsRepositoryProvider);

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('التطبيقات المُراقَبة'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Color(0xFF38BDF8)),
            tooltip: 'إضافة تطبيقات',
            onPressed: () => context.push('/monitored-apps/add'),
          ),
        ],
      ),
      body: appsAsync.when(
        data: (apps) {
          if (apps.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3B82F6).withAlpha(38),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.apps_rounded,
                        size: 64,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'لا توجد تطبيقات تحت المراقبة بعد',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'أضف تطبيقات التواصل الاجتماعي التي ترغب بالتحكم بوقت استخدامها وتجنب التشتت.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF94A3B8),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ElevatedButton.icon(
                      onPressed: () => context.push('/monitored-apps/add'),
                      icon: const Icon(Icons.add_rounded),
                      label: const Text('إضافة تطبيق الآن'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: apps.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final app = apps[index];
              return _buildAppItem(context, app, repo);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('حدث خطأ: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/monitored-apps/add'),
        backgroundColor: const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('إضافة تطبيق'),
      ),
    );
  }

  Widget _buildAppItem(
    BuildContext context,
    MonitoredApp app,
    dynamic repo,
  ) {
    return Mas7oolCard(
      child: Row(
        children: [
          // App Icon
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: app.icon != null
                ? Image.memory(
                    app.icon!,
                    width: 46,
                    height: 46,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 46,
                    height: 46,
                    color: const Color(0xFF334155),
                    child: const Icon(
                      Icons.android_rounded,
                      color: Colors.white70,
                    ),
                  ),
          ),
          const SizedBox(width: 14),

          // App Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  app.appName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  app.packageName,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Active toggle switch
          Switch(
            value: app.isEnabled,
            activeThumbColor: const Color(0xFF38BDF8),
            onChanged: (val) {
              repo.toggleAppEnabled(app.packageName, val);
            },
          ),

          // Delete button
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444)),
            onPressed: () => _confirmDelete(context, app, repo),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, MonitoredApp app, dynamic repo) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('إزالة من المراقبة', style: TextStyle(color: Colors.white)),
          content: Text(
            'هل أنت متأكد من إزالة "${app.appName}" من قائمة التطبيقات المُراقَبة؟',
            style: const TextStyle(color: Color(0xFF94A3B8)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('إلغاء', style: TextStyle(color: Color(0xFF94A3B8))),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                repo.removeMonitoredApp(app.packageName);
                Navigator.pop(ctx);
              },
              child: const Text('إزالة'),
            ),
          ],
        ),
      ),
    );
  }
}
