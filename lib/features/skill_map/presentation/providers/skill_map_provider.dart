import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/skill_map_api.dart';
import '../../models/skill_map_model.dart';

const _cacheKey = 'skill_map_cache';

class SkillMapNotifier extends AsyncNotifier<List<SkillMapEntry>> {
  @override
  Future<List<SkillMapEntry>> build() async {
    // Auto-sync when connectivity is restored
    final sub = Connectivity().onConnectivityChanged.listen((results) {
      if (results.any((r) => r != ConnectivityResult.none)) refresh();
    });
    ref.onDispose(sub.cancel);
    return _loadWithCache();
  }

  Future<List<SkillMapEntry>> _loadWithCache() async {
    try {
      final entries = await ref.read(skillMapApiProvider).getSkillMap();
      await _saveCache(entries);
      return entries;
    } catch (_) {
      final cached = await _readCache();
      return cached;
    }
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_loadWithCache);
  }

  Future<void> _saveCache(List<SkillMapEntry> entries) async {
    final prefs = await SharedPreferences.getInstance();
    final json = entries.map((e) => e.toJson()).toList();
    await prefs.setString(_cacheKey, jsonEncode(json));
  }

  Future<List<SkillMapEntry>> _readCache() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_cacheKey);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List;
    return list
        .map((e) => SkillMapEntry.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final skillMapProvider =
    AsyncNotifierProvider<SkillMapNotifier, List<SkillMapEntry>>(
  SkillMapNotifier.new,
);
