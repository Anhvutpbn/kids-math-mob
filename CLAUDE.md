# CLAUDE.md — kids-math-app

## Project

Flutter mobile app cho Kids Math Learning App. Chạy iOS + Android.
Kết nối với `kids-math-api` (NestJS + MongoDB Atlas).

## Stack

| Thành phần | Công nghệ |
|-----------|-----------|
| Framework | Flutter 3.x + Dart |
| State management | Riverpod (`flutter_riverpod` + `riverpod_generator`) |
| Navigation | `go_router` |
| HTTP | `dio` |
| Auth storage | `flutter_secure_storage` (JWT) |
| Local cache | `shared_preferences` (SkillMap, LessonQueue) |
| Audio | `audioplayers` |
| TTS | `flutter_tts` |
| Animation | `lottie` |
| Charts | `fl_chart` (RadarChart cho Skill Map) |
| Models | `freezed` + `json_serializable` |

## Cấu trúc thư mục

```
lib/
├── main.dart
├── app.dart                        # ProviderScope + MaterialApp.router
├── core/
│   ├── constants/skills.dart       # SkillId enum, MasteryThreshold constants
│   ├── theme/app_colors.dart       # Color palette + mastery color mapping
│   ├── network/api_client.dart     # Dio instance + JWT interceptor
│   └── utils/                      # tts_helper.dart, audio_helper.dart
├── features/
│   ├── auth/                       # login, register
│   ├── onboarding/                 # welcome, avatar pick, placement test
│   ├── home/                       # home screen + skill map preview
│   ├── session/                    # làm bài, tutorial, result
│   ├── skill_map/                  # radar chart đầy đủ
│   ├── dashboard/                  # parent dashboard
│   └── gamification/               # badges, streak, XP
├── shared/widgets/                 # AppButton, AvatarWidget, LoadingOverlay
└── routes/app_router.dart          # go_router named routes
assets/
├── images/avatars/                 # 8 avatar PNG — bundle trong app
├── images/badges/                  # badge icons
├── audio/                          # correct.mp3, wrong.mp3, levelup.mp3
└── animations/                     # Lottie JSON files
```

## Feature structure pattern

Mỗi feature theo cấu trúc:

```
feature_name/
├── data/
│   └── feature_api.dart           # Dio calls
├── models/
│   └── feature_model.dart         # @freezed class
└── presentation/
    ├── screens/
    ├── widgets/
    └── providers/
        └── feature_provider.dart  # Riverpod AsyncNotifier hoặc Notifier
```

## Conventions

- **Không dùng `setState`** — toàn bộ state qua Riverpod provider
- Model dùng `@freezed` — chạy `dart run build_runner build` sau khi thêm model
- Provider dùng `@riverpod` annotation — code gen tự tạo `.g.dart`
- Navigation dùng `context.go('/route')` hoặc `context.push('/route')`
- Tất cả API call trong `data/` layer, không gọi Dio trực tiếp từ widget
- Màu mastery: xem `AppColors` — green/yellow/orange/red/grey
- Không fetch ảnh từ network — dùng `Image.asset('assets/images/...')`

## API Base URL

```dart
// lib/core/network/api_client.dart
const String baseUrl = String.fromEnvironment('API_URL', defaultValue: 'http://10.0.2.2:3000');
// 10.0.2.2 = localhost từ Android emulator
// iOS simulator dùng 127.0.0.1
```

## Skill Map — Màu theo mastery

```dart
// AppColors
mastery >= 80  → Colors.green    // Thành thạo
mastery >= 60  → Colors.yellow   // Đang học tốt
mastery >= 30  → Colors.orange   // Đang học
mastery > 0    → Colors.red      // Cần luyện
mastery == 0 + locked → Colors.grey
```

## Session Flow quan trọng

Xem `docs/WORKFLOW_SESSION.md`. Key points:
1. Lấy `lesson_queue` từ API trước khi bắt đầu
2. Mỗi câu: đếm `time_spent_ms` local, gửi lên `POST /question/submit`
3. Nếu response `inject_tutorial: true` → **dừng session**, navigate `TutorialScreen`
4. Sau `session/end` → gọi `POST /ai/analyze` **async** (không block UI)
5. TTS đọc câu hỏi khi render `QuestionCard`

## Offline Strategy

- `SkillMap` và `LessonQueue` cache vào `shared_preferences`
- Khi offline: dùng cache, hiện banner nhỏ "Đang offline"
- Submit câu hỏi thất bại khi offline → lưu vào local queue, retry khi online

## UX cho trẻ nhỏ

- Button tối thiểu **64×64px**
- Font size trong session: đề bài **>= 28sp**, đáp án **>= 24sp**  
- TTS tự động đọc khi câu mới hiện ra
- Feedback âm thanh cho mọi tương tác (đúng/sai)
- Không có loading spinner dài — dùng skeleton hoặc cached data

## Build commands

```bash
# Install dependencies
flutter pub get

# Code generation (freezed + riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run on emulator
flutter run

# Run with custom API URL
flutter run --dart-define=API_URL=http://192.168.1.x:3000
```
