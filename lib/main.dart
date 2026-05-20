import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app/app.dart';
import 'core/bootstrap/app_bootstrap.dart';
import 'core/utils/app_logger.dart';
import 'core/utils/app_provider_observer.dart';
import 'shared/providers/shared_preferences_provider.dart';

Future<void> main() async {
  await runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      _installGlobalErrorHandlers();
      GoogleFonts.config.allowRuntimeFetching = false;

      final bootstrap = await AppBootstrap.initialize();
      await _configureAppChrome();

      runApp(
        ProviderScope(
          observers: [AppProviderObserver()],
          overrides: [
            sharedPreferencesProvider.overrideWithValue(
              bootstrap.sharedPreferences,
            ),
          ],
          child: CVifyApp(startupWarnings: bootstrap.warnings),
        ),
      );
    },
    (error, stackTrace) {
      debugPrint(error.toString());
      debugPrint(stackTrace.toString());
      AppLogger.error('Unhandled zone error', error, stackTrace);
      try {
        WidgetsFlutterBinding.ensureInitialized();
        runApp(_FatalStartupApp(message: error.toString()));
      } catch (_) {
        // If Flutter cannot mount the fallback UI, we still keep the error logs.
      }
    },
  );
}

void _installGlobalErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
    debugPrint(details.stack?.toString() ?? '');
    AppLogger.error(
      'Unhandled Flutter framework error',
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint(error.toString());
    debugPrint(stack.toString());
    AppLogger.error('Unhandled platform error', error, stack);
    return true;
  };

  ErrorWidget.builder = (details) {
    final stackTrace = details.stack ?? StackTrace.current;
    AppLogger.error(
      'Widget build failure reached ErrorWidget',
      details.exception,
      stackTrace,
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
                  'CVify a rencontré une erreur au démarrage, mais l’application est restée ouverte pour afficher les logs.',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };
}

Future<void> _configureAppChrome() async {
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
  } catch (error, stackTrace) {
    AppLogger.error('Failed to configure system UI', error, stackTrace);
  }
}

class _FatalStartupApp extends StatelessWidget {
  final String message;

  const _FatalStartupApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline_rounded, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'CVify n’a pas pu terminer son démarrage.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
