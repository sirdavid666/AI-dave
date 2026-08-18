# Dave AI Voice Assistant

100% offline Android voice assistant built with Flutter. No internet, no API key.

## What's included
```
lib/
  main.dart            - app entry point, dark theme
  home_screen.dart      - center glowing mic button screen
  chat_screen.dart      - WhatsApp-style chat, voice in/out, file attach
  ai_brain.dart          - offline rule-based getAIResponse() logic
  models/message.dart    - chat message model
  widgets/mic_button.dart   - animated glowing mic button
  widgets/chat_bubble.dart  - animated fade-in chat bubble
android/app/src/main/AndroidManifest.xml  - permissions
android/app/build.gradle.snippet           - minSdk 21 / targetSdk 34 config
pubspec.yaml           - dependencies
```

## Build it into an APK (do this on your own computer)
I can write and organize all the Dart/Flutter source code, but I don't have
the Android SDK, emulator, or Flutter build toolchain in this environment
to actually compile an .apk — that has to happen on a machine with Flutter
installed. Steps:

1. Install Flutter: https://docs.flutter.dev/get-started/install
2. Create the platform folders (this project ships `lib/`, `pubspec.yaml`,
   and manifest content only):
   ```
   flutter create --org com.dave.ai --project-name dave_ai_voice_assistant .
   ```
   Then copy this project's `lib/` and `pubspec.yaml` over the generated ones,
   and merge `android/app/src/main/AndroidManifest.xml` and the
   `build.gradle.snippet` values into the generated `android/app/build.gradle`.
3. Fetch packages:
   ```
   flutter pub get
   ```
4. Run on a connected device/emulator:
   ```
   flutter run
   ```
5. Build the release APK:
   ```
   flutter build apk --release
   ```
   The APK will be at `build/app/outputs/flutter-apk/app-release.apk`.

Note: package version numbers in `pubspec.yaml` are current as of my last
update — `flutter pub get` will pull compatible versions, but if any have
moved on, bump them with `flutter pub upgrade`.

There's no "Settings > Publishing" toggle here — that instruction sounds
like it's from a different app-building platform. If you're using one
(FlutterFlow, a website builder, etc.), that setting lives in that tool,
not here.

## Known Android quirks handled
- Android 13+ (API 33) requires granular media permissions for file_picker;
  these are included in the manifest alongside `READ_EXTERNAL_STORAGE`.
- `queries` block added so `url_launcher` can open browser links on
  Android 11+ (package visibility rules).
