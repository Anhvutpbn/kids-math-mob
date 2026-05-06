import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_repository.dart';
import '../../models/user_model.dart';

class AuthNotifier extends AsyncNotifier<UserModel?> {
  @override
  Future<UserModel?> build() async {
    return ref.read(authRepositoryProvider).getMe();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).login(email, password),
    );
  }

  Future<void> register(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(authRepositoryProvider).register(email, password),
    );
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncData(null);
  }

  Future<void> completeOnboarding({
    required String childName,
    required int childAge,
    required String avatarId,
    required String language,
  }) async {
    await ref.read(authRepositoryProvider).completeOnboarding(
          childName: childName,
          childAge: childAge,
          avatarId: avatarId,
          language: language,
        );
    final user = await ref.read(authRepositoryProvider).getMe();
    state = AsyncData(user);
  }

  Future<void> updateLanguage(String language) async {
    final current = state.valueOrNull;
    if (current == null) return;
    await ref.read(authRepositoryProvider).completeOnboarding(
      childName: current.childName ?? '',
      childAge: current.childAge ?? 6,
      avatarId: current.avatarId,
      language: language,
    );
    state = AsyncData(current.copyWith(language: language));
  }
}

final authStateProvider = AsyncNotifierProvider<AuthNotifier, UserModel?>(
  AuthNotifier.new,
);
