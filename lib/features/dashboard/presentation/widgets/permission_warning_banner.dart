import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/permissions/app_permissions.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/mas7ool_card.dart';

class PermissionWarningBanner extends ConsumerWidget {
  const PermissionWarningBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final permissions = ref.watch(permissionsStateStreamProvider).valueOrNull ?? {};

    final isUsageGranted =
        permissions[AppPermissionType.usageAccess]?.isGranted ?? true;
    final isOverlayGranted =
        permissions[AppPermissionType.overlay]?.isGranted ?? true;

    if (isUsageGranted && isOverlayGranted) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Mas7oolCard(
        color: const Color(0xFFEF4444).withAlpha(38),
        border: Border.all(
          color: const Color(0xFFEF4444).withAlpha(128),
          width: 1.5,
        ),
        child: Row(
          children: [
            const Icon(
              Icons.warning,
              color: Color(0xFFEF4444),
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تنبيه: صلاحيات أساسية مفقودة',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'المراقبة والـ Overlay لن يعملا بدون هذه الصلاحيات.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFCA5A5),
                    ),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => context.push('/permissions'),
              child: const Text(
                'إصلاح',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
