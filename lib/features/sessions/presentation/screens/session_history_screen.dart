import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/mas7ool_card.dart';
import '../../domain/entities/app_usage_session.dart';

class SessionHistoryScreen extends ConsumerWidget {
  const SessionHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(sessionHistoryStreamProvider);
    final repo = ref.watch(sessionRepositoryProvider);

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('سجل الجلسات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Color(0xFFEF4444)),
            tooltip: 'مسح السجل',
            onPressed: () => _confirmClearHistory(context, repo),
          ),
        ],
      ),
      body: historyAsync.when(
        data: (sessions) {
          if (sessions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history_toggle_off_rounded,
                    size: 64,
                    color: Color(0xFF64748B),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا يوجد سجل جلسات سابق',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'ستظهر هنا جميع جلسات الاستخدام المكتملة والمحددة.',
                    style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: sessions.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final session = sessions[index];
              return _buildHistoryItem(session);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text('خطأ: $err', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(AppUsageSession session) {
    Color getStatusColor() {
      switch (session.status) {
        case SessionStatus.active:
        case SessionStatus.extended:
          return const Color(0xFF3B82F6);
        case SessionStatus.expired:
        case SessionStatus.ended:
          return const Color(0xFF10B981);
        case SessionStatus.cancelled:
          return const Color(0xFFEF4444);
        default:
          return const Color(0xFF94A3B8);
      }
    }

    String getStatusText() {
      switch (session.status) {
        case SessionStatus.active:
          return 'نشطة حالياً';
        case SessionStatus.extended:
          return 'ممتدة (+${session.extensionCount})';
        case SessionStatus.expired:
        case SessionStatus.ended:
          return 'مكتملة';
        case SessionStatus.cancelled:
          return 'ملغاة';
        default:
          return session.status.name;
      }
    }

    return Mas7oolCard(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: getStatusColor().withAlpha(38),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.access_time_rounded,
              color: getStatusColor(),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      session.appName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: getStatusColor().withAlpha(38),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        getStatusText(),
                        style: TextStyle(
                          color: getStatusColor(),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      TimeFormatter.formatDateTimeArabic(session.startedAt),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'المدة: ${session.totalDurationMinutes} دقيقة',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmClearHistory(BuildContext context, dynamic repo) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('مسح سجل الجلسات', style: TextStyle(color: Colors.white)),
          content: const Text(
            'هل أنت متأكد من مسح جميع بيانات وسجلات الجلسات السابقة بشكل نهائي؟',
            style: TextStyle(color: Color(0xFF94A3B8)),
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
                repo.clearHistory();
                Navigator.pop(ctx);
              },
              child: const Text('مسح الكل'),
            ),
          ],
        ),
      ),
    );
  }
}
