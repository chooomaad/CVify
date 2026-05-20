import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/translations.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_logger.dart';
import '../../shared/models/cv_model.dart';
import '../../shared/models/template_model.dart';
import '../../shared/providers/cv_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final Widget child;
  final String currentLocation;

  const HomeScreen({
    super.key,
    required this.child,
    required this.currentLocation,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/templates')) return 1;
    if (location.startsWith('/premium')) return 3;
    if (location.startsWith('/settings')) return 4;
    return 0;
  }

  Future<void> _onTap(BuildContext context, int index) async {
    switch (index) {
      case 0:
        context.go('/home');
        return;
      case 1:
        context.go('/templates');
        return;
      case 2:
        try {
          final cv = await ref.read(cvListProvider.notifier).create();
          if (context.mounted) {
            context.push('/cv-builder', extra: cv.id);
          }
        } catch (error, stackTrace) {
          AppLogger.error(
            'Failed to create a CV from the home navigation',
            error,
            stackTrace,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Unable to create a new CV right now.'),
              ),
            );
          }
        }
        return;
      case 3:
        context.go('/premium');
        return;
      case 4:
        context.go('/settings');
        return;
      default:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIdx = _indexFromLocation(widget.currentLocation);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBg = isDark ? AppColors.darkSurface : AppColors.surface;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: navBg,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: context.t('nav_home'),
                  isActive: currentIdx == 0,
                  onTap: () => _onTap(context, 0),
                ),
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: context.t('nav_templates'),
                  isActive: currentIdx == 1,
                  onTap: () => _onTap(context, 1),
                ),
                // Center create button
                Expanded(
                  child: GestureDetector(
                    onTap: () => _onTap(context, 2),
                    behavior: HitTestBehavior.opaque,
                    child: Center(
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.shadowPrimary,
                        ),
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  label: context.t('nav_features'),
                  isActive: currentIdx == 3,
                  onTap: () => _onTap(context, 3),
                ),
                _NavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: context.t('nav_settings'),
                  isActive: currentIdx == 4,
                  onTap: () => _onTap(context, 4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppColors.primary : AppColors.textTertiary;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isActive ? activeIcon : icon,
                key: ValueKey(isActive),
                color: color,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HOME TAB ───────────────────────────────────────────────────────────────

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cvList = ref.watch(cvListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _HomeAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  _HeroBanner(),
                  const SizedBox(height: 28),
                  _QuickStats(cvCount: cvList.length),
                  const SizedBox(height: 28),
                  if (cvList.isNotEmpty) ...[
                    _SectionHeader(
                      title: context.t('home_my_cvs_section'),
                      subtitle: '${cvList.length} CV',
                      action: context.t('home_see_all'),
                      onAction: () {},
                    ),
                    const SizedBox(height: 14),
                    ...cvList.take(3).map((cv) => _CVListItem(cv: cv)),
                    const SizedBox(height: 28),
                  ],
                  _SectionHeader(
                    title: context.t('home_popular_templates'),
                    subtitle: '${TemplateRepository.all.length} templates',
                    action: context.t('home_see_all'),
                    onAction: () => context.go('/templates'),
                  ),
                  const SizedBox(height: 14),
                  _TemplateHorizontalList(),
                  const SizedBox(height: 32),
                  _TipsCard(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SliverAppBar(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'CVify',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      actions: [
        GestureDetector(
          onTap: () => context.go('/settings'),
          child: Container(
            width: 38,
            height: 38,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.gray100,
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: Icon(
              Icons.person_rounded,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.gray500,
            ),
          ),
        ),
      ],
    );
  }
}

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: AppColors.shadowLg,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  context.t('home_version_badge'),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.t('home_hero_title'),
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                context.t('home_hero_subtitle'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => context.push('/cv-builder'),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        context.t('home_create_cv'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: AppColors.gray900,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.gray900,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: 0.08, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }
}

class _QuickStats extends StatelessWidget {
  final int cvCount;
  const _QuickStats({required this.cvCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stats = [
      {
        'value': '$cvCount',
        'label': context.t('home_stats_cvs'),
        'icon': Icons.description_rounded,
      },
      {
        'value': '${TemplateRepository.all.length}',
        'label': context.t('home_stats_templates'),
        'icon': Icons.grid_view_rounded,
      },
      {
        'value': '∞',
        'label': context.t('home_stats_pdf'),
        'icon': Icons.picture_as_pdf_rounded,
      },
    ];

    return Row(
      children:
          stats.asMap().entries.map((e) {
            final s = e.value;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: e.key < 2 ? 10 : 0),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      s['icon'] as IconData,
                      size: 20,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      s['value'] as String,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s['label'] as String,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ).animate().fadeIn(
                delay: Duration(milliseconds: 100 + e.key * 80),
                duration: 400.ms,
              ),
            );
          }).toList(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? action;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.subtitle,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: AppColors.textTertiary),
              ),
            ],
          ),
        ),
        if (action != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class _CVListItem extends ConsumerWidget {
  final CVModel cv;
  const _CVListItem({required this.cv});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push('/cv-builder', extra: cv.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cv.title,
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cv.personalInfo.fullName.isNotEmpty
                            ? cv.personalInfo.fullName
                            : context.t('home_tap_to_edit'),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _IconBtn(
                      icon: Icons.picture_as_pdf_outlined,
                      onTap: () => context.push('/pdf-preview', extra: cv.id),
                    ),
                    const SizedBox(width: 4),
                    _IconBtn(
                      icon: Icons.edit_outlined,
                      onTap: () => context.push('/cv-builder', extra: cv.id),
                      isPrimary: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.03, end: 0);
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isPrimary;

  const _IconBtn({
    required this.icon,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primarySurface : AppColors.gray100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: isPrimary ? AppColors.primary : AppColors.gray500,
        ),
      ),
    );
  }
}

