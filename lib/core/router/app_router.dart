import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_logger.dart';
import '../../features/cv_builder/presentation/cv_builder_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/pdf_export/pdf_preview_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/templates/templates_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    errorBuilder: (context, state) {
      final error = state.error;
      if (error != null) {
        AppLogger.error(
          'Router error while opening ${state.uri}',
          error,
          StackTrace.current,
        );
      }

      return _RouteErrorScreen(location: state.uri.toString());
    },
    routes: [
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      ShellRoute(
        builder:
            (context, state, child) => HomeScreen(
              child: child,
              currentLocation: state.matchedLocation,
            ),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeTab(),
          ),
          GoRoute(
            path: '/templates',
            name: 'templates',
            builder: (context, state) => const TemplatesScreen(),
          ),
          GoRoute(
            path: '/premium',
            name: 'premium',
            builder: (context, state) => const PremiumScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/cv-builder',
        name: 'cv-builder',
        builder: (context, state) {
          return CVBuilderScreen(cvId: _readCvId(state.extra));
        },
      ),
      GoRoute(
        path: '/pdf-preview',
        name: 'pdf-preview',
        builder: (context, state) {
          final cvId = _readCvId(state.extra) ?? '';
          return PDFPreviewScreen(cvId: cvId);
        },
      ),
    ],
    redirect: (_, __) => null,
  );
});

String? _readCvId(Object? extra) {
  if (extra == null) {
    return null;
  }

  if (extra is String && extra.trim().isNotEmpty) {
    return extra;
  }

  AppLogger.warning('Ignoring route extra because it is not a valid CV id.');
  return null;
}

class _RouteErrorScreen extends StatelessWidget {
  final String location;

  const _RouteErrorScreen({required this.location});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  'Something went wrong while opening this screen.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(location, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
