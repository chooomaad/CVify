import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/bootstrap/asset_guard.dart';
import '../core/bootstrap/plugin_guard.dart';
import '../core/config/startup_policy.dart';
import '../core/l10n/translations.dart';
import '../core/router/app_router.dart';
import '../core/theme/app_theme.dart';
import '../core/utils/app_logger.dart';
import '../core/utils/app_provider_observer.dart';
import '../features/splash/splash_screen.dart';
import '../shared/providers/app_state_provider.dart';
import '../shared/providers/shared_preferences_provider.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  SharedPreferences? _sharedPreferences;
  List<String> _startupWarnings = const [];
  bool _startupComplete = false;

  @override
  void initState() {
    super.initState();
    ErrorWidget.builder = (details) {
      AppLogger.error(
        'ErrorWidget rendered',
        details.exception,
        details.stack ?? StackTrace.current,
      );
      return Material(
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.error_outline_rounded, size: 48),
                  SizedBox(height: 16),
                  Text(
                    'CVify a rencontre une erreur, mais l application reste ouverte.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };
    _initializeStartup();
  }

  void _scheduleHeavyAnimations() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(const Duration(milliseconds: 600), () {
        StartupPolicy.enableHeavyAnimations();
        AppLogger.startup('Heavy launch animations enabled.');
      });
    });
  }

  Future<void> _initializeStartup() async {
    AppLogger.startup('Cold start bootstrap begin.');
    final warnings = <String>[];
    SharedPreferences? sharedPreferences;

    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);
      SystemChrome.setSystemUIOverlayStyle(
        const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      );
      AppLogger.startup('System UI configured.');
    } catch (error, stackTrace) {
      warnings.add('System UI configuration failed.');
      AppLogger.warning(
        'Failed to configure system UI during startup.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    try {
      sharedPreferences = await SharedPreferences.getInstance().timeout(
        const Duration(seconds: 4),
      );
      AppLogger.startup('SharedPreferences ready.');
    } on TimeoutException catch (error, stackTrace) {
      warnings.add('SharedPreferences startup timed out.');
      AppLogger.warning(
        'SharedPreferences timed out during startup.',
        error: error,
        stackTrace: stackTrace,
      );
    } catch (error, stackTrace) {
      warnings.add('SharedPreferences startup failed.');
      AppLogger.warning(
        'SharedPreferences failed during startup.',
        error: error,
        stackTrace: stackTrace,
      );
    }

    warnings.addAll(await AssetGuard.verifyRequiredAssets());
    warnings.addAll(await PluginGuard.verifyStartupPlugins());

    if (!mounted) return;

    setState(() {
      _sharedPreferences = sharedPreferences;
      _startupWarnings = warnings;
      _startupComplete = true;
    });

    AppLogger.startup(
      'Cold start bootstrap complete. warnings=${warnings.length}',
    );
    _scheduleHeavyAnimations();
  }

  @override
  Widget build(BuildContext context) {
    if (!_startupComplete) {
      return const _StartupLoadingApp();
    }

    return ProviderScope(
      observers: [AppProviderObserver()],
      overrides: [
        sharedPreferencesProvider.overrideWithValue(_sharedPreferences),
      ],
      child: CVifyApp(startupWarnings: _startupWarnings),
    );
  }
}

class _StartupLoadingApp extends StatelessWidget {
  const _StartupLoadingApp();

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScaffold(),
    );
  }
}

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

      AppLogger.startup(
        'Root shell build: theme=$themeMode lang=$langCode onboarded=${ref.read(appStateProvider).isOnboarded}',
      );

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
      AppLogger.error(
        'Failed to build the root application shell',
        error,
        stackTrace,
      );
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: _StartupFailureScreen(),
      );
    }
  }
}

class _StartupFailureScreen extends StatelessWidget {
  const _StartupFailureScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'CVify a rencontre une erreur lors du chargement de l interface.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
