# Verification — 11 November 2026

- Flutter 3.47.9 stable, Dart 3.13.7.
- `flutter analyze`: passed, no issues.
- Curriculum validation: 100 days; 200 sentence pairs in each; 10 rounds of 20; 20,000 unique Hindi sentences, English sentences and IDs; no unexpanded placeholders.
- Automated tests: four progress/reward/backup tests, one full curriculum test, and two widget tests passed. Widget checks cover the dashboard and lesson at 390 × 844, correct-answer XP, and wrong-answer revision without XP.
- Release JavaScript web build: passed with `/english-quest/` base path and locally bundled CanvasKit resources.
- Flutter's optional WebAssembly compatibility dry run reports third-party `flutter_tts` interop warnings. This deliverable uses the successfully compiled JavaScript build, not WebAssembly.
- Full live-browser visual verification was not possible: the cloud browser could not connect to the local preview server.
- Android and iOS platform source projects are included, but native builds, speech output on actual devices, signing, and app-store submission have not been verified.
- No GitHub push or public deployment has occurred. The target repository was not available through the connected account, and the browser required sign-in. The included workflow is ready for the repository once it exists and GitHub Pages is configured for Actions.

The course is pattern-based translation practice. Automated uniqueness/count tests do not certify linguistic quality or suitability for every learner; the source patterns are editable for teacher review.
