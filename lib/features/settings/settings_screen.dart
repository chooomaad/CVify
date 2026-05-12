import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/translations.dart';
import '../../core/theme/app_colors.dart';
import '../../shared/providers/app_state_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appStateProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                  context.t('settings_title'),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Text(
                  'CVify v1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Appearance ──────────────────────────
                  _SectionHeader(
                    context.t('settings_appearance'),
                  ).animate().fadeIn(duration: 300.ms),

                  _SettingsGroup(
                    isDark: isDark,
                    children: [
                      // Dark mode
                      _SettingsTile(
                        icon: Icons.dark_mode_rounded,
                        label: context.t('settings_dark_mode'),
                        trailing: Switch(
                          value: appState.isDarkMode,
                          onChanged:
                              (_) =>
                                  ref
                                      .read(appStateProvider.notifier)
                                      .toggleDarkMode(),
                          activeColor: AppColors.primary,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        onTap:
                            () =>
                                ref
                                    .read(appStateProvider.notifier)
                                    .toggleDarkMode(),
                      ),

                      // Language
                      _SettingsTile(
                        icon: Icons.language_rounded,
                        label: context.t('settings_language'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              context.t('lang_${appState.langCode}'),
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.textTertiary),
                            ),
                            const SizedBox(width: 4),
                            const Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: AppColors.textTertiary,
                            ),
                          ],
                        ),
                        onTap:
                            () => _showLangPicker(
                              context,
                              ref,
                              appState.langCode,
                            ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: 24),

                  // ── Legal ────────────────────────────────
                  _SectionHeader(
                    context.t('settings_legal'),
                  ).animate().fadeIn(delay: 200.ms),

                  _SettingsGroup(
                    isDark: isDark,
                    children: [
                      _SettingsTile(
                        icon: Icons.privacy_tip_outlined,
                        label: context.t('settings_privacy'),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onTap:
                            () => _showInfoSheet(
                              context,
                              title: context.t('settings_privacy'),
                              body: _privacyText(
                                context.t('lang_${appState.langCode}'),
                              ),
                            ),
                      ),
                      _SettingsTile(
                        icon: Icons.gavel_rounded,
                        label: context.t('settings_terms'),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onTap:
                            () => _showInfoSheet(
                              context,
                              title: context.t('settings_terms'),
                              body: _termsText(
                                context.t('lang_${appState.langCode}'),
                              ),
                            ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 24),

                  // ── About & Support ──────────────────────
                  _SectionHeader(
                    context.t('settings_about'),
                  ).animate().fadeIn(delay: 400.ms),

                  _SettingsGroup(
                    isDark: isDark,
                    children: [
                      _SettingsTile(
                        icon: Icons.info_outline_rounded,
                        label: context.t('settings_about_app'),
                        trailing: const Icon(
                          Icons.chevron_right_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        onTap: () => _showAboutSheet(context),
                      ),
                      _SettingsTile(
                        icon: Icons.mail_outline_rounded,
                        label: context.t('settings_contact'),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onTap: () {},
                      ),
                      _SettingsTile(
                        icon: Icons.star_outline_rounded,
                        label: context.t('settings_rate'),
                        trailing: const Icon(
                          Icons.open_in_new_rounded,
                          size: 16,
                          color: AppColors.textTertiary,
                        ),
                        onTap: () {},
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 32),

                  // Version footer
                  Center(
                    child: Column(
                      children: [
                        Text(
                          '${context.t('settings_version')} 1.0.0',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          context.t('about_made_with'),
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 600.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Language picker ──────────────────────────────────────────────────────
  void _showLangPicker(BuildContext context, WidgetRef ref, String current) {
    final langs = [
      ('fr', '🇫🇷', context.t('lang_fr')),
      ('en', '🇬🇧', context.t('lang_en')),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.t('lang_picker_title'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                ...langs.map((lang) {
                  final isSelected = current == lang.$1;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Text(
                      lang.$2,
                      style: const TextStyle(fontSize: 24),
                    ),
                    title: Text(
                      lang.$3,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w400,
                      ),
                    ),
                    trailing:
                        isSelected
                            ? Container(
                              width: 24,
                              height: 24,
                              decoration: const BoxDecoration(
                                color: AppColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 14,
                              ),
                            )
                            : null,
                    onTap: () {
                      ref.read(appStateProvider.notifier).setLang(lang.$1);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
    );
  }

  // ── About sheet ──────────────────────────────────────────────────────────
  void _showAboutSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (_) => Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 48),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.description_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'CVify',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    context.t('about_description'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  context.t('about_made_with'),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
    );
  }

  // ── Info sheet (privacy / terms) ─────────────────────────────────────────
  void _showInfoSheet(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder:
          (_) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.95,
            minChildSize: 0.4,
            builder:
                (ctx, ctrl) => Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(28),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
                  child: Column(
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.border,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: SingleChildScrollView(
                          controller: ctrl,
                          child: Text(
                            body,
                            style: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondary,
                              height: 1.7,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
          ),
    );
  }

  static String _privacyText(String lang) =>
      lang == 'English'
          ? 'CVify does not collect any personal data. All your resumes are stored locally on your device. We do not have access to your information and do not share it with third parties.\n\nYour data belongs to you. You can delete it at any time by uninstalling the application.\n\nThis application does not use analytics, trackers, or advertising.'
          : 'CVify ne collecte aucune donnée personnelle. Tous vos CV sont stockés localement sur votre appareil. Nous n\'avons pas accès à vos informations et ne les partageons avec aucun tiers.\n\nVos données vous appartiennent. Vous pouvez les supprimer à tout moment en désinstallant l\'application.\n\nCette application n\'utilise aucun analytics, traceur ou publicité.';

  static String _termsText(String lang) =>
      lang == 'English'
          ? 'By using CVify, you agree to use this application solely for creating professional resumes for personal or professional use.\n\nCVify is provided free of charge. We reserve the right to update the application at any time.\n\nThe application is provided "as is" without any warranty of any kind.'
          : 'En utilisant CVify, vous acceptez d\'utiliser cette application uniquement pour créer des CVs professionnels à des fins personnelles ou professionnelles.\n\nCVify est fourni gratuitement. Nous nous réservons le droit de mettre à jour l\'application à tout moment.\n\nL\'application est fournie "telle quelle" sans aucune garantie d\'aucune sorte.';
}

// ── Shared widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.5,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  const _SettingsGroup({required this.children, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
        boxShadow: isDark ? null : AppColors.shadowSm,
      ),
      child: Column(
        children:
            children.asMap().entries.map((e) {
              return Column(
                children: [
                  e.value,
                  if (e.key < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: AppColors.gray100,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(icon, color: AppColors.textSecondary, size: 18),
      ),
      title: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
