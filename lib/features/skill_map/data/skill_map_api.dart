import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/skill_map_model.dart';

class SkillMapApi {
  final Dio _dio;
  SkillMapApi(this._dio);

  Future<List<SkillMapEntry>> getSkillMap() async {
    final res = await _dio.get(ApiEndpoints.skillMap);
    final list = res.data['data'] as List? ?? [];
    return list.map((e) {
      final m = Map<String, dynamic>.from(e as Map<String, dynamic>);
      m['id'] ??= m['_id'];
      m['mastery'] ??= m['masteryScore'] ?? 0;
      return SkillMapEntry.fromJson(m);
    }).toList();
  }

  Future<SkillMapEntry> getSkillDetail(String skillId) async {
    final res = await _dio.get(ApiEndpoints.skillMapDetail(skillId));
    final m = Map<String, dynamic>.from(res.data['data'] as Map<String, dynamic>);
    m['id'] ??= m['_id'];
    m['mastery'] ??= m['masteryScore'] ?? 0;
    return SkillMapEntry.fromJson(m);
  }
}

final skillMapApiProvider = Provider<SkillMapApi>(
  (ref) => SkillMapApi(ref.watch(dioProvider)),
);
