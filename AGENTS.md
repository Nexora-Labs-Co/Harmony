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
- Entry point: `lib/main.dart` (`HarmonyApp` wires `MultiProvider` + `HarmonyHome`)
- State: `lib/core/state/*_provider.dart` (Library, Playlist, Player, Profile)
- Models: `lib/core/models/` (`Track`, `Playlist`, `ExternalTrackModel`)
- Services: `lib/core/services/` (`YouTubeService`, `RecommendationService`)
- Screens: `lib/ui/screens/{home,favorites,local,album,playlists,cari,search}/`
- Shared widgets: `lib/ui/shared/widgets/cached_artwork.dart`
- Mobile layout uses `XoraOne`; tablet `XoraSlate`; desktop `XoraNexo`

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
- Mobile home greeting is time-based; tests should not assert a specific greeting.