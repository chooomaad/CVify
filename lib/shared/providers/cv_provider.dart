import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/app_logger.dart';
import '../models/cv_model.dart';

class CVListNotifier extends StateNotifier<List<CVModel>> {
  CVListNotifier() : super([]) {
    _loadCVs();
  }

  static const _key = 'cv_list';
  final _uuid = const Uuid();

  Future<void> _loadCVs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw == null || raw.trim().isEmpty) {
        state = [];
        return;
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        throw const FormatException('Stored CV payload is not a JSON list.');
      }

      state =
          decoded
              .whereType<Map>()
              .map(
                (entry) => CVModel.fromJson(Map<String, dynamic>.from(entry)),
              )
              .toList();
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to load saved CVs. Resetting local CV cache.',
        error: error,
        stackTrace: stackTrace,
      );
      state = [];
      await _clearPersistedState();
    }
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _key,
        jsonEncode(state.map((e) => e.toJson()).toList()),
      );
    } catch (error, stackTrace) {
      AppLogger.error('Failed to persist CV list', error, stackTrace);
    }
  }

  Future<void> _clearPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    } catch (error, stackTrace) {
      AppLogger.warning(
        'Failed to clear corrupted CV cache.',
        error: error,
        stackTrace: stackTrace,
      );
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
  return CVListNotifier();
});

final currentCVProvider = StateProvider<CVModel?>((ref) => null);
