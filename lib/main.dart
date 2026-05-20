import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'core/utils/app_logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'Unhandled Flutter framework error',
      details.exception,
      details.stack ?? StackTrace.current,
    );
    FlutterError.presentError(details);
  };

  PlatformDispatcher.instance.onError = (error, stackTrace) {
    AppLogger.error('Unhandled platform error', error, stackTrace);
    return true;
  };

  await runZonedGuarded(
    () async {
      await _configureAppChrome();
      runApp(const ProviderScope(child: CVifyApp()));
    },
    (error, stackTrace) {
      AppLogger.error('Unhandled zone error', error, stackTrace);
    },
  );
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
