import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/models/user_model.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/onboarding/presentation/screens/welcome_screen.dart';
import '../features/onboarding/presentation/screens/avatar_pick_screen.dart';
import '../features/placement_test/presentation/screens/placement_test_screen.dart';
import '../features/home/presentation/screens/home_screen.dart';
import '../features/session/presentation/screens/session_screen.dart';
import '../features/session/presentation/screens/result_screen.dart';
import '../features/session/presentation/screens/tutorial_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/skill_map/presentation/screens/skill_map_screen.dart';
import '../features/gamification/presentation/screens/badges_screen.dart';
import '../features/dashboard/presentation/screens/session_detail_screen.dart';
import '../features/memory_game/models/memory_game_models.dart';
import '../features/memory_game/presentation/screens/memory_game_level_select_screen.dart';
import '../features/memory_game/presentation/screens/memory_game_screen.dart';
import '../features/multiplication/models/multiplication_models.dart';
import '../features/multiplication/presentation/screens/multiplication_home_screen.dart';
import '../features/multiplication/presentation/screens/multiplication_session_screen.dart';
import '../features/multiplication/presentation/screens/multiplication_history_screen.dart';
import '../features/multiplication/presentation/screens/multiplication_learn_screen.dart';
import '../features/session/presentation/screens/skill_level_select_screen.dart';

/// ChangeNotifier that listens to authStateProvider and notifies GoRouter
/// to re-run redirect — without recreating the GoRouter instance.
class _RouterNotifier extends ChangeNotifier {
  _RouterNotifier(this._ref) {
    _ref.listen<AsyncValue<UserModel?>>(
      authStateProvider,
      (_, __) => notifyListeners(),
    );
  }

  final Ref _ref;

  bool get isLoading => _ref.read(authStateProvider).isLoading;
  UserModel? get user => _ref.read(authStateProvider).valueOrNull;
}

final _routerNotifierProvider = Provider<_RouterNotifier>(
  (ref) => _RouterNotifier(ref),
);

final appRouterProvider = Provider<GoRouter>((ref) {
  // READ — not watch — so the provider never re-runs and the GoRouter
  // is created exactly once for the lifetime of the app.
  final notifier = ref.read(_routerNotifierProvider);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      if (notifier.isLoading) return null;

      final user = notifier.user;
      final isLoggedIn = user != null;
      final isOnboarded = user?.onboardingDone ?? false;

      final loc = state.uri.toString();
      final isAuthRoute = loc.startsWith('/login') || loc.startsWith('/register');
      final isOnboardingRoute = loc.startsWith('/onboarding');
      final isSplash = loc == '/splash';

      if (isSplash) {
        if (!isLoggedIn) return '/login';
        if (!isOnboarded) return '/onboarding/welcome';
        return '/home';
      }
      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && !isOnboarded && !isOnboardingRoute) return '/onboarding/welcome';
      if (isLoggedIn && isOnboarded && (isAuthRoute || isOnboardingRoute)) return '/home';
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const _SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/onboarding/welcome', builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: '/onboarding/avatar', builder: (_, __) => const AvatarPickScreen()),
      GoRoute(path: '/onboarding/placement', builder: (_, __) => const PlacementTestScreen()),
      GoRoute(path: '/home', builder: (_, __) => const HomeScreen()),
      GoRoute(path: '/session', builder: (_, __) => const SessionScreen()),
      GoRoute(
        path: '/skill-level-select',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>;
          return SkillLevelSelectScreen(
            skillId: extra['skillId'] as String,
            emoji: extra['emoji'] as String,
            name: extra['name'] as String,
          );
        },
      ),
      GoRoute(
        path: '/result',
        builder: (_, state) {
          final extra = state.extra as Map<String, dynamic>? ?? {};
          return ResultScreen(
            stars: extra['stars'] as int? ?? 1,
            xpEarned: extra['xpEarned'] as int? ?? 0,
            correctCount: extra['correctCount'] as int? ?? 0,
            totalCount: extra['totalCount'] as int? ?? 0,
            previousXp: extra['previousXp'] as int? ?? 0,
          );
        },
      ),
      GoRoute(
        path: '/tutorial',
        builder: (_, state) {
          final skillId = state.extra as String? ?? '';
          return TutorialScreen(skillId: skillId);
        },
      ),
      GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
      GoRoute(path: '/skill-map', builder: (_, __) => const SkillMapScreen()),
      GoRoute(path: '/badges', builder: (_, __) => const BadgesScreen()),
      GoRoute(
        path: '/session-detail/:id',
        builder: (_, state) => SessionDetailScreen(
          sessionId: state.pathParameters['id']!,
          date: state.extra as String? ?? '',
        ),
      ),
      GoRoute(
        path: '/memory-game',
        builder: (_, __) => const MemoryGameLevelSelectScreen(),
      ),
      GoRoute(
        path: '/memory-game/play',
        builder: (_, state) {
          final config = state.extra as MemoryGameLevelConfig;
          return MemoryGameScreen(config: config);
        },
      ),
      GoRoute(
        path: '/multiplication',
        builder: (_, __) => const MultiplicationHomeScreen(),
      ),
      GoRoute(
        path: '/multiplication/learn',
        builder: (_, __) => const MultiplicationLearnScreen(),
      ),
      GoRoute(
        path: '/multiplication/session',
        builder: (_, state) {
          final config = state.extra as MultiLevelConfig;
          return MultiplicationSessionScreen(config: config);
        },
      ),
      GoRoute(
        path: '/multiplication/history',
        builder: (_, __) => const MultiplicationHistoryScreen(),
      ),
    ],
  );
});

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
