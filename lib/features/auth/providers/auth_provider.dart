import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/auth_service.dart';

// ─── Service ─────────────────────────────────────────────────────────────────

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ─── Stream d'état auth (connexion / déconnexion) ────────────────────────────

final authStateStreamProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

// ─── Utilisateur courant ─────────────────────────────────────────────────────

final currentUserProvider = Provider<User?>((ref) {
  final auth = ref.watch(authStateStreamProvider);
  return auth.when(
    data: (state) => state.session?.user,
    loading: () => Supabase.instance.client.auth.currentUser,
    error: (_, __) => null,
  );
});

// ─── Statut authentifié ──────────────────────────────────────────────────────

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// ─── État du chargement auth ─────────────────────────────────────────────────

final authLoadingProvider = StateProvider<bool>((ref) => false);

// ─── Message d'erreur auth ───────────────────────────────────────────────────

final authErrorProvider = StateProvider<String?>((ref) => null);
