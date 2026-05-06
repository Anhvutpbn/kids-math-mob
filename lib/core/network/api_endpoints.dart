import 'package:flutter/foundation.dart';

class ApiEndpoints {
  static String get baseUrl {
    const envUrl = String.fromEnvironment('API_BASE_URL');
    if (envUrl.isNotEmpty) return envUrl;
    return kIsWeb
        ? 'http://localhost:3000/api/v1'
        : 'http://10.0.2.2:3000/api/v1';
  }

  // Auth
  static const register = '/auth/register';
  static const login = '/auth/login';
  static const onboardingDone = '/auth/me/onboarding-done';

  // Users
  static const me = '/users/me';
  static const avatar = '/users/me/avatar';

  // Skills
  static const skills = '/skills';
  static const skillMap = '/skills/map';
  static String skillMapDetail(String skillId) => '/skills/map/$skillId';

  // Questions
  static const questions = '/questions';
  static String questionDetail(String id) => '/questions/$id';

  // Placement test
  static const placementQuestions = '/placement-test/questions';
  static const placementSubmit = '/placement-test/submit';

  // Sessions
  static const sessionStart = '/sessions/start';
  static const sessionSubmitQuestion = '/sessions/questions/submit';
  static String sessionEnd(String id) => '/sessions/$id/end';
  static const sessionHistory = '/sessions/history';
  static String sessionDetail(String id) => '/sessions/$id/detail';

  // Lesson queue
  static const lessonQueueNext = '/lesson-queue/next';
  static const lessonQueueGenerate = '/lesson-queue/generate';
  static const lessonQueueGenerateWeekly = '/lesson-queue/generate-weekly';

  // AI
  static const aiAnalyze = '/ai/analyze';
  static const aiInsight = '/ai/insight';
  static const aiWeakAreas = '/ai/weak-areas';

  // Dashboard
  static const dashboardSummary = '/dashboard/summary';
  static const dashboardSessionHistory = '/dashboard/session-history';
  static const dashboardSkillOverview = '/dashboard/skill-overview';
  static const dashboardAiInsight = '/dashboard/ai-insight';

  // Badges
  static const badges = '/badges';
  static const myBadges = '/badges/me';
}
