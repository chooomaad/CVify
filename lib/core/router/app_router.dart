import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/cv_builder/presentation/cv_builder_screen.dart';
import '../../features/templates/templates_screen.dart';
import '../../features/pdf_export/pdf_preview_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/settings/settings_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
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
        builder: (context, state, child) => HomeScreen(child: child),
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
          final cvId = state.extra as String?;
          return CVBuilderScreen(cvId: cvId);
        },
      ),
      GoRoute(
        path: '/pdf-preview',
        name: 'pdf-preview',
        builder: (context, state) {
          final cvId = state.extra as String? ?? '';
          return PDFPreviewScreen(cvId: cvId);
        },
      ),
    ],
    // No auth gate — splash navigates directly to /home after loading.
    // Onboarding is accessible via /onboarding but never forced.
    redirect: (context, state) {
      if (state.matchedLocation == '/splash') return null;
      return null;
    },
  );
});
