import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/cv_model.dart';

class CVListNotifier extends StateNotifier<List<CVModel>> {
  CVListNotifier() : super([]) {
    _loadCVs();
  }

  static const _key = 'cv_list';
  final _uuid = const Uuid();

  Future<void> _loadCVs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      state =
          list.map((e) => CVModel.fromJson(e as Map<String, dynamic>)).toList();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(state.map((e) => e.toJson()).toList()),
    );
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