class _TemplateHorizontalList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final templates = TemplateRepository.all.take(5).toList();
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: templates.length,
        itemBuilder: (context, i) {
          final t = templates[i];
          return GestureDetector(
            onTap: () => context.go('/templates'),
            child: Container(
              width: 140,
              margin: EdgeInsets.only(right: i < templates.length - 1 ? 12 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.shadowSm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: t.colors,
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(13),
                        ),
                      ),
                      child: _MiniCV(color: t.colors.first),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(13),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.name,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(fontSize: 12),
                        ),
                        Text(
                          t.description,
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(
                            color: AppColors.textTertiary,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(
              delay: Duration(milliseconds: i * 80),
              duration: 400.ms,
            ),
          );
        },
      ),
    );
  }
}

class _MiniCV extends StatelessWidget {
  final Color color;
  const _MiniCV({required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 90,
        height: 115,
        margin: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withValues(alpha: 0.15),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 3,
                          color: color,
                          width: double.infinity,
                        ),
                        const SizedBox(height: 2),
                        Container(
                          height: 2,
                          color: Colors.grey[200],
                          width: 40,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(height: 1, color: Colors.grey[100]),
              const SizedBox(height: 5),
              ...List.generate(
                4,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    height: 2.5,
                    width: double.infinity,
                    color: Colors.grey[200],
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 2,
                color: color.withValues(alpha: 0.5),
                width: 30,
              ),
              const SizedBox(height: 4),
              ...List.generate(
                3,
                (_) => Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Container(
                    height: 2.5,
                    width: double.infinity,
                    color: Colors.grey[200],
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

class _TipsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tips = [
      (context.t('home_tip_ats'), Icons.search_rounded),
      (context.t('home_tip_quantify'), Icons.trending_up_rounded),
      (context.t('home_tip_adapt'), Icons.tune_rounded),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_rounded,
                size: 18,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Text(
                context.t('home_pro_tips'),
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(tip.$2, size: 14, color: AppColors.primary),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      tip.$1,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.gray700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 500.ms);
  }
}
