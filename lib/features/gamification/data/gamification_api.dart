import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/badge_model.dart';

class GamificationApi {
  final Dio _dio;
  GamificationApi(this._dio);

  Future<List<BadgeModel>> getAllBadges() async {
    final res = await _dio.get(ApiEndpoints.badges);
    final list = res.data['data'] as List? ?? [];
    return list.map((e) => BadgeModel.fromJson(_remapBadge(e as Map<String, dynamic>))).toList();
  }

  Future<List<BadgeModel>> getMyBadges() async {
    final res = await _dio.get(ApiEndpoints.myBadges);
    final list = res.data['data'] as List? ?? [];
    return list.map((e) => BadgeModel.fromJson(_remapBadge(e as Map<String, dynamic>))).toList();
  }

  Map<String, dynamic> _remapBadge(Map<String, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    m['id'] ??= m['_id']?.toString() ?? '';
    final code = (m['code'] ?? m['id'] ?? 'badge').toString();
    m['iconAsset'] ??= 'assets/images/badges/$code.png';
    final condType = m['conditionType']?.toString() ?? '';
    final condVal = m['conditionValue']?.toString() ?? '';
    m['condition'] ??= condType.isNotEmpty ? '$condType:$condVal' : null;
    m['descriptionVi'] ??= m['nameVi'] ?? '';
    return m;
  }
}

final gamificationApiProvider = Provider<GamificationApi>(
  (ref) => GamificationApi(ref.watch(dioProvider)),
);
