# Kids Math App

Ứng dụng học toán dành cho trẻ em 5–7 tuổi. Chạy trên iOS và Android.

## Giới thiệu

App giúp trẻ luyện tập 8 kỹ năng toán theo lộ trình cá nhân hóa từ AI. Hệ thống tự động phát hiện điểm yếu, điều chỉnh độ khó và nhắc ôn tập đúng lúc (spaced repetition). Giao diện thân thiện với trẻ nhỏ: hình ảnh trực quan, âm thanh phản hồi, TTS đọc câu hỏi.

## Tech Stack

| Thành phần | Công nghệ |
|---|---|
| Framework | Flutter 3.x + Dart |
| State | Riverpod |
| Navigation | go_router |
| HTTP | Dio + JWT interceptor |
| Auth storage | flutter_secure_storage |
| Audio | audioplayers + flutter_tts |
| Animation | Lottie |
| Charts | fl_chart (Radar Chart) |

## Tính năng

- Placement test xác định trình độ ban đầu
- Lesson queue cá nhân hóa theo điểm yếu
- Tutorial tự động khi bé liên tiếp làm sai
- Skill map trực quan — 8 kỹ năng với % thành thạo
- Gamification: XP, Level, Streak, Badges
- Parent dashboard theo dõi tiến trình
- Hỗ trợ Tiếng Việt / English
- Offline mode với local cache

## Cài đặt

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Chạy app

```bash
# Android emulator (localhost API)
flutter run

# Kết nối API thật
flutter run --dart-define=API_URL=http://192.168.1.x:3000
```

## Build APK Android (chạy trong Git Bash)

```bash
unset _JAVA_OPTIONS && \
GRADLE_USER_HOME="D:/SDK/gradle" \
ANDROID_HOME="D:/SDK/android" \
ANDROID_SDK_ROOT="D:/SDK/android" \
flutter build apk --release --dart-define=API_URL=http://YOUR_SERVER_IP:3000
```

> Thay `YOUR_SERVER_IP` bằng IP VPS hoặc IP máy local.
> File APK output: `build/app/outputs/flutter-apk/app-release.apk`

## Backend API

[kids-math-api](https://github.com/Anhvutpbn/kids-math-api) — NestJS + MongoDB Atlas
