import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/app_logger.dart';

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
  AppStateNotifier() : super(const AppState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedLang = prefs.getString('langCode');
      final lang = _sanitizeLang(storedLang);

      state = state.copyWith(
        isOnboarded: prefs.getBool('isOnboarded') ?? false,
        isDarkMode: prefs.getBool('isDarkMode') ?? false,
        langCode: lang,
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to load app state', error, stackTrace);
      state = state.copyWith(langCode: _detectDeviceLang());
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

  Future<void> setOnboarded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isOnboarded', true);
      state = state.copyWith(isOnboarded: true);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save onboarding state', error, stackTrace);
    }
  }

  Future<void> toggleDarkMode() async {
    final newValue = !state.isDarkMode;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', newValue);
      state = state.copyWith(isDarkMode: newValue);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to toggle dark mode', error, stackTrace);
    }
  }

  Future<void> setLang(String code) async {
    final sanitizedCode = _sanitizeLang(code);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('langCode', sanitizedCode);
      state = state.copyWith(langCode: sanitizedCode);
    } catch (error, stackTrace) {
      AppLogger.error('Failed to save language preference', error, stackTrace);
    }
  }
}

final appStateProvider = StateNotifierProvider<AppStateNotifier, AppState>((
  ref,
) {
  return AppStateNotifier();
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final isDark = ref.watch(appStateProvider.select((s) => s.isDarkMode));
  return isDark ? ThemeMode.dark : ThemeMode.light;
});

final langCodeProvider = Provider<String>((ref) {
  return ref.watch(appStateProvider.select((s) => s.langCode));
});
