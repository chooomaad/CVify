import 'package:flutter/services.dart';

import '../utils/app_logger.dart';

/// Verifies bundled assets exist before the UI depends on them.
class AssetGuard {
  AssetGuard._();

  static const requiredAssets = <String>[
    'assets/images/logo.png',
    'AssetManifest.json',
    'FontManifest.json',
  ];

  static Future<List<String>> verifyRequiredAssets() async {
    final warnings = <String>[];

    for (final path in requiredAssets) {
      try {
        if (path.endsWith('.json')) {
          final content = await rootBundle.loadString(path);
          if (content.trim().isEmpty) {
            warnings.add('$path is empty.');
            AppLogger.warning('Asset guard: $path is empty.');
          } else {
            AppLogger.info('Asset guard: $path loaded.');
          }
        } else {
          await rootBundle.load(path);
          AppLogger.info('Asset guard: $path loaded.');
        }
      } catch (error, stackTrace) {
        warnings.add('Missing or unreadable asset: $path');
        AppLogger.warning(
          'Asset guard failed for $path',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }

    return warnings;
  }
}
