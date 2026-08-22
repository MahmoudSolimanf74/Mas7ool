import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/mas7ool_card.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(databaseProvider);

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('الإعدادات والتوافق'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section 1: Platform & OEM
          const Text(
            'توافق النظام والأجهزة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 8),

          Mas7oolCard(
            onTap: () => context.push('/settings/compatibility'),
            child: const Row(
              children: [
                Icon(Icons.phone_android_rounded, color: Color(0xFF38BDF8)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'دليل توافق الشركات المصنعة',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'إعدادات Xiaomi وSamsung وOppo لمنع إيقاف التطبيق',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 2: Permissions
          const Text(
            'الصلاحيات والأذونات',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 8),

          Mas7oolCard(
            onTap: () => context.push('/permissions'),
            child: const Row(
              children: [
                Icon(Icons.security_rounded, color: Color(0xFF10B981)),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'فحص وتحديث الصلاحيات',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'الوصول لبيانات الاستخدام، الـ Overlay، والإشعارات',
                        style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_back_ios_new_rounded, size: 16, color: Color(0xFF64748B)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Section 3: Privacy & Data
          const Text(
            'الخصوصية والبيانات المحلية',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF38BDF8),
            ),
          ),
          const SizedBox(height: 8),

          Mas7oolCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lock_outline_rounded, color: Color(0xFF10B981), size: 20),
                    SizedBox(width: 8),
                    Text(
                      'خصوصية محلية 100% (Local-First)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'جميع بياناتك وسجلات استخدامك محفوظة فقط على جهازك محلياً في قاعدة بيانات مشفرة، ولا يتم إرسال أو تخزين أي معلومة خارج هاتفك.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 14),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFEF4444),
                    side: const BorderSide(color: Color(0xFFEF4444)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => _confirmResetAllData(context, db),
                  icon: const Icon(Icons.delete_forever_rounded, size: 18),
                  label: const Text('مسح جميع البيانات وإعادة الضبط'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Center(
            child: Text(
              '${AppConstants.appName} v1.0.0 (Android Native + Flutter)',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _confirmResetAllData(BuildContext context, dynamic db) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text('إعادة ضبط المصنع', style: TextStyle(color: Colors.white)),
          content: const Text(
            'سيتم حذف جميع التطبيقات المُراقَبة وسجل الجلسات بالكامل. هل تريد المتابعة؟',
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
              onPressed: () async {
                await db.clearOldSessions();
                AppLogger.clearDiagnostics();
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم مسح البيانات بنجاح.')),
                  );
                }
              },
              child: const Text('مسح نهائي'),
            ),
          ],
        ),
      ),
    );
  }
}
