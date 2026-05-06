import 'package:freezed_annotation/freezed_annotation.dart';

part 'placement_models.freezed.dart';
part 'placement_models.g.dart';

@freezed
class PlacementQuestion with _$PlacementQuestion {
  const factory PlacementQuestion({
    required String id,
    required String skillId,
    required String type,
    required String questionVi,
    String? questionEn,
    @Default([]) List<String> options,
    required String correctAnswer,
    @Default(1) int difficulty,
    String? hintVi,
  }) = _PlacementQuestion;

  factory PlacementQuestion.fromJson(Map<String, dynamic> json) =>
      _$PlacementQuestionFromJson(json);
}

@freezed
class PlacementAnswer with _$PlacementAnswer {
  const factory PlacementAnswer({
    required String questionId,
    required String answer,
    required int timeSpentMs,
  }) = _PlacementAnswer;

  factory PlacementAnswer.fromJson(Map<String, dynamic> json) =>
      _$PlacementAnswerFromJson(json);
}
