import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/placement_models.dart';

class PlacementTestApi {
  final Dio _dio;
  PlacementTestApi(this._dio);

  Future<List<PlacementQuestion>> getQuestions() async {
    final res = await _dio.get(ApiEndpoints.placementQuestions);
    final list = res.data['data'] as List;
    return list.map((e) => PlacementQuestion.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> submit(List<PlacementAnswer> answers) async {
    await _dio.post(ApiEndpoints.placementSubmit, data: {
      'answers': answers.map((a) => a.toJson()).toList(),
    });
  }
}

final placementTestApiProvider = Provider<PlacementTestApi>(
  (ref) => PlacementTestApi(ref.watch(dioProvider)),
);
