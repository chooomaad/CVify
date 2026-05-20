import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/extensions/launch_safe_animate.dart';
import '../../shared/providers/app_state_provider.dart';

class OnboardingData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;
  final List<String> features;
  final Widget illustration;

  const OnboardingData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
    required this.features,
    required this.illustration,
  });
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingPage(
      title: 'Your career,\nelevated.',
      subtitle:
          'Join thousands of professionals who landed roles at top-tier companies using our AI-optimized templates.',
      features: ['2x Faster', 'ATS Ready'],
      featureSubtitles: [
        'Create your resume in minutes, not hours.',
        'Beat the bots with structured document data.',
      ],
      featureIcons: [Icons.bolt_rounded, Icons.trending_up_rounded],
      illustrationIcon: Icons.description_rounded,
      illustrationLabel: 'OFFER RECEIVED\nSenior Designer',
    ),
    _OnboardingPage(
      title: 'AI\nOptimization',
      subtitle:
          'Our smart engine analyzes your profile to suggest industry-standard keywords and formats.',
      features: ['Keywords Optimized', 'ATS Compatibility: 98%'],
      featureSubtitles: ['', ''],
      featureIcons: [Icons.check_circle_outline, Icons.check_circle_outline],
      illustrationIcon: Icons.psychology_rounded,
      illustrationLabel: 'AI SCANNING...',
    ),
    _OnboardingPage(
      title: 'Preview &\nExport',
      subtitle:
          'Generate beautiful, print-ready PDFs and share them instantly with recruiters worldwide.',
      features: ['Share Instantly', 'PDF Export'],
      featureSubtitles: [
        'Send your resume via link or email.',
        'High-quality, ATS-compatible PDFs.',
      ],
      featureIcons: [Icons.share_rounded, Icons.picture_as_pdf_rounded],
      illustrationIcon: Icons.picture_as_pdf_rounded,
      illustrationLabel: 'READY TO SHARE',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  void _finish() async {
    await ref.read(appStateProvider.notifier).setOnboarded();
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.description_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CVify',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  TextButton(
                    onPressed: _finish,
                    child: Text(
                      'Skip',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  SmoothPageIndicator(
                    controller: _controller,
                    count: _pages.length,
                    effect: ExpandingDotsEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: AppColors.border,
                      dotHeight: 8,
                      dotWidth: 8,
                      expansionFactor: 3,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _currentPage == _pages.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: Theme.of(
                              context,
                            ).textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ),

                  if (_currentPage == _pages.length - 1) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _finish,
                      child: Text(
                        'SKIP FOR NOW',
                        style: Theme.of(
                          context,
                        ).textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                  Text(
                    "By continuing, you agree to CVify's Terms of Service and\nPrivacy Policy.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textHint,
                      height: 1.5,
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
}

class _OnboardingPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<String> features;
  final List<String> featureSubtitles;
  final List<IconData> featureIcons;
  final IconData illustrationIcon;
  final String illustrationLabel;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.features,
    required this.featureSubtitles,
    required this.featureIcons,
    required this.illustrationIcon,
    required this.illustrationLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // Illustration card
          Expanded(
                flex: 5,
                child: Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.08),
                        blurRadius: 32,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: _IllustrationWidget(
                    icon: illustrationIcon,
                    label: illustrationLabel,
                  ),
                ),
              )
              .launchEffect(
                (w) => w
                    .animate()
                    .fadeIn(duration: 600.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      end: const Offset(1, 1),
                      duration: 600.ms,
                      curve: Curves.easeOut,
                    ),
              ),

          // Title
          Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                  height: 1.15,
                ),
              )
              .launchEffect(
                (w) => w
                    .animate()
                    .fadeIn(delay: 200.ms, duration: 500.ms)
                    .slideY(begin: 0.2, end: 0, delay: 200.ms),
              ),

          const SizedBox(height: 12),

          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ).launchEffect(
            (w) => w.animate().fadeIn(delay: 350.ms, duration: 500.ms),
          ),

          const SizedBox(height: 24),

          // Feature cards
          if (featureSubtitles.first.isNotEmpty)
            Row(
              children: List.generate(
                features.length,
                (i) => Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border, width: 0.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          featureIcons[i],
                          color: AppColors.primary,
                          size: 22,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          features[i],
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(color: AppColors.textPrimary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          featureSubtitles[i],
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ).launchEffect(
                    (w) => w.animate().fadeIn(
                      delay: Duration(milliseconds: 400 + i * 100),
                      duration: 400.ms,
                    ),
                  ),
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border, width: 0.5),
              ),
              child: Column(
                children: List.generate(
                  features.length,
                  (i) => Padding(
                    padding: EdgeInsets.only(
                      bottom: i < features.length - 1 ? 8 : 0,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          features[i],
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).launchEffect(
              (w) => w.animate().fadeIn(delay: 400.ms, duration: 400.ms),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _IllustrationWidget extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IllustrationWidget({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Mock document/screen background
        Container(
          width: 180,
          height: 220,
          decoration: BoxDecoration(
            color: const Color(0xFF1A3CB8),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Stack(
            children: [
              // Decorative circles
              Positioned(
                top: 20,
                right: 20,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.15),
                  ),
                ),
              ),
              Center(
                child: Container(
                  width: 100,
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A6FE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 32),
                      const SizedBox(height: 8),
                      Container(
                        height: 4,
                        width: 60,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        height: 4,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 4,
                        width: 50,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Label badge
        Positioned(
          bottom: 40,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.celebration_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
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
