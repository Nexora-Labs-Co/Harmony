# Harmony

Flutter + Rust hybrid music player. UI/state in Dart (`lib/`), metadata/FFI in Rust (`rust/crates/nexora_core`); actual audio playback is done by `media_kit` (mpv), not the Rust audio engine.

## Setup gotcha (do this first)

- `pubspec.yaml` depends on `nexora_ui_kit` via `path: ../NexoraUi-Kit`. That directory must exist as a **sibling of the repo root**. In this checkout it does not: the package lives at `../../ui/NexoraUi-Kit` (relative to the repo). Create a symlink before `flutter pub get`:
  - worktree: `ln -s /home/saaarmyx/Desktop/Nexora-Labs-Co/ui/NexoraUi-Kit /home/saaarmyx/.local/share/opencode/worktree/a5ede0/NexoraUi-Kit`
  - original clone: `ln -s ../../ui/NexoraUi-Kit /home/saaarmyx/Desktop/Nexora-Labs-Co/apps/NexoraUi-Kit`
- `assets/images/` must exist (referenced in `pubspec.yaml`).

## Commands

- `flutter pub get` — after the symlink above.
- `cd rust && cargo build -p nexora_core --release` — native core; output `rust/target/release/nexora_core.dll` (Windows) / `libnexora_core.so` (Linux). Cargo build emits warnings (static mut in `api.rs`) — pre-existing, not a failure.
- `cd rust && cargo test -p nexora_core` — runs 0 tests; not a meaningful gate.
- `cd rust && cargo fmt && cargo clippy` — expected per CONTRIBUTING (clippy warnings pre-existing).
- `flutter build linux --release` / `flutter build windows --release` / `flutter build apk --release`.
- `flutter analyze` — many pre-existing warnings; not a hard gate.
- `flutter test` — single smoke test in `test/widget_test.dart`; currently fails headless because `NexoraApp` uses `window_manager` + `media_kit` without `main()`'s `MediaKit.ensureInitialized()`. Not a reliable CI gate.
- Packaging: `./scripts/package.sh [linux|android|windows|all]` (Git Bash on Windows; uses `cygpath`). Builds Rust + Flutter, copies the DLL on Windows, zips.

## Verification order

1. `cd rust && cargo build -p nexora_core --release`
2. `flutter pub get`
3. `flutter build <platform> --release`
4. copy `rust/target/release/nexora_core.dll` → `build/windows/x64/runner/Release/` (package script does this)
5. smoke-run the built binary

## Native library / FFI

- `lib/services/rust_ffi.dart` loads `nexora_core.dll` (Windows) / `libnexora_core.so` (Linux) from `exeDir`, then `rust/target/{release,debug}`. Keep these names in sync with Rust `name = "nexora_core"` + `crate-type = ["cdylib", ...]`.
- Rust FFI exposes metadata helpers (`nexora_ffi_duration_ms`, `artist`, `album`, `title`, `artwork_base64`) plus an audio engine (`load_path`/`play`/...) that Dart does **not** use for playback — playback goes through `media_kit`. Don't "fix" playback by routing through Rust.
- `media_kit` needs `libmpv-2.dll` (Windows) / `libmpv2` (Linux `.deb` dep) in the bundle.

## Structure

- `lib/main.dart` — entrypoint; sets window options, `MediaKit.ensureInitialized()`, `AudioService.instance.initialize()`, hardcodes `UpdateService` current version `'26.10.27'`.
- `lib/services/` — `AudioService` (media_kit), `RustFfi`, `YouTubeService`, `MusicWatcher`, `UpdateService`.
- `lib/providers/` — `PlayerProvider`, `LibraryProvider`, `PlaylistProvider`, `SearchProvider`, `ProfileProvider`.
- `lib/ui/` — screens, widgets, theme, layouts; desktop shell consumes `nexora_ui_kit`.
- `rust/crates/nexora_core/src/{api,ffi,audio,library,metadata,...}` — Rust core.
- `rust_builder/` — Flutter plugin glue (platform plugin class `none`); do not hand-edit.
- `windows/`, `linux/`, `android/` — platform projects; `*/flutter/generated_plugins.cmake` and registrants are generated — do not hand-edit.

## Release / versioning gotchas

- Bump version in **three** places: `pubspec.yaml`, `rust/crates/nexora_core/Cargo.toml`, and the hardcoded `'26.10.27'` in `lib/main.dart` (`UpdateService`). `scripts/package.sh` also has its own `BASE_VERSION` (`26.10.28`).
- README release flow: build via `scripts/package.sh`, tag `vX.Y.Z`, attach artifacts. Harmony checks GitHub releases (`Nexora-Labs-Co/Harmony`) at startup for auto-update.
- `permission_handler` was removed (unused; its Windows plugin needed NuGet/CppWinRT). Don't re-add.

## Windows gotchas

- No NuGet in Windows build (see above).
- After `flutter build windows --release`, copy `rust/target/release/nexora_core.dll` into `build/windows/x64/runner/Release/` (package script does this).
- Native asset dir is `build/windows/x64/runner/Release/`; app resolves the DLL relative to the executable.