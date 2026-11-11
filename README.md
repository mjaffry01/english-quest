# English Quest

A Flutter Hindi-to-English learning app with **100 course days and 200 sentence pairs every day (20,000 total)**.

## Features

- Ten rounds of 20 sentences each day; ten progressively harder levels.
- Multiple-choice translation, written translation with model answers and self-assessment, and English text-to-speech.
- Ten recurring themes: home, school, play, food, nature, city, science, creativity, kindness, adventure.
- Sequential lesson unlocks, bookmarks, mistake revision, saved local progress and JSON backup/restore.
- Five XP per newly mastered sentence, 100 XP per completed course day. Replays cannot farm points.
- A calendar-day streak requires 200 newly mastered sentences that day. Multiple course days on one date still count as one streak day. Badges at 1, 3, 7, 14, 30, 60 and 100 days remain after a missed day.
- Responsive desktop/mobile layout and bundled Hindi fonts. No account, advertising, analytics or paid API.

## Run and verify

Install Flutter stable and Python 3. Then:

```sh
python3 tools/build_course.py
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

For unattended environments, set `CI=true`, `FLUTTER_SUPPRESS_ANALYTICS=true`, and `DASH__SUPPRESS_ANALYTICS=true` to skip cloud-host detection and analytics.

## Publish to GitHub Pages

1. Create a public repository named `english-quest` (or use another repository name).
2. Push these files to its `main` branch.
3. In repository **Settings → Pages → Build and deployment**, choose **GitHub Actions**.
4. Run **Test and publish English Quest** from the Actions tab, or push a commit.

The workflow generates/validates content, runs the analyzer and tests, builds Flutter web with the repository-specific base path, and deploys to Pages. It uses GitHub's built-in token; no personal access token belongs in the repository. The actual published URL appears in the workflow deployment result.

Manual web build:

```sh
flutter build web --release --base-href /english-quest/ --no-web-resources-cdn
```

Serve `build/web` over HTTP(S), not a `file://` URL. For a custom domain at the root use `--base-href /`.

## Mobile distribution

The Flutter UI and persistence work across supported platforms. Android/iOS platform projects are included when generated. Build Android with `flutter build apk --release` after installing the Android SDK. iOS requires macOS, Xcode, and your signing identity. GitHub Pages publishes the **web version**, not an App Store/Play Store release. Native signing and store submissions are separate.

## Content design and limitations

`tools/build_course.py` is the editable source of the curriculum; `assets/course.json` is the bundled generated course. It combines 200 bilingual activities with 100 sentence patterns. These are **structured practice variations**, not 20,000 independently written stories. Difficulty increases by grammatical stage every ten days; the themes recur intentionally. This is not an accredited syllabus or a guarantee of fluency. A teacher should review the course for a particular child's level and use real conversation alongside translation.

Most Hindi examples use हम (we); some questions address तुम. Indian/British English spelling is used. Written answers are **self-assessed**, not AI-graded; more than one translation may be valid. Speech depends on installed browser/device voices and is not pronunciation scoring. Streak dates use the device clock; this is a personal learning tool, not a tamper-proof rewards system. Breaks are encouraged; a missed day never deletes learning progress.

Progress stays in local device storage. Clearing browser data removes it. Settings supports copying a backup and restoring it on another device. Restore replaces current local progress after validating the backup format. No server sync is provided. The web app requires an initial network load; offline installation/caching is not promised.

## Font attribution

Bundled Noto Sans Devanagari fonts are distributed under the SIL Open Font License; see `assets/fonts/LICENSE.txt`.
