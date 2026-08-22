import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/mas7ool_card.dart';
import '../../domain/entities/monitored_app.dart';

class AddAppsScreen extends ConsumerStatefulWidget {
  const AddAppsScreen({super.key});

  @override
  ConsumerState<AddAppsScreen> createState() => _AddAppsScreenState();
}

class _AddAppsScreenState extends ConsumerState<AddAppsScreen> {
  List<MonitoredApp> _installedApps = [];
  bool _isLoading = true;
  String _searchQuery = '';
  bool _includeSystemApps = false;

  @override
  void initState() {
    super.initState();
    _loadInstalledApps();
  }

  Future<void> _loadInstalledApps() async {
    setState(() => _isLoading = true);
    final repo = ref.read(monitoredAppsRepositoryProvider);
    final apps = await repo.scanInstalledApps(includeSystem: _includeSystemApps);
    if (mounted) {
      setState(() {
        _installedApps = apps;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final monitoredAppsAsync = ref.watch(monitoredAppsStreamProvider);
    final repo = ref.watch(monitoredAppsRepositoryProvider);

    final monitoredPackageSet = monitoredAppsAsync.valueOrNull
            ?.map((a) => a.packageName)
            .toSet() ??
        <String>{};

    final filteredApps = _installedApps.where((app) {
      final matchesQuery = app.appName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          app.packageName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesQuery;
    }).toList();

    return RtlScaffold(
      appBar: AppBar(
        title: const Text('إضافة تطبيقات للمراقبة'),
      ),
      body: Column(
        children: [
          // Search & Filter Box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  onChanged: (val) => setState(() => _searchQuery = val),
                  decoration: InputDecoration(
                    hintText: 'ابحث عن اسم التطبيق أو الحزمة...',
                    prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'تم العثور على ${filteredApps.length} تطبيق',
                      style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                    ),
                    Row(
                      children: [
                        const Text(
                          'تطبيقات النظام',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                        ),
                        Switch(
                          value: _includeSystemApps,
                          onChanged: (val) {
                            setState(() => _includeSystemApps = val);
                            _loadInstalledApps();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Apps List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'جاري فحص التطبيقات المثبتة...',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  )
                : filteredApps.isEmpty
                    ? const Center(
                        child: Text(
                          'لا توجد تطبيقات مطابقة لبحثك',
                          style: TextStyle(color: Color(0xFF94A3B8)),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredApps.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final app = filteredApps[index];
                          final isMonitored =
                              monitoredPackageSet.contains(app.packageName);
                          final isPopular = AppConstants.popularSocialApps
                              .containsKey(app.packageName);

                          return Mas7oolCard(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: app.icon != null
                                      ? Image.memory(
                                          app.icon!,
                                          width: 42,
                                          height: 42,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          width: 42,
                                          height: 42,
                                          color: const Color(0xFF334155),
                                          child: const Icon(
                                            Icons.android_rounded,
                                            color: Colors.white70,
                                            size: 22,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              app.appName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isPopular) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFF3B82F6)
                                                    .withAlpha(51),
                                                borderRadius:
                                                    BorderRadius.circular(6),
                                              ),
                                              child: const Text(
                                                'شائع',
                                                style: TextStyle(
                                                  color: Color(0xFF60A5FA),
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        app.packageName,
                                        style: const TextStyle(
                                          fontSize: 11,
                                          color: Color(0xFF64748B),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isMonitored
                                        ? const Color(0xFF10B981)
                                            .withAlpha(38)
                                        : const Color(0xFF2563EB),
                                    foregroundColor: isMonitored
                                        ? const Color(0xFF10B981)
                                        : Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (isMonitored) {
                                      repo.removeMonitoredApp(app.packageName);
                                    } else {
                                      repo.addMonitoredApp(app);
                                    }
                                  },
                                  child: Text(
                                    isMonitored ? 'مُضاف ✓' : '+ إضافة',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
