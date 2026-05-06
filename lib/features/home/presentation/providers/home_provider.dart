import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../session/data/session_api.dart';

/// Returns true if a weekly review session is available in the lesson queue.
final weeklyReviewAvailableProvider = FutureProvider<bool>((ref) async {
  try {
    final api = ref.read(sessionApiProvider);
    final queue = await api.getLessonQueueRaw();
    return queue['queueType'] == 'weekly_review';
  } catch (_) {
    return false;
  }
});
