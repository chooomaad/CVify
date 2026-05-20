import 'package:flutter/material.dart';

import '../../core/utils/app_logger.dart';

/// Asset image that never throws on missing files (iOS Release safe).
class SafeAssetImage extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Color? color;
  final Widget? placeholder;

  const SafeAssetImage(
    this.assetPath, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.color,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      width: width,
      height: height,
      fit: fit,
      color: color,
      errorBuilder: (context, error, stackTrace) {
        AppLogger.warning(
          'Failed to load asset: $assetPath',
          error: error,
          stackTrace: stackTrace,
        );
        return placeholder ?? const SizedBox.shrink();
      },
    );
  }
}

/// Network image with the same safe fallback.
class SafeNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;

  const SafeNetworkImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (context, error, stackTrace) {
        AppLogger.warning(
          'Failed to load network image: $url',
          error: error,
          stackTrace: stackTrace,
        );
        return const SizedBox.shrink();
      },
    );
  }
}
