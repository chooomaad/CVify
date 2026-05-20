import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'app/app.dart';
import 'core/utils/app_logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppLogger.startup('main() — offline-safe cold start.');

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FlutterError',
      details.exception,
      details.stack ?? StackTrace.current,
    );
  };

  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformDispatcher error', error, stack);
    return true;
  };

  runZonedGuarded(() async {
    runApp(const MyApp());
  }, (error, stack) {
    AppLogger.error('runZonedGuarded uncaught', error, stack);
  });
}
