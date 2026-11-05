# AGENTS.md

## Repository
- Flutter app (`harmony`) — music player shell built on the Nexora `xora` design system.
- Depends on sibling package `../Xora` via path dependency; clone both repos side-by-side or `flutter pub get` fails.

## Commands
- Setup: `flutter pub get`
- Analyze (lint/typecheck): `flutter analyze`
- Tests: `flutter test`
- Single test: `flutter test test/widget_test.dart` or `flutter test --name "harmony builds"`
- Run: `flutter run -d <device>`
- Web build: `flutter build web --no-tree-shake-icons` (FontAwesome icons; tree-shaking can drop glyphs)

## Verification
- Run `flutter analyze && flutter test` before finishing. No other lint/typecheck tooling.

## Structure
- Entry point: `lib/main.dart` (single file; all screens in `HarmonyApp`/`HarmonyHome`)
- Uses `XoraTheme`, `XoraResponsive`, `XoraOne`/`XoraSlate`/`XoraNexo` layouts, and `XoraIcons` (FontAwesome) from `package:xora`
- Tests: `test/widget_test.dart`

## Conventions
- Branches: `feat/...`, `fix/...`, `docs/...`, `refactor/...`
- Commits: Conventional Commits (e.g. `feat(app): ...`)
- Large changes need an Issue first; PRs target `main`.

## Governance
- License: PolyForm Noncommercial 1.0.0; "Nexora" name/logo/brand require written permission.
- Security: follow SECURITY.md reporting flow; no public disclosure.

## Gotchas
- `analysis_options.yaml` excludes platform dirs (`android/`, `web/`, etc.) from analysis.
- SDK constraint `^3.13.7`; Xora requires Flutter `>=3.24.0`.
- README/CONTRIBUTING still contain `{{TODO}}` placeholders; do not treat as authoritative.