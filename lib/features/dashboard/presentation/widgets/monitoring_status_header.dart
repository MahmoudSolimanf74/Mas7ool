import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mas7ool/core/providers/app_providers.dart';
import 'package:mas7ool/features/monitoring/domain/services/monitoring_state_machine.dart';
import 'package:mas7ool/shared/widgets/mas7ool_card.dart';

class MonitoringStatusHeader extends ConsumerWidget {
  const MonitoringStatusHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final monitoringState = ref.watch(monitoringStateStreamProvider).valueOrNull ??
        MonitoringState.stopped;
    final stateMachine = ref.watch(monitoringStateMachineProvider);
    final isRunning = monitoringState.isMonitoring;

    return Mas7oolCard(
      color: isRunning
          ? const Color(0xFF10B981).withAlpha(31)
          : const Color(0xFFEF4444).withAlpha(31),
      border: Border.all(
        color: isRunning
            ? const Color(0xFF10B981).withAlpha(102)
            : const Color(0xFFEF4444).withAlpha(102),
        width: 1.5,
      ),
      child: Row(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRunning
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              boxShadow: [
                BoxShadow(
                  color: (isRunning
                          ? const Color(0xFF10B981)
                          : const Color(0xFFEF4444))
                      .withAlpha(153),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isRunning ? 'خدمة المراقبة نشطة' : 'خدمة المراقبة متوقفة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isRunning
                      ? 'يراقب مسؤول فتح التطبيقات المحددة تلقائياً'
                      : 'اضغط لتشغيل المراقبة والتحكم بالوقت',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isRunning
                  ? const Color(0xFFEF4444).withAlpha(51)
                  : const Color(0xFF10B981),
              foregroundColor:
                  isRunning ? const Color(0xFFF87171) : Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            onPressed: () async {
              if (isRunning) {
                await stateMachine.stopMonitoring();
              } else {
                await stateMachine.startMonitoring();
              }
            },
            child: Text(
              isRunning ? 'إيقاف' : 'تشغيل',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
