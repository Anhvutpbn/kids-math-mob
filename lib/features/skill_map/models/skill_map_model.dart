import 'package:freezed_annotation/freezed_annotation.dart';

part 'skill_map_model.freezed.dart';
part 'skill_map_model.g.dart';

@freezed
class SkillMapEntry with _$SkillMapEntry {
  const factory SkillMapEntry({
    required String id,
    required String skillId,
    @Default(0) int mastery,
    String? errorTypeFlag,
    DateTime? nextReviewAt,
    @Default(false) bool locked,
  }) = _SkillMapEntry;

  factory SkillMapEntry.fromJson(Map<String, dynamic> json) =>
      _$SkillMapEntryFromJson(json);
}
