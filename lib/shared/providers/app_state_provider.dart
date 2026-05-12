import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final prefs = await SharedPreferences.getInstance();
    final storedLang = prefs.getString('langCode');
    // Migrate any previously stored 'ar' to 'fr' since Arabic is no longer supported
    final lang =
        (storedLang == 'ar' || storedLang == null)
            ? _detectDeviceLang()
            : storedLang;
    state = state.copyWith(
      isOnboarded: prefs.getBool('isOnboarded') ?? false,
      isDarkMode: prefs.getBool('isDarkMode') ?? false,
      langCode: lang,
    );
  }

  static String _detectDeviceLang() {
    final code = ui.PlatformDispatcher.instance.locale.languageCode;
    if (code == 'en') return 'en';
    return 'fr';
  }

  Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isOnboarded', true);
    state = state.copyWith(isOnboarded: true);
  }

  Future<void> toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    final newValue = !state.isDarkMode;
    await prefs.setBool('isDarkMode', newValue);
    state = state.copyWith(isDarkMode: newValue);
  }

  Future<void> setLang(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('langCode', code);
    state = state.copyWith(langCode: code);
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
