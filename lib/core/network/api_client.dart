import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'api_endpoints.dart';

const _tokenKey = 'jwt_token';

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final dioProvider = Provider<Dio>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiEndpoints.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  );

  // Attach JWT
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        try {
          final token = await storage
              .read(key: _tokenKey)
              .timeout(const Duration(seconds: 3));
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
        } catch (_) {
          // storage read timed out or failed — proceed without token
        }
        handler.next(options);
      },
      onError: (error, handler) {
        handler.next(error);
      },
    ),
  );

  return dio;
});

// Token helpers
Future<void> saveToken(FlutterSecureStorage storage, String token) =>
    storage.write(key: _tokenKey, value: token);

Future<String?> readToken(FlutterSecureStorage storage) =>
    storage.read(key: _tokenKey);

Future<void> deleteToken(FlutterSecureStorage storage) =>
    storage.delete(key: _tokenKey);
