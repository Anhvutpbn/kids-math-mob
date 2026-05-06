import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(ApiEndpoints.register, data: {
      'email': email,
      'password': password,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final res = await _dio.post(ApiEndpoints.login, data: {
      'email': email,
      'password': password,
    });
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMe() async {
    final res = await _dio.get(ApiEndpoints.me);
    final data = Map<String, dynamic>.from(res.data['data'] as Map<String, dynamic>);
    data['id'] ??= data['_id'];
    return data;
  }

  Future<void> completeOnboarding({
    required String childName,
    required int childAge,
    required String avatarId,
    required String language,
  }) async {
    await _dio.patch(ApiEndpoints.onboardingDone, data: {
      'childName': childName,
      'childAge': childAge,
      'avatarId': avatarId,
      'language': language,
    });
  }
}

final authApiProvider = Provider<AuthApi>(
  (ref) => AuthApi(ref.watch(dioProvider)),
);
