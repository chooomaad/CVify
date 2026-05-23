import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/app_logger.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/cv_builder/presentation/cv_builder_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/onboarding/onboarding_screen.dart';
import '../../features/pdf_export/pdf_preview_screen.dart';
import '../../features/premium/premium_screen.dart';
import '../../features/profile/presentation/edit_profile_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/templates/templates_screen.dart';
import '../../shared/providers/app_state_provider.dart';

// ─── RouterNotifier — évite la recréation de GoRouter ────────────────────────

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    // Écoute les changements d'état sans recréer le routeur
    _ref.listen<AppState>(appStateProvider, (_, __) => notifyListeners());
    _ref.listen(authStateStreamProvider, (_, __) => notifyListeners());
  }

  String? redirect(BuildContext context, GoRouterState state) {
    final appState = _ref.read(appStateProvider);
    final authAsync = _ref.read(authStateStreamProvider);

    final isOnboarded = appState.isOnboarded;

    // Pendant le chargement initial de l'auth, ne pas rediriger
    final isAuthLoading = authAsync.isLoading;
    if (isAuthLoading) return null;

    final isAuthenticated = authAsync.whenOrNull(
          data: (s) => s.session != null,
        ) ??
        false;

    final uri = state.uri.path;
    const authPaths = {'/login', '/register', '/forgot-password'};
    const publicPaths = {'/splash', '/onboarding'};
    final isAuthRoute = authPaths.contains(uri);
    final isPublicRoute = publicPaths.contains(uri);

    AppLogger.router(
      'Redirect: uri=$uri onboarded=$isOnboarded authenticated=$isAuthenticated',
    );

    // 1. Onboarding obligatoire
    if (!isOnboarded && !isPublicRoute) {
      return '/onboarding';
    }

    // 2. Auth obligatoire après onboarding
    if (isOnboarded && !isAuthenticated && !isAuthRoute) {
      return '/login';
    }

    // 3. Déjà connecté → pas de route auth
    if (isOnboarded && isAuthenticated && isAuthRoute) {
      return '/home';
    }

    return null;
  }
}

// ─── Provider stable (GoRouter créé une seule fois) ──────────────────────────

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = RouterNotifier(ref);

  final router = GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: false,
    refreshListenable: notifier,
    redirect: notifier.redirect,
    observers: [_AppRouterObserver()],
    errorBuilder: (context, state) {
      final error = state.error;
      if (error != null) {
        AppLogger.error(
          'Router error: ${state.uri}',
          error,
          StackTrace.current,
        );
      }
      return _RouteErrorScreen(location: state.uri.toString());
    },
    routes: [
      // ── Routes publiques ──────────────────────────────────────────────────
      GoRoute(
        path: '/splash',
        name: 'splash',
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Routes d'authentification ─────────────────────────────────────────
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (_, __) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'register',
            name: 'register',
            builder: (_, __) => const RegisterScreen(),
          ),
        ],
      ),
      GoRoute(
        path: '/register',
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot-password',
        builder: (_, __) => const ForgotPasswordScreen(),
      ),

      // ── Routes principales (shell avec bottom nav) ────────────────────────
      ShellRoute(
        builder: (context, state, child) => HomeScreen(
          currentLocation: state.matchedLocation,
          child: child,
        ),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (_, __) => const HomeTab(),
          ),
          GoRoute(
            path: '/templates',
            name: 'templates',
            builder: (_, __) => const TemplatesScreen(),
          ),
          GoRoute(
            path: '/premium',
            name: 'premium',
            builder: (_, __) => const PremiumScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (_, __) => const SettingsScreen(),
          ),
        ],
      ),

      // ── Routes de profil ──────────────────────────────────────────────────
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (_, __) => const ProfileScreen(),
        routes: [
          GoRoute(
            path: 'edit',
            name: 'profile-edit',
            builder: (_, __) => const EditProfileScreen(),
          ),
        ],
      ),

      // ── CV builder & PDF ──────────────────────────────────────────────────
      GoRoute(
        path: '/cv-builder',
        name: 'cv-builder',
        builder: (context, state) {
          final cvId = _readCvId(state.extra);
          AppLogger.router('Building /cv-builder cvId=$cvId');
          return CVBuilderScreen(cvId: cvId);
        },
      ),
      GoRoute(
        path: '/pdf-preview',
        name: 'pdf-preview',
        builder: (context, state) {
          final cvId = _readCvId(state.extra) ?? '';
          AppLogger.router('Building /pdf-preview cvId=$cvId');
          return PDFPreviewScreen(cvId: cvId);
        },
      ),
    ],
  );

  ref.onDispose(() {
    notifier.dispose();
    router.dispose();
  });

  return router;
});

// ─── Helpers ─────────────────────────────────────────────────────────────────

String? _readCvId(Object? extra) {
  if (extra is String && extra.trim().isNotEmpty) return extra;
  return null;
}

class _AppRouterObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.navigation('PUSH ${route.settings.name} ← ${previousRoute?.settings.name}');
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    AppLogger.navigation('POP ${route.settings.name} → ${previousRoute?.settings.name}');
    super.didPop(route, previousRoute);
  }
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
                  'Page introuvable.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(location, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: () => context.go('/home'),
                  child: const Text('Retour accueil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
