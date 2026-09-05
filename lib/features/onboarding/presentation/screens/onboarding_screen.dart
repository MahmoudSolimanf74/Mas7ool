import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/rtl_scaffold.dart';
import '../../../../shared/widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'تحكّم بوقتك بوعي',
      'description':
          'تطبيق Mas7ool يساعدك على التوقف عن التمرير اللانهائي (Doomscrolling) في تطبيقات التواصل الاجتماعي وتحديد أهداف استخدام واضحة.',
      'icon': Icons.timer,
      'color': const Color(0xFF3B82F6),
    },
    {
      'title': 'نافذة تحديد المدة الفورية',
      'description':
          'بمجرد فتح أي تطبيق مُراقَب، تظهر لك نافذة تسألك كم دقيقة تريد استخدامه، لتبدأ جلسة استخدام محددة بدقة.',
      'icon': Icons.layers,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'title': 'تنبيه حازم وإغلاق آمن',
      'description':
          'عند انتهاء الوقت، ينبهك Mas7ool مباشرة، ويتيح لك إضافة دقيقة واحدة كحد أقصى أو الرجوع إلى الشاشة الرئيسية بسلام.',
      'icon': Icons.security,
      'color': const Color(0xFF10B981),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return RtlScaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              // Header Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? const Color(0xFF3B82F6)
                              : const Color(0xFF334155),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  if (_currentPage < _pages.length - 1)
                    TextButton(
                      onPressed: () => context.go('/permissions'),
                      child: const Text(
                        'تخطي',
                        style: TextStyle(color: Color(0xFF94A3B8)),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 30),

              // Slide Content
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (idx) => setState(() => _currentPage = idx),
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    final item = _pages[index];
                    final color = item['color'] as Color;
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: color.withAlpha(38),
                            border: Border.all(
                              color: color.withAlpha(102),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            item['icon'] as IconData,
                            size: 60,
                            color: color,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Text(
                          item['title'] as String,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            item['description'] as String,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF94A3B8),
                              height: 1.6,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              // Bottom Navigation Button
              CustomButton(
                label: _currentPage == _pages.length - 1
                    ? 'إعداد الصلاحيات والبدء'
                    : 'التالي',
                icon: Icons.arrow_forward,
                onPressed: () {
                  if (_currentPage < _pages.length - 1) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    context.go('/permissions');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
