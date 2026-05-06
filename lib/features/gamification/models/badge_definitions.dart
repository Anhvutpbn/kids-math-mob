import 'badge_model.dart';

/// Static badge catalogue — used as fallback when API is unavailable.
const kBadgeDefinitions = [
  BadgeModel(
    id: 'streak_3',
    nameVi: 'Ngọn lửa 3 ngày',
    descriptionVi: 'Học liên tục 3 ngày',
    iconAsset: 'assets/images/badges/badge_streak_3.png',
    condition: '3 ngày streak',
  ),
  BadgeModel(
    id: 'streak_7',
    nameVi: 'Tuần lễ vàng',
    descriptionVi: 'Học liên tục 7 ngày',
    iconAsset: 'assets/images/badges/badge_streak_7.png',
    condition: '7 ngày streak',
  ),
  BadgeModel(
    id: 'streak_30',
    nameVi: 'Siêu kiên trì',
    descriptionVi: 'Học liên tục 30 ngày',
    iconAsset: 'assets/images/badges/badge_streak_30.png',
    condition: '30 ngày streak',
  ),
  BadgeModel(
    id: 'first_star',
    nameVi: 'Ngôi sao đầu tiên',
    descriptionVi: 'Hoàn thành bài học đầu tiên',
    iconAsset: 'assets/images/badges/badge_first_star.png',
    condition: 'Hoàn thành 1 bài',
  ),
  BadgeModel(
    id: 'perfect',
    nameVi: 'Hoàn hảo!',
    descriptionVi: 'Đạt 100% trong một buổi học',
    iconAsset: 'assets/images/badges/badge_perfect.png',
    condition: '100% chính xác',
  ),
  BadgeModel(
    id: 'speed',
    nameVi: 'Tốc độ ánh sáng',
    descriptionVi: 'Trả lời dưới 5 giây mỗi câu',
    iconAsset: 'assets/images/badges/badge_speed.png',
    condition: 'TB < 5s/câu',
  ),
  BadgeModel(
    id: 'master_add',
    nameVi: 'Vua cộng số',
    descriptionVi: 'Thành thạo phép cộng (≥80%)',
    iconAsset: 'assets/images/badges/badge_master_add.png',
    condition: 'Mastery cộng ≥80%',
  ),
  BadgeModel(
    id: 'master_sub',
    nameVi: 'Vua trừ số',
    descriptionVi: 'Thành thạo phép trừ (≥80%)',
    iconAsset: 'assets/images/badges/badge_master_sub.png',
    condition: 'Mastery trừ ≥80%',
  ),
  BadgeModel(
    id: 'explorer',
    nameVi: 'Nhà thám hiểm',
    descriptionVi: 'Thử tất cả 7 kỹ năng',
    iconAsset: 'assets/images/badges/badge_explorer.png',
    condition: 'Làm bài ở 7 kỹ năng',
  ),
  BadgeModel(
    id: 'champion',
    nameVi: 'Nhà vô địch',
    descriptionVi: 'Đạt 3 sao 10 buổi liên tiếp',
    iconAsset: 'assets/images/badges/badge_champion.png',
    condition: '10 buổi 3 sao liên tiếp',
  ),
];
