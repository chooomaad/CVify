import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/l10n/translations.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_logger.dart';
import '../shared/providers/app_state_provider.dart';

class CVifyApp extends ConsumerWidget {
  final List<String> startupWarnings;

  const CVifyApp({super.key, this.startupWarnings = const []});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final router = ref.watch(routerProvider);
      final themeMode = ref.watch(themeModeProvider);
      final langCode = ref.watch(langCodeProvider);

      if (startupWarnings.isNotEmpty) {
        AppLogger.warning(
          'Startup completed with warnings: ${startupWarnings.join(' | ')}',
        );
      }

      return TranslationsProvider(
        child: MaterialApp.router(
          title: 'CVify',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
          locale: langCode == 'en' ? const Locale('en') : const Locale('fr'),
          supportedLocales: const [Locale('fr'), Locale('en')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        ),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to build the root application shell', error, stackTrace);
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.error_outline_rounded, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'CVify a rencontré une erreur lors du chargement de l’interface.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }
}
