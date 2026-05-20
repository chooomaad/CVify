import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_logger.dart';
import '../models/cv_model.dart';
import 'shared_preferences_provider.dart';

class CVListNotifier extends StateNotifier<List<CVModel>> {
  CVListNotifier(this._prefs) : super(_restoreCVs(_prefs));

  static const _key = 'cv_list';
  final _uuid = const Uuid();
  final SharedPreferences? _prefs;

  static List<CVModel> _restoreCVs(SharedPreferences? prefs) {
    if (prefs == null) {
      AppLogger.warning(
        'SharedPreferences unavailable during CV bootstrap. Starting with an empty list.',
      );
      return [];
    }

    try {
      final raw = prefs.getString(_key);
      if (raw == null || raw.trim().isEmpty) {
        return [];
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Stored CV payload is not a JSON list.');
      }

      return decoded
          .whereType<Map>()
          .map((entry) => CVModel.fromJson(Map<String, dynamic>.from(entry)))
          .toList();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to restore saved CVs. Resetting local CV cache.',
        error: error,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<SharedPreferences?> _resolvePrefs() async {
    if (_prefs != null) {
      return _prefs;
    }

    try {
      return await SharedPreferences.getInstance();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'SharedPreferences could not be reopened for CV persistence.',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await _resolvePrefs();
      await prefs?.setString(
        _key,
        jsonEncode(state.map((e) => e.toJson()).toList()),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to persist CV list', error, stackTrace);
    }
  }

  Future<CVModel> create({String? templateId}) async {
    final cv = CVModel(
      id: _uuid.v4(),
      title: 'Mon CV',
      templateId: templateId ?? 'modern',
    );
    state = [cv, ...state];
    await _save();
    return cv;
  }

  Future<void> update(CVModel cv) async {
    final updated = cv.copyWith(updatedAt: DateTime.now());
    state = state.map((e) => e.id == cv.id ? updated : e).toList();
    await _save();
  }

  Future<void> delete(String id) async {
    state = state.where((e) => e.id != id).toList();
    await _save();
  }

  CVModel? getById(String id) {
    try {
      return state.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }
}

final cvListProvider = StateNotifierProvider<CVListNotifier, List<CVModel>>((
  ref,
) {
  return CVListNotifier(ref.watch(sharedPreferencesProvider));
});

final currentCVProvider = StateProvider<CVModel?>((ref) => null);
