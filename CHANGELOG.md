# Changelog

All notable changes to **Our Story** are documented here. Format loosely
follows [Keep a Changelog](https://keepachangelog.com/).

## [1.6.0] — Production Release Candidate (RC1)

First Play Store–ready release. No feature, screen, route, model,
repository, or architecture changed — this milestone is entirely about
packaging, signing, and release-pipeline quality.

### Added
- Official app icon (adaptive icon — foreground + background — for
  Android 8+, plus legacy and round launcher icons for older devices)
  generated for every density (mdpi → xxxhdpi), replacing the default
  Flutter icon.
- `android:roundIcon` wired up in the manifest alongside the existing
  `android:icon`.
- Real Android release signing: Gradle now reads `android/key.properties`
  (never committed) and applies a proper upload-key `signingConfig` to
  release builds. Falls back to the debug key only when no
  `key.properties` is present, so a fresh local clone still builds.
- Production release GitHub Actions workflow: checkout → JDK 17 → Flutter
  → dependency/Gradle caching → `flutter pub get` → `flutter analyze` →
  `flutter test` → decode `KEYSTORE_BASE64` and write `key.properties`
  from the `KEY_ALIAS` / `KEY_PASSWORD` / `STORE_PASSWORD` secrets →
  signed `flutter build apk --release` and `flutter build appbundle
  --release` → APK signature verification → upload both artifacts →
  on a `v*.*.*` tag push, automatically create/update the GitHub Release
  with both files attached → signing material wiped from the runner at
  the end of the job.
- `store_assets/play_store_icon_512.png` — a 512×512 Play Store listing
  icon generated from the same source artwork.

### Changed
- Version bumped to `1.6.0+7`.

## [1.5.0] — Premium Romantic Experience & Final Story Polish

Pure visual/emotional polish — no architecture, route, storage layer,
repository, or animation was redesigned.

- Premium Home Screen: animated gradient, floating hearts, golden
  particles, staggered fade/rise entrance for every section.
- Luxury typography pass: soft glow shadows, wider letter-spacing, new
  `displayTitle` / `statNumber` / `credits` / `heroSubtitle` /
  `sectionLabel` styles, all existing styles unchanged.
- Always-on, low-opacity ambient romantic decoration layer in Story Mode
  (sparkles, golden dust, rose petals, rare heart bursts).
- Dynamic mood-gradient backgrounds for milestone scenes with no photo or
  video of their own.
- 7 new cinematic transitions (Dream Fade, Romantic Blur, Heart Reveal,
  Rose Bloom, Golden Flash, Film Burn, Soft Zoom), joining the existing
  11 for 18 total.
- Staged emotional Story finale: live journey statistics → closing
  message → fireworks/stars → slow credits roll.
- `JourneyModel` field 8, `featuredName` — additive, backward compatible.

## [1.4.0] — Media & Performance Pass

- Music Manager: per-scene background music with a dedicated volume
  setting, falling back to the app's ambient theme when a scene has none.
- Drag-to-reorder for photos and videos in Creator Mode.
- Preview no longer requires saving the scene first.
- Perf pass: media decoded at display resolution instead of full
  resolution (photo pickers, video thumbnails, scene backgrounds).
- Named voice notes (e.g. "Dad's toast").

## [1.3.0] — Cinematic Experience Engine

- `SceneMilestoneType` and themed decorative treatments per milestone.
- Cinematic vertical timeline screen — scroll through the relationship by
  year rather than a plain list.
- Journey Intro title card with both partners' names.
- Additional cinematic scene transitions, bringing the total (combined
  with v1.2.0) to 11.

## [1.2.0] — Story Engine

- Real `Chapter` entities with chapter-grouped story structure (scenes
  link to a chapter via `Scene.chapterId`, replacing plain string
  labels — the old label keeps working for anything authored earlier).
- Richer "letter reveal" scene content.
- Voice-note waveform player.

## [1.1.0] — Media Foundation

- Real photo/video/background-music/voice-recording pipeline,
  implementing what v1.0.0 had left as architecture-only placeholders.
- `Scene.voiceRecordingPath` introduced.

## [1.0.0] — Foundation

- Initial offline architecture: MVVM + Riverpod, go_router navigation,
  Hive local storage, no Firebase/network dependency of any kind.
- Base Home Screen with the long-press-the-heart Creator Mode shortcut.
- Plain scene layout (title / optional subtitle / story text).
