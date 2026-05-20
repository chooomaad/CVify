import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_logger.dart';

class AppProviderObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    AppLogger.error(
      'Provider failure in ${provider.name ?? provider.runtimeType}',
      error,
      stackTrace,
    );
  }
}
