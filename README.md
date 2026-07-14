# Our Story — Hanif ❤ Santona

An interactive, cinematic anniversary gift app telling a love story from
**October 1, 2017** to **July 17, 2026** — built entirely offline, with no
Firebase and no network dependency of any kind.

> **Status:** `v1.6.0 — Production Release Candidate (RC1)`. This
> milestone adds nothing new to the app experience — no feature, screen,
> route, model, repository, or architecture changed. It's entirely
> packaging and release-pipeline work: the official app icon, real
> Android release signing, and a GitHub Actions workflow that produces a
> signed APK and AAB automatically. See [CHANGELOG.md](CHANGELOG.md) for
> the full version history, including what `v1.5.0` (Premium Romantic
> Experience & Final Story Polish) delivered.

---

## ✨ What's in v1.5.0

- **Premium Home Screen**: animated gradient + floating hearts + golden
  particles + soft glow behind a staggered fade/rise entrance for the
  welcome text and every section — Continue Journey, Preview Story,
  Anniversary Countdown, Favorite Memories, Recent Scenes, Settings.
  Creator Mode is still reachable via the original long-press-the-heart
  shortcut (unchanged since v1.0.0); a small "Create New Story" text
  link now sits alongside it too.
- **Luxury Typography**: soft glow shadows on every large title, wider
  letter-spacing, two new styles (`displayTitle`, `statNumber`,
  `credits`, `heroSubtitle`, `sectionLabel`) — every existing style name
  and call site keeps working exactly as before.
- **Ambient Romantic Decorations**: a new, always-on, low-opacity layer
  in Story Mode — faint sparkles, golden dust, occasional rose petals,
  and a rare heart burst — independent of whatever `AnimationType` or
  milestone a scene already has, tuned deliberately faint so it never
  competes with photos or text.
- **Dynamic Background System**: scenes with a `SceneMilestoneType` and
  no photo/video of their own now render a milestone-appropriate mood
  gradient (sunset tones for Proposal, ivory/gold for Wedding, warm
  gold for Pregnancy, a hospital-to-nursery blend for Baby's Birth,
  cozy terracotta for Family, candlelit midnight for Anniversary)
  instead of the generic romantic gradient — carried smoothly by the
  scene-to-scene transition system that already existed.
- **7 new transitions**: Dream Fade, Romantic Blur, Heart Reveal (a
  real heart-shaped clip-path wipe), Rose Bloom, Golden Flash, Film
  Burn, Soft Zoom — joining the 11 from v1.2.0/v1.3.0 for 18 total,
  each independently configurable per scene exactly like the others.
- **Emotional Ending**: Story Mode's finale is now a staged sequence —
  journey statistics (years married, years/days together, memories/
  photos/videos counts, computed live from the scenes just played and
  the editable Journey record) → "I love you forever." → "Happy
  Anniversary ❤️" with fireworks and stars → a slow Credits roll
  ("Created with Love", the couple's names, an optional "Featuring"
  line) — with Watch Again/Close always available, never forcing anyone
  to sit through it.
- **Performance pass**: no new rebuild sources introduced by the
  ambient decoration layer (built once, animates via its own
  controllers); every new `AnimationController`/`Timer` is disposed;
  confirmed zero `Hero` widgets exist anywhere (so there's nothing to
  collide on tags).

## 🗄️ Storage model & schema evolution

One more additive Hive field this milestone: `JourneyModel` field 8,
`featuredName` (String, default empty) — falls back gracefully for any
Journey record saved by an earlier version, no migration step.

## 🚀 Getting started

```bash
flutter pub get
flutter run
```

### Android: one-time Gradle wrapper step

This repo intentionally does **not** commit the binary `gradle-wrapper.jar`.
Generate it once locally before your first Android build:

```bash
cd android
gradle wrapper --gradle-version 8.6 --distribution-type all
cd ..
flutter build apk --release
```

CI does this automatically on every run — see
`.github/workflows/build_apk.yml`.

## 🖼️ App icon

The official launcher icon lives in `android/app/src/main/res/` — legacy
square icons and round icons for every density (`mdpi`–`xxxhdpi`), plus
an Android 8+ adaptive icon (`mipmap-anydpi-v26/ic_launcher.xml`) built
from a navy-blue background (`values/ic_launcher_background.xml`) and a
safe-zone-scaled foreground so it survives circle, squircle, and
rounded-square launcher masks alike. A 512×512 copy for the Play Store
listing is at `store_assets/play_store_icon_512.png`.

## 🔐 Release & signing

Release builds are signed with a real upload key, not the Flutter debug
key.

**In CI** (`.github/workflows/build_apk.yml`): the workflow decodes the
`KEYSTORE_BASE64` repository secret into `android/app/upload-keystore.jks`
and writes `android/key.properties` from the `KEY_ALIAS`, `KEY_PASSWORD`,
and `STORE_PASSWORD` secrets before building. Both files are deleted from
the runner at the end of the job. Push a tag matching `v*.*.*` (e.g.
`v1.6.0`) to also cut a GitHub Release with the signed APK and AAB
attached automatically.

**Locally**, to produce a properly signed build:

```bash
# from the repo root
keytool -genkey -v -keystore android/app/upload-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

then create `android/key.properties` (already git-ignored):

```properties
storeFile=upload-keystore.jks
storePassword=<your store password>
keyAlias=upload
keyPassword=<your key password>
```

```bash
flutter build apk --release
flutter build appbundle --release
```

Without `android/key.properties`, release builds silently fall back to
the debug key so `flutter build apk --release` still succeeds for local
testing — but such a build must never be uploaded to Google Play.

## 🗺️ Roadmap (deliberately out of scope for this milestone)

- The remaining 6 reserved `AnimationType` overlay renderers.
- A true bezier page-curl (today's `pageCurl` is a stylized 3D-flip).
- Bundling real `ambient_theme.mp3` / `paper_open.mp3` audio assets.
- Photographic (not gradient-mood) milestone backgrounds, if real
  location/stage photography is ever supplied.

## 📄 License

Private, personal project. Not published to pub.dev.
