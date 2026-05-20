import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_logger.dart';
import 'shared_preferences_provider.dart';

class AppState {
  final bool isOnboarded;
  final bool isDarkMode;
  final String langCode; // 'fr' | 'en' | 'ar'

  const AppState({
    this.isOnboarded = false,
    this.isDarkMode = false,
    this.langCode = 'fr',
  });

  AppState copyWith({bool? isOnboarded, bool? isDarkMode, String? langCode}) {
    return AppState(
      isOnboarded: isOnboarded ?? this.isOnboarded,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      langCode: langCode ?? this.langCode,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier(this._prefs) : super(_restoreState(_prefs));

  final SharedPreferences? _prefs;

  static AppState _restoreState(SharedPreferences? prefs) {
    final fallbackLang = _detectDeviceLang();
    if (prefs == null) {
      AppLogger.provider(
        'SharedPreferences unavailable during startup. Using default app state.',
      );
      return AppState(langCode: fallbackLang);
    }

    try {
      final storedLang = prefs.getString('langCode');
      final lang = _sanitizeLang(storedLang);

      return AppState(
        isOnboarded: prefs.getBool('isOnboarded') ?? false,
        isDarkMode: prefs.getBool('isDarkMode') ?? false,
        langCode: lang,
      );
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to restore app state from SharedPreferences.',
        error: error,
        stackTrace: stackTrace,
      );
      return AppState(langCode: fallbackLang);
    }
  }

  static String _detectDeviceLang() {
    final code = ui.PlatformDispatcher.instance.locale.languageCode;
    if (code == 'en') return 'en';
    return 'fr';
  }

  static String _sanitizeLang(String? storedLang) {
    if (storedLang == 'en' || storedLang == 'fr') {
      return storedLang!;
    }

    return _detectDeviceLang();
  }

  Future<SharedPreferences?> _resolvePrefs() async {
    if (_prefs != null) {
      return _prefs;
    }

    try {
      return await SharedPreferences.getInstance();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'SharedPreferences could not be reopened after startup.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> setOnboarded() async {
    try {
      state = state.copyWith(isOnboarded: true);
      final prefs = await _resolvePrefs();
      await prefs?.setBool('isOnboarded', true);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save onboarding state', error, stackTrace);
    }
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;

    try {
      state = state.copyWith(isDarkMode: newValue);
      final prefs = await _resolvePrefs();
      await prefs?.setBool('isDarkMode', newValue);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to toggle dark mode', error, stackTrace);
    }
  }

  Future<void> setLang(String code) async {
    final sanitizedCode = _sanitizeLang(code);

    try {
      state = state.copyWith(langCode: sanitizedCode);
      final prefs = await _resolvePrefs();
      await prefs?.setString('langCode', sanitizedCode);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save language preference', error, stackTrace);
    }
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier(ref.watch(sharedPreferencesProvider));
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(appStateProvider.select((s) => s.isDarkMode));
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

final langCodeProvider = Provider<String>((ref) {
  return ref.watch(appStateProvider.select((s) => s.langCode));
});
