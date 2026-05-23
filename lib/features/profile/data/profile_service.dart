import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/utils/app_logger.dart';
import '../models/user_profile.dart';

class ProfileService {
  SupabaseClient get _client => Supabase.instance.client;

  // ─── Récupérer le profil ─────────────────────────────────────────────────

  Future<UserProfile?> getProfile(String userId) async {
    try {
      final data = await _client
          .from(SupabaseConfig.profilesTable)
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (data == null) return null;
      return UserProfile.fromJson(data);
    } catch (e, st) {
      AppLogger.error('Erreur getProfile', e, st);
      return null;
    }
  }

  // ─── Créer ou récupérer le profil ────────────────────────────────────────

  Future<UserProfile> getOrCreateProfile({
    required String userId,
    required String email,
    String? fullName,
  }) async {
    final existing = await getProfile(userId);
    if (existing != null) return existing;

    try {
      final data = await _client
          .from(SupabaseConfig.profilesTable)
          .insert({
            'id': userId,
            'email': email,
            'full_name': fullName,
          })
          .select()
          .single();

      AppLogger.info('Profil créé pour $userId');
      return UserProfile.fromJson(data);
    } catch (e, st) {
      AppLogger.error('Erreur createProfile', e, st);
      // Retourner un profil local minimal si la création échoue
      return UserProfile(
        id: userId,
        email: email,
        fullName: fullName,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  // ─── Mettre à jour le profil ─────────────────────────────────────────────

  Future<UserProfile> updateProfile({
    required String userId,
    String? fullName,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fullName != null) updates['full_name'] = fullName.trim();
    if (phone != null) updates['phone'] = phone.trim().isEmpty ? null : phone.trim();
    if (bio != null) updates['bio'] = bio.trim().isEmpty ? null : bio.trim();
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

    try {
      final data = await _client
          .from(SupabaseConfig.profilesTable)
          .update(updates)
          .eq('id', userId)
          .select()
          .single();

      AppLogger.info('Profil mis à jour pour $userId');
      return UserProfile.fromJson(data);
    } catch (e, st) {
      AppLogger.error('Erreur updateProfile', e, st);
      rethrow;
    }
  }

  // ─── Upload de l'avatar ──────────────────────────────────────────────────

  Future<String> uploadAvatar({
    required String userId,
    required String filePath,
  }) async {
    try {
      final file = File(filePath);
      final ext = filePath.split('.').last.toLowerCase();
      final storagePath = '$userId/avatar.$ext';

      await _client.storage
          .from(SupabaseConfig.avatarsBucket)
          .upload(
            storagePath,
            file,
            fileOptions: const FileOptions(upsert: true),
          );

      final publicUrl = _client.storage
          .from(SupabaseConfig.avatarsBucket)
          .getPublicUrl(storagePath);

      // Ajouter un timestamp pour forcer le rechargement du cache
      final urlWithCache = '$publicUrl?t=${DateTime.now().millisecondsSinceEpoch}';

      AppLogger.info('Avatar uploadé: $urlWithCache');
      return urlWithCache;
    } catch (e, st) {
      AppLogger.error('Erreur uploadAvatar', e, st);
      rethrow;
    }
  }

  // ─── Supprimer l'avatar ──────────────────────────────────────────────────

  Future<void> deleteAvatar(String userId) async {
    try {
      final files = await _client.storage
          .from(SupabaseConfig.avatarsBucket)
          .list(path: userId);

      if (files.isNotEmpty) {
        final paths = files.map((f) => '$userId/${f.name}').toList();
        await _client.storage
            .from(SupabaseConfig.avatarsBucket)
            .remove(paths);
      }

      await _client
          .from(SupabaseConfig.profilesTable)
          .update({'avatar_url': null, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', userId);
    } catch (e, st) {
      AppLogger.error('Erreur deleteAvatar', e, st);
    }
  }
}
