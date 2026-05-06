enum SkillId { SK01, SK02, SK03, SK04, SK05, SK06, SK07, SK08 }

class SkillMeta {
  final SkillId id;
  final String nameVi;
  final String nameEn;
  final List<SkillId> dependsOn;
  final int order;

  const SkillMeta({
    required this.id,
    required this.nameVi,
    required this.nameEn,
    required this.dependsOn,
    required this.order,
  });
}

const skills = <SkillId, SkillMeta>{
  SkillId.SK01: SkillMeta(id: SkillId.SK01, nameVi: 'Nhận biết số 0-10',   nameEn: 'Number Recognition 0-10',  dependsOn: [],                              order: 1),
  SkillId.SK02: SkillMeta(id: SkillId.SK02, nameVi: 'Nhận biết số 0-100',  nameEn: 'Number Recognition 0-100', dependsOn: [SkillId.SK01],                  order: 2),
  SkillId.SK03: SkillMeta(id: SkillId.SK03, nameVi: 'Đếm số',              nameEn: 'Counting',                 dependsOn: [SkillId.SK01],                  order: 3),
  SkillId.SK04: SkillMeta(id: SkillId.SK04, nameVi: 'So sánh số',          nameEn: 'Number Comparison',        dependsOn: [SkillId.SK02],                  order: 4),
  SkillId.SK05: SkillMeta(id: SkillId.SK05, nameVi: 'Phép cộng đơn giản', nameEn: 'Simple Addition',          dependsOn: [SkillId.SK03],                  order: 5),
  SkillId.SK06: SkillMeta(id: SkillId.SK06, nameVi: 'Phép trừ đơn giản',  nameEn: 'Simple Subtraction',       dependsOn: [SkillId.SK05],                  order: 6),
  SkillId.SK07: SkillMeta(id: SkillId.SK07, nameVi: 'Điền số còn thiếu',  nameEn: 'Missing Number',           dependsOn: [SkillId.SK04, SkillId.SK05],    order: 7),
  SkillId.SK08: SkillMeta(id: SkillId.SK08, nameVi: 'Chọn min/max',        nameEn: 'Min/Max Selection',         dependsOn: [SkillId.SK04],                  order: 8),
};

class MasteryThreshold {
  static const int beginner   = 30;
  static const int learning   = 60;
  static const int practicing = 80;
  static const int mastered   = 100;
}

const int spacedRepetitionDays = 7;
const int maxAttemptsPerQuestion = 3;
const int streakResetHours = 36; // grace period
