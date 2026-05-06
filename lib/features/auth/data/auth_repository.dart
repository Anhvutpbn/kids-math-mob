import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../models/user_model.dart';
import 'auth_api.dart';

const _validAvatarIds = {
  'avatar_01', 'avatar_02', 'avatar_03', 'avatar_04',
  'avatar_05', 'avatar_06', 'avatar_07', 'avatar_08',
};

Map<String, dynamic> _normalizeUser(Map<String, dynamic> raw) {
  final avatarId = raw['avatarId']?.toString() ?? '';
  if (avatarId.isEmpty || !_validAvatarIds.contains(avatarId)) {
    return {...raw, 'avatarId': 'avatar_01'};
  }
  return raw;
}

class AuthRepository {
  final AuthApi _api;
  final _storage;

  AuthRepository(this._api, this._storage);

  Future<UserModel> login(String email, String password) async {
    final data = await _api.login(email: email, password: password);
    await saveToken(_storage, data['access_token'] as String);
    return UserModel.fromJson(_normalizeUser(data['user'] as Map<String, dynamic>));
  }

  Future<UserModel> register(String email, String password) async {
    final data = await _api.register(email: email, password: password);
    await saveToken(_storage, data['access_token'] as String);
    return UserModel.fromJson(_normalizeUser(data['user'] as Map<String, dynamic>));
  }

  Future<UserModel?> getMe() async {
    final token = await readToken(_storage);
    if (token == null) return null;
    try {
      final data = await _api.getMe();
      return UserModel.fromJson(_normalizeUser(data));
    } catch (_) {
      return null;
    }
  }

  Future<void> logout() => deleteToken(_storage);

  Future<void> completeOnboarding({
    required String childName,
    required int childAge,
    required String avatarId,
    required String language,
  }) =>
      _api.completeOnboarding(
        childName: childName,
        childAge: childAge,
        avatarId: avatarId,
        language: language,
      );
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(secureStorageProvider),
  );
});
