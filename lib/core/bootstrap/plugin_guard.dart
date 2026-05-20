import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_logger.dart';

/// Probes plugins used at startup so MissingPluginException surfaces in logs, not crashes.
class PluginGuard {
  PluginGuard._();

  static Future<List<String>> verifyStartupPlugins() async {
    final warnings = <String>[];

    await _probe(
      name: 'shared_preferences',
      warnings: warnings,
      probe: () async {
        await SharedPreferences.getInstance();
      },
    );

    // image_picker / path_provider are lazy — only used from CV builder UI.
    AppLogger.info(
      'Plugin guard: deferred plugins (image_picker, path_provider) verified at use-site.',
    );

    return warnings;
  }

  static Future<void> _probe({
    required String name,
    required List<String> warnings,
    required Future<void> Function() probe,
  }) async {
    try {
      await probe();
      AppLogger.info('Plugin guard: $name OK');
    } on MissingPluginException catch (error, stackTrace) {
      warnings.add('MissingPluginException: $name');
      AppLogger.error('Plugin guard: $name missing', error, stackTrace);
    } catch (error, stackTrace) {
      warnings.add('Plugin probe failed: $name');
      AppLogger.warning(
        'Plugin guard: $name probe failed',
        error: error,
        stackTrace: stackTrace,
      );
    }
  }
}
