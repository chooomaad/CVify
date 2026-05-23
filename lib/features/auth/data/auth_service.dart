import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/utils/app_logger.dart';

class AuthException implements Exception {
  final String message;
  final String? code;
  AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

class AuthService {
  SupabaseClient get _client => Supabase.instance.client;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;
  Session? get currentSession => _client.auth.currentSession;
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // ─── Inscription ─────────────────────────────────────────────────────────

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    String? fullName,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email.trim(),
        password: password,
        data: fullName != null && fullName.trim().isNotEmpty
            ? {'full_name': fullName.trim()}
            : null,
        emailRedirectTo: SupabaseConfig.authRedirectUrl,
      );
      AppLogger.info('Inscription réussie: ${email.trim()}');
      return response;
    } on AuthException catch (e) {
      AppLogger.warning('Échec inscription: ${e.message}');
      throw _mapAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erreur inscription', e, st);
      throw AuthException('Une erreur réseau est survenue. Vérifiez votre connexion.');
    }
  }

  // ─── Connexion ───────────────────────────────────────────────────────────

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );
      AppLogger.info('Connexion réussie: ${email.trim()}');
      return response;
    } on AuthException catch (e) {
      AppLogger.warning('Échec connexion: ${e.message}');
      throw _mapAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erreur connexion', e, st);
      throw AuthException('Une erreur réseau est survenue. Vérifiez votre connexion.');
    }
  }

  // ─── Déconnexion ─────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      AppLogger.info('Déconnexion réussie');
    } catch (e, st) {
      AppLogger.error('Erreur déconnexion', e, st);
    }
  }

  // ─── Réinitialisation mot de passe ───────────────────────────────────────

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim(),
        redirectTo: SupabaseConfig.passwordResetUrl,
      );
      AppLogger.info('Email reset envoyé: ${email.trim()}');
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erreur reset password', e, st);
      throw AuthException('Une erreur réseau est survenue. Vérifiez votre connexion.');
    }
  }

  // ─── Mise à jour du mot de passe ─────────────────────────────────────────

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      AppLogger.info('Mot de passe mis à jour');
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e, st) {
      AppLogger.error('Erreur update password', e, st);
      throw AuthException('Impossible de mettre à jour le mot de passe.');
    }
  }

  // ─── Suppression du compte ───────────────────────────────────────────────

  Future<void> deleteAccount() async {
    final user = currentUser;
    if (user == null) throw AuthException('Aucun utilisateur connecté.');

    try {
      // Supprimer les données du profil (cascade supprime l'auth via FK)
      await _client.from(SupabaseConfig.profilesTable).delete().eq('id', user.id);
      await _client.auth.signOut();
      AppLogger.info('Compte supprimé: ${user.id}');
    } catch (e, st) {
      AppLogger.error('Erreur suppression compte', e, st);
      throw AuthException('Impossible de supprimer le compte. Réessayez.');
    }
  }

  // ─── Mapping des erreurs Supabase ────────────────────────────────────────

  AuthException _mapAuthException(AuthException e) {
    final msg = e.message.toLowerCase();

    if (msg.contains('invalid login credentials') ||
        msg.contains('invalid credentials')) {
      return AuthException('Email ou mot de passe incorrect.');
    }
    if (msg.contains('email not confirmed')) {
      return AuthException(
        'Veuillez confirmer votre adresse email avant de vous connecter.',
        code: 'email_not_confirmed',
      );
    }
    if (msg.contains('user already registered') ||
        msg.contains('already been registered')) {
      return AuthException('Un compte existe déjà avec cet email.');
    }
    if (msg.contains('password should be at least')) {
      return AuthException('Le mot de passe doit contenir au moins 6 caractères.');
    }
    if (msg.contains('rate limit')) {
      return AuthException('Trop de tentatives. Veuillez patienter quelques minutes.');
    }
    if (msg.contains('network') || msg.contains('connection')) {
      return AuthException('Erreur de connexion réseau. Vérifiez votre internet.');
    }
    return AuthException(e.message);
  }
}
