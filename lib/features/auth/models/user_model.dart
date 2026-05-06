import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const factory UserModel({
    required String id,
    required String email,
    String? childName,
    int? childAge,
    @Default('vi') String language,
    @Default('avatar_01') String avatarId,
    @Default(0) int totalXp,
    @Default(0) int streakCurrent,
    @Default(0) int streakLongest,
    @Default(false) bool onboardingDone,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}
