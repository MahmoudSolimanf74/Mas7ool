import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mas7ool/core/providers/app_providers.dart';
import 'package:mas7ool/core/utils/time_formatter.dart';
import 'package:mas7ool/shared/widgets/mas7ool_card.dart';

class ActiveSessionCard extends ConsumerWidget {
  const ActiveSessionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSession = ref.watch(activeSessionStreamProvider).valueOrNull;
    final sessionEngine = ref.watch(sessionEngineProvider);

    if (activeSession == null || !activeSession.status.isRunning) {
      return Mas7oolCard(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF334155).withAlpha(128),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_empty_rounded,
                  color: Color(0xFF94A3B8),
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'لا توجد جلسة نشطة حالياً',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'ستبدأ الجلسة فور فتح أي تطبيق من التطبيقات المُراقَبة',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isExpired = activeSession.isExpired;
    final remaining = activeSession.remainingTime;
    final progress = activeSession.progressFraction;

    return Mas7oolCard(
      color: isExpired
          ? const Color(0xFF7F1D1D).withAlpha(102)
          : const Color(0xFF1E293B),
      border: Border.all(
        color: isExpired
            ? const Color(0xFFEF4444)
            : const Color(0xFF3B82F6).withAlpha(153),
        width: 1.5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isExpired
                          ? const Color(0xFFEF4444).withAlpha(51)
                          : const Color(0xFF3B82F6).withAlpha(51),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isExpired
                          ? Icons.warning_amber_rounded
                          : Icons.timer_rounded,
                      color: isExpired
                          ? const Color(0xFFEF4444)
                          : const Color(0xFF38BDF8),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'جلسة: ${activeSession.appName}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              if (activeSession.extensionCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '+${activeSession.extensionCount} تمديد',
                    style: const TextStyle(
                      color: Color(0xFFFBBF24),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Countdown display
          Center(
            child: Column(
              children: [
                Text(
                  TimeFormatter.formatRemaining(remaining),
                  style: TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: isExpired
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF38BDF8),
                  ),
                ),
                Text(
                  isExpired ? 'انتهت المدة المحددة!' : 'الوقت المتبقي للجلسة',
                  style: TextStyle(
                    fontSize: 13,
                    color: isExpired
                        ? const Color(0xFFFCA5A5)
                        : const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Linear Progress Indicator
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFF334155),
              valueColor: AlwaysStoppedAnimation<Color>(
                isExpired
                    ? const Color(0xFFEF4444)
                    : (progress > 0.8
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF38BDF8)),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Session Quick Controls
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF334155),
                    foregroundColor: const Color(0xFFFBBF24),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => sessionEngine.extendSession(
                    activeSession.packageName,
                    additionalMinutes: 1,
                  ),
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text(
                    '+1 دقيقة',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => sessionEngine.endSession(
                    activeSession.packageName,
                    sendHome: true,
                  ),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  label: const Text(
                    'إنهاء وإغلاق',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
