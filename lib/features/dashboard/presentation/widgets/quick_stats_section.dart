import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/mas7ool_card.dart';

class QuickStatsSection extends ConsumerWidget {
  const QuickStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoredApps = ref.watch(monitoredAppsStreamProvider).valueOrNull ?? [];
    final sessions = ref.watch(sessionHistoryStreamProvider).valueOrNull ?? [];

    final enabledAppsCount = monitoredApps.where((a) => a.isEnabled).length;
    final totalSessionsToday = sessions.where((s) {
      final now = DateTime.now();
      return s.startedAt.year == now.year &&
          s.startedAt.month == now.month &&
          s.startedAt.day == now.day;
    }).length;

    final totalMinutesToday = sessions.where((s) {
      final now = DateTime.now();
      return s.startedAt.year == now.year &&
          s.startedAt.month == now.month &&
          s.startedAt.day == now.day;
    }).fold<int>(0, (sum, s) => sum + s.totalDurationMinutes);

    return Row(
      children: [
        Expanded(
          child: Mas7oolCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.apps,
                  color: Color(0xFF38BDF8),
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  '$enabledAppsCount',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'تطبيقات مُراقَبة',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Mas7oolCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.timelapse,
                  color: Color(0xFF818CF8),
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalSessionsToday',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'جلسات اليوم',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Mas7oolCard(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Column(
              children: [
                const Icon(
                  Icons.access_time,
                  color: Color(0xFF34D399),
                  size: 26,
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalMinutesToday د',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'وقت واعٍ اليوم',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
