import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/gamification_api.dart';
import '../../models/badge_model.dart';
import '../../models/badge_definitions.dart';

/// All badges merged with earned status from /badges/me.
/// Falls back to static definitions if API is unavailable.
final badgesProvider = FutureProvider<List<BadgeModel>>((ref) async {
  final api = ref.read(gamificationApiProvider);
  try {
    final all = await api.getAllBadges();
    final earned = await api.getMyBadges();
    final earnedIds = {for (final b in earned) b.id};
    // Merge iconAsset from local definitions if API doesn't send it
    final localMap = {for (final b in kBadgeDefinitions) b.id: b.iconAsset};
    return all.map((b) => b.copyWith(
      earned: earnedIds.contains(b.id),
      iconAsset: b.iconAsset.isEmpty ? (localMap[b.id] ?? b.iconAsset) : b.iconAsset,
    )).toList();
  } catch (_) {
    // Offline fallback: show all badges as locked
    return kBadgeDefinitions;
  }
});
