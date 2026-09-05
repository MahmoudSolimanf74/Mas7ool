import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/mas7ool_card.dart';

class DeviceCompatibilityScreen extends ConsumerStatefulWidget {
  const DeviceCompatibilityScreen({super.key});

  @override
  ConsumerState<DeviceCompatibilityScreen> createState() =>
      _DeviceCompatibilityScreenState();
}

class _DeviceCompatibilityScreenState
    extends ConsumerState<DeviceCompatibilityScreen> {
  Map<String, dynamic> _deviceInfo = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDeviceInfo();
  }

  Future<void> _loadDeviceInfo() async {
    final bridge = ref.read(nativeBridgeProvider);
    final info = await bridge.getDeviceInfo();
    if (mounted) {
      setState(() {
        _deviceInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bridge = ref.read(nativeBridgeProvider);
    final manufacturer =
        (_deviceInfo['manufacturer'] as String? ?? '').toUpperCase();
    final model = _deviceInfo['model'] as String? ?? '';
    final sdkInt = _deviceInfo['sdkInt'] as int? ?? 0;
    final oemType = _deviceInfo['oemType'] as String? ?? 'OTHER';

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('دليل توافق الأجهزة'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Device Info Card
                Mas7oolCard(
                  color: const Color(0xFF3B82F6).withAlpha(31),
                  border: Border.all(
                    color: const Color(0xFF3B82F6).withAlpha(102),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF38BDF8),
                        size: 28,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'جهازك: $manufacturer $model',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'إصدار Android SDK: $sdkInt | النوع: $oemType',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                const Text(
                  'تقوم بعض واجهات الشركات المصنعة بإيقاف التطبيقات في الخلفية بقوة لتوفير البطارية. إليك خطوات ضبط جهازك لضمان عدم توقف المراقبة:',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),

                // Xiaomi / HyperOS
                _buildManufacturerSection(
                  title: 'أجهزة Xiaomi / Redmi / POCO (MIUI & HyperOS)',
                  isCurrentOem: oemType == 'XIAOMI',
                  instructions: [
                    '1. تفعيل "التشغيل التلقائي (AutoStart)" للتطبيق.',
                    '2. منح إذن "عرض النوافذ المنبثقة أثناء التشغيل في الخلفية".',
                    '3. ضبط موفر البطارية على "لا توجد قيود (No Restrictions)".',
                  ],
                  actions: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => bridge.openManufacturerAutostart(),
                      icon: const Icon(Icons.power_settings_new, size: 16),
                      label: const Text('فتح إعدادات AutoStart'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF38BDF8),
                        side: const BorderSide(color: Color(0xFF38BDF8)),
                      ),
                      onPressed: () => bridge.openXiaomiBackgroundPopup(),
                      icon: const Icon(Icons.layers, size: 16),
                      label: const Text('إذن النوافذ المنبثقة (Xiaomi)'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Samsung (OneUI)
                _buildManufacturerSection(
                  title: 'أجهزة Samsung (One UI)',
                  isCurrentOem: oemType == 'SAMSUNG',
                  instructions: [
                    '1. اذهب إلى: العناية بالجهاز > البطارية > حدود استخدام الخلفية.',
                    '2. أضف Mas7ool إلى قائمة "التطبيقات التي لا توضع في وضع السكون أبداً".',
                    '3. من معلومات التطبيق > البطارية، اختر "غير مقيّد (Unrestricted)".',
                  ],
                  actions: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => bridge.openManufacturerAutostart(),
                      icon: const Icon(Icons.battery_saver, size: 16),
                      label: const Text('فتح إعدادات بطارية سامسونج'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Oppo & Realme
                _buildManufacturerSection(
                  title: 'أجهزة Oppo / Realme / OnePlus (ColorOS & OxygenOS)',
                  isCurrentOem: oemType == 'OPPO' || oemType == 'REALME' || oemType == 'ONEPLUS',
                  instructions: [
                    '1. فعّل خيار "السماح بالبدء التلقائي (Allow Auto-Launch)".',
                    '2. فعّل خيار "السماح بالنشاط في الخلفية".',
                    '3. في إعدادات إدارة البطارية، عطّل تجميد التطبيقات السريع.',
                  ],
                  actions: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => bridge.openManufacturerAutostart(),
                      icon: const Icon(Icons.launch, size: 16),
                      label: const Text('فتح إعدادات بدء التشغيل'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Huawei
                _buildManufacturerSection(
                  title: 'أجهزة Huawei & Honor (EMUI / HarmonyOS)',
                  isCurrentOem: oemType == 'HUAWEI',
                  instructions: [
                    '1. في مدير الهاتف > تشغيل التطبيقات (App Launch)، ابحث عن Mas7ool.',
                    '2. غيّر الإعداد من تلقائي إلى "إدارة يدوية".',
                    '3. فعّل جميع الخيارات: بدء التشغيل التلقائي، وبدء التشغيل الثانوي، والتشغيل في الخلفية.',
                  ],
                  actions: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2563EB),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => bridge.openManufacturerAutostart(),
                      icon: const Icon(Icons.settings, size: 16),
                      label: const Text('فتح إدارة بدء التشغيل'),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
              ],
            ),
    );
  }

  Widget _buildManufacturerSection({
    required String title,
    required bool isCurrentOem,
    required List<String> instructions,
    required List<Widget> actions,
  }) {
    return Mas7oolCard(
      color: isCurrentOem
          ? const Color(0xFF1E293B)
          : const Color(0xFF0F172A).withAlpha(128),
      border: Border.all(
        color: isCurrentOem
            ? const Color(0xFF38BDF8)
            : const Color(0xFF334155),
        width: isCurrentOem ? 1.8 : 1.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (isCurrentOem)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withAlpha(51),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'جهازك الحالي',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          ...instructions.map(
            (ins) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                ins,
                style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8), height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...actions,
        ],
      ),
    );
  }
}
