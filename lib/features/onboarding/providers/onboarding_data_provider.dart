import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingData {
  final String childName;
  final int childAge;
  final String avatarId;
  final String language;

  const OnboardingData({
    this.childName = '',
    this.childAge = 5,
    this.avatarId = 'avatar_01',
    this.language = 'vi',
  });

  OnboardingData copyWith({
    String? childName,
    int? childAge,
    String? avatarId,
    String? language,
  }) =>
      OnboardingData(
        childName: childName ?? this.childName,
        childAge: childAge ?? this.childAge,
        avatarId: avatarId ?? this.avatarId,
        language: language ?? this.language,
      );
}

final onboardingDataProvider = StateProvider<OnboardingData>((_) => const OnboardingData());
