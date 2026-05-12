import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/translations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/models/template_model.dart';
import '../../shared/providers/cv_provider.dart';

final _selectedCategoryProvider = StateProvider<String>((ref) => 'Tous');

class TemplatesScreen extends ConsumerWidget {
  const TemplatesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCat = ref.watch(_selectedCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final templates =
        selectedCat == 'Tous'
            ? TemplateRepository.all
            : TemplateRepository.all
                .where((t) => t.category == selectedCat)
                .toList();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // App bar
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            pinned: true,
            titleSpacing: 20,
            toolbarHeight: 70,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.t('templates_title'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  '${TemplateRepository.all.length} modèles • ${context.t('templates_subtitle_free')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          // Category filter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children:
                      TemplateRepository.categories.map((cat) {
                        final isSelected = selectedCat == cat;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap:
                                () =>
                                    ref
                                        .read(
                                          _selectedCategoryProvider.notifier,
                                        )
                                        .state = cat,
                            child: AnimatedContainer(
                              duration: 180.ms,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 9,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isSelected
                                        ? AppColors.primary
                                        : isDark
                                        ? AppColors.darkSurface
                                        : AppColors.surface,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color:
                                      isSelected
                                          ? AppColors.primary
                                          : isDark
                                          ? AppColors.darkBorder
                                          : AppColors.border,
                                ),
                              ),
                              child: Text(
                                cat,
                                style: Theme.of(
                                  context,
                                ).textTheme.labelMedium?.copyWith(
                                  color:
                                      isSelected
                                          ? Colors.white
                                          : AppColors.textSecondary,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
            ),
          ),

          // Template list
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) => _TemplateCard(
                  template: templates[i],
                  index: i,
                  isDark: isDark,
                ),
                childCount: templates.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Template card
// ─────────────────────────────────────────────────────────────────────────────
class _TemplateCard extends ConsumerWidget {
  final TemplateModel template;
  final int index;
  final bool isDark;

  const _TemplateCard({
    required this.template,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: isDark ? null : AppColors.shadowMd,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () async {
                final cv = await ref
                    .read(cvListProvider.notifier)
                    .create(templateId: template.id);
                if (context.mounted) {
                  context.push('/cv-builder', extra: cv.id);
                }
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview area
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(19),
                    ),
                    child: SizedBox(
                      height: 220,
                      child: _TemplatePreview(template: template),
                    ),
                  ),

                  // Info row
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    template.name,
                                    style:
                                        Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Text(
                                      context.t('templates_free_badge'),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.labelSmall?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 9,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                template.description,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textTertiary),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 5,
                                children:
                                    template.tags.take(3).map((tag) {
                                      return Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              isDark
                                                  ? AppColors
                                                      .darkSurfaceElevated
                                                  : AppColors.gray100,
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Text(
                                          tag,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.labelSmall?.copyWith(
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: AppColors.shadowPrimary,
                          ),
                          child: Text(
                            context.t('templates_use'),
                            style: Theme.of(
                              context,
                            ).textTheme.labelLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
        .animate()
        .fadeIn(delay: Duration(milliseconds: index * 80), duration: 400.ms)
        .slideY(
          begin: 0.06,
          end: 0,
          delay: Duration(milliseconds: index * 80),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Preview dispatcher — routes to the correct visual per layout type
// ─────────────────────────────────────────────────────────────────────────────
class _TemplatePreview extends StatelessWidget {
  final TemplateModel template;
  const _TemplatePreview({required this.template});

  @override
  Widget build(BuildContext context) {
    switch (template.layout) {
      case TemplateLayout.modern:
        return _ModernPreview(template: template);
      case TemplateLayout.minimal:
        return _MinimalPreview(template: template);
      case TemplateLayout.corporate:
        return _CorporatePreview(template: template);
      case TemplateLayout.creative:
        return _CreativePreview(template: template);
      case TemplateLayout.ats:
        return _AtsPreview(template: template);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 1. MODERN preview — blue gradient bg, mini two-column card
// ─────────────────────────────────────────────────────────────────────────────
class _ModernPreview extends StatelessWidget {
  final TemplateModel template;
  const _ModernPreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final accent = template.colors.first;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [accent.withValues(alpha: 0.9), accent],
        ),
      ),
      child: Center(
        child: Container(
          width: 160,
          height: 190,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              // Left sidebar
              Container(
                width: 50,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(10),
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 8,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(height: 12),
                    ..._miniLines(5, Colors.white.withValues(alpha: 0.7), 28),
                    const SizedBox(height: 10),
                    ..._miniLines(3, Colors.white.withValues(alpha: 0.5), 24),
                  ],
                ),
              ),
              // Right content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 5,
                        width: 70,
                        color: const Color(0xFF1A1A2E),
                      ),
                      const SizedBox(height: 3),
                      Container(height: 3, width: 50, color: accent),
                      const SizedBox(height: 8),
                      Container(height: 1, color: const Color(0xFFE5E7EB)),
                      const SizedBox(height: 8),
                      ..._miniLines(3, const Color(0xFFD1D5DB), 80),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 40,
                        color: accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 5),
                      ..._miniLines(4, const Color(0xFFD1D5DB), 80),
                      const SizedBox(height: 8),
                      Container(
                        height: 3,
                        width: 35,
                        color: accent.withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 5),
                      ..._miniLines(2, const Color(0xFFD1D5DB), 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 2. MINIMAL preview — light gray bg, centered white card, lots of space
// ─────────────────────────────────────────────────────────────────────────────
class _MinimalPreview extends StatelessWidget {
  final TemplateModel template;
  const _MinimalPreview({required this.template});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Center(
        child: Container(
          width: 170,
          height: 195,
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Big name
              Container(height: 7, width: 110, color: const Color(0xFF111827)),
              const SizedBox(height: 4),
              Container(height: 3, width: 70, color: const Color(0xFF6B7280)),
              const SizedBox(height: 6),
              // Contact line
              Row(
                children: [
                  Container(
                    height: 2,
                    width: 30,
                    color: const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 2,
                    width: 24,
                    color: const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 2,
                    width: 28,
                    color: const Color(0xFFD1D5DB),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(height: 0.5, color: const Color(0xFF111827)),
              const SizedBox(height: 10),
              // Section — no decorations
              Container(height: 3, width: 45, color: const Color(0xFF374151)),
              const SizedBox(height: 6),
              ..._miniLines(3, const Color(0xFFD1D5DB), 140),
              const SizedBox(height: 10),
              Container(height: 3, width: 38, color: const Color(0xFF374151)),
              const SizedBox(height: 6),
              ..._miniLines(3, const Color(0xFFD1D5DB), 140),
              const SizedBox(height: 10),
              Container(height: 3, width: 30, color: const Color(0xFF374151)),
              const SizedBox(height: 6),
              Row(
                children: [
                  Container(
                    height: 6,
                    width: 30,
                    color: const Color(0xFFE5E7EB),
                    child: null,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 6,
                    width: 28,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 6,
                    width: 25,
                    color: const Color(0xFFE5E7EB),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 3. CORPORATE preview — dark navy full-width header + content
// ─────────────────────────────────────────────────────────────────────────────
class _CorporatePreview extends StatelessWidget {
  final TemplateModel template;
  const _CorporatePreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final navy = template.colors.first;
    return Container(
      color: const Color(0xFFF3F4F6),
      child: Center(
        child: Container(
          width: 170,
          height: 195,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Full-width dark header
              Container(
                height: 60,
                color: navy,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 6, width: 90, color: Colors.white),
                    const SizedBox(height: 4),
                    Container(
                      height: 3,
                      width: 60,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        Container(
                          height: 2,
                          width: 35,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 2,
                          width: 28,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          height: 2,
                          width: 32,
                          color: Colors.white.withValues(alpha: 0.4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Body: two column
              Expanded(
                child: Row(
                  children: [
                    // Left column
                    SizedBox(
                      width: 55,
                      child: Container(
                        color: const Color(0xFFF8F9FA),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 3,
                              width: 35,
                              color: navy.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 4),
                            ..._miniLines(4, const Color(0xFFD1D5DB), 40),
                            const SizedBox(height: 6),
                            Container(
                              height: 3,
                              width: 30,
                              color: navy.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 4),
                            ..._miniLines(3, const Color(0xFFD1D5DB), 40),
                          ],
                        ),
                      ),
                    ),
                    Container(width: 0.5, color: const Color(0xFFE5E7EB)),
                    // Right column
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 3,
                              width: 50,
                              color: navy.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 4),
                            ..._miniLines(3, const Color(0xFFD1D5DB), 90),
                            const SizedBox(height: 6),
                            Container(
                              height: 3,
                              width: 45,
                              color: navy.withValues(alpha: 0.7),
                            ),
                            const SizedBox(height: 4),
                            ..._miniLines(3, const Color(0xFFD1D5DB), 90),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 4. CREATIVE preview — bold wide purple sidebar, decorative shapes
// ─────────────────────────────────────────────────────────────────────────────
class _CreativePreview extends StatelessWidget {
  final TemplateModel template;
  const _CreativePreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final purple = template.colors.first;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [purple.withValues(alpha: 0.08), const Color(0xFFF5F0FF)],
        ),
      ),
      child: Center(
        child: Container(
          width: 170,
          height: 195,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: purple.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Row(
              children: [
                // Wide creative sidebar
                Container(
                  width: 65,
                  color: purple,
                  child: Stack(
                    children: [
                      // Decorative circle
                      Positioned(
                        top: -20,
                        right: -20,
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -15,
                        left: -15,
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Container(
                              height: 2.5,
                              width: 40,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 5),
                            ..._miniLines(
                              4,
                              Colors.white.withValues(alpha: 0.5),
                              38,
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 2.5,
                              width: 35,
                              color: Colors.white.withValues(alpha: 0.4),
                            ),
                            const SizedBox(height: 5),
                            ..._miniLines(
                              3,
                              Colors.white.withValues(alpha: 0.5),
                              38,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 6,
                          width: 80,
                          color: const Color(0xFF1F2937),
                        ),
                        const SizedBox(height: 3),
                        Container(height: 3, width: 55, color: purple),
                        const SizedBox(height: 10),
                        // Creative section divider
                        Row(
                          children: [
                            Container(width: 3, height: 10, color: purple),
                            const SizedBox(width: 5),
                            Container(
                              height: 2.5,
                              width: 35,
                              color: purple.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ..._miniLines(3, const Color(0xFFD1D5DB), 85),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(width: 3, height: 10, color: purple),
                            const SizedBox(width: 5),
                            Container(
                              height: 2.5,
                              width: 30,
                              color: purple.withValues(alpha: 0.7),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        ..._miniLines(3, const Color(0xFFD1D5DB), 85),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 5. ATS preview — clean teal accent line, pure text layout
// ─────────────────────────────────────────────────────────────────────────────
class _AtsPreview extends StatelessWidget {
  final TemplateModel template;
  const _AtsPreview({required this.template});

  @override
  Widget build(BuildContext context) {
    final teal = template.colors.first;
    return Container(
      color: const Color(0xFFF0FDFA),
      child: Center(
        child: Container(
          width: 170,
          height: 195,
          color: Colors.white,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name block
              Container(height: 6, width: 100, color: const Color(0xFF111827)),
              const SizedBox(height: 4),
              Container(height: 3, width: 65, color: teal),
              const SizedBox(height: 5),
              // Contact row — all text
              Row(
                children: [
                  Container(
                    height: 2,
                    width: 32,
                    color: const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 2,
                    width: 26,
                    color: const Color(0xFFD1D5DB),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    height: 2,
                    width: 30,
                    color: const Color(0xFFD1D5DB),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Teal accent rule
              Container(height: 2, color: teal),
              const SizedBox(height: 8),
              // Section label — uppercase
              Container(height: 3.5, width: 55, color: const Color(0xFF374151)),
              const SizedBox(height: 5),
              ..._miniLines(3, const Color(0xFFD1D5DB), 140),
              const SizedBox(height: 8),
              Container(height: 2, color: const Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              Container(height: 3.5, width: 48, color: const Color(0xFF374151)),
              const SizedBox(height: 5),
              ..._miniLines(3, const Color(0xFFD1D5DB), 140),
              const SizedBox(height: 8),
              Container(height: 2, color: const Color(0xFFE5E7EB)),
              const SizedBox(height: 8),
              Container(height: 3.5, width: 40, color: const Color(0xFF374151)),
              const SizedBox(height: 5),
              Row(
                children: [
                  Container(
                    height: 7,
                    width: 28,
                    color: teal.withValues(alpha: 0.15),
                    alignment: Alignment.center,
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 7,
                    width: 24,
                    color: teal.withValues(alpha: 0.15),
                  ),
                  const SizedBox(width: 4),
                  Container(
                    height: 7,
                    width: 30,
                    color: teal.withValues(alpha: 0.15),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared helper
// ─────────────────────────────────────────────────────────────────────────────
List<Widget> _miniLines(int count, Color color, double maxW) {
  final widths = [1.0, 0.8, 0.95, 0.7, 0.85];
  return List.generate(count, (i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Container(
        height: 2.5,
        width: maxW * widths[i % widths.length],
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(1),
        ),
      ),
    );
  });
}
