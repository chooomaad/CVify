import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

class AppBootstrapResult {
  final SharedPreferences? sharedPreferences;
  final List<String> warnings;

  const AppBootstrapResult({
    required this.sharedPreferences,
    required this.warnings,
  });
}

class AppBootstrap {
  AppBootstrap._();

  static Future<AppBootstrapResult> initialize() async {
    final warnings = <String>[];
    SharedPreferences? sharedPreferences;

    try {
      sharedPreferences = await SharedPreferences.getInstance();
      AppLogger.info('SharedPreferences initialized for startup bootstrap.');
    } catch (error, stackTrace) {
      warnings.add('SharedPreferences unavailable during startup.');
      AppLogger.error(
        'Failed to initialize SharedPreferences during startup',
        error,
        stackTrace,
      );
    }

    try {
      final manifest = await rootBundle.loadString('AssetManifest.json');
      if (manifest.trim().isEmpty) {
        warnings.add('Asset manifest is empty.');
        AppLogger.warning('Asset manifest was loaded but is empty.');
      } else {
        AppLogger.info('Asset manifest loaded successfully.');
      }
    } catch (error, stackTrace) {
      warnings.add('Asset manifest could not be loaded.');
      AppLogger.error('Failed to load asset manifest', error, stackTrace);
    }

    try {
      final fontManifest = await rootBundle.loadString('FontManifest.json');
      if (fontManifest.trim().isEmpty) {
        warnings.add('Font manifest is empty.');
        AppLogger.warning('Font manifest was loaded but is empty.');
      } else {
        AppLogger.info('Font manifest loaded successfully.');
      }
    } catch (error, stackTrace) {
      warnings.add('Font manifest could not be loaded.');
      AppLogger.error('Failed to load font manifest', error, stackTrace);
    }

    try {
      await rootBundle.load('assets/images/logo.png');
      AppLogger.info('Startup logo asset loaded successfully.');
    } catch (error, stackTrace) {
      warnings.add('The startup logo asset is missing or unreadable.');
      AppLogger.error('Failed to load startup logo asset', error, stackTrace);
    }

    return AppBootstrapResult(
      sharedPreferences: sharedPreferences,
      warnings: warnings,
    );
  }
}
