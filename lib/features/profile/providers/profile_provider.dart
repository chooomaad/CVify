import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../data/profile_service.dart';
import '../models/user_profile.dart';

// ─── Service ─────────────────────────────────────────────────────────────────

final profileServiceProvider = Provider<ProfileService>((ref) => ProfileService());

// ─── Notifier principal ───────────────────────────────────────────────────────

class ProfileNotifier extends AutoDisposeAsyncNotifier<UserProfile?> {
  ProfileService get _service => ref.read(profileServiceProvider);

  @override
  Future<UserProfile?> build() async {
    final user = ref.watch(currentUserProvider);
    if (user == null) return null;

    return _service.getOrCreateProfile(
      userId: user.id,
      email: user.email ?? '',
      fullName: user.userMetadata?['full_name'] as String?,
    );
  }

  Future<void> saveProfile({
    String? fullName,
    String? phone,
    String? bio,
    String? avatarUrl,
  }) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => _service.updateProfile(
        userId: user.id,
        fullName: fullName,
        phone: phone,
        bio: bio,
        avatarUrl: avatarUrl,
      ),
    );
  }

  Future<String?> uploadAvatar(String filePath) async {
    final user = ref.read(currentUserProvider);
    if (user == null) return null;

    try {
      final url = await _service.uploadAvatar(
        userId: user.id,
        filePath: filePath,
      );
      await saveProfile(avatarUrl: url);
      return url;
    } catch (_) {
      return null;
    }
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
    await future;
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider.autoDispose<ProfileNotifier, UserProfile?>(
  ProfileNotifier.new,
);
