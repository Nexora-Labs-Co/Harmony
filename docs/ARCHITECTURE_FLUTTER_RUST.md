# Arquitectura Harmony - Flutter + Dart + Rust

## Principios
- UI en Flutter/Dart, lógica pesada en Rust
- Bindings seguros con FFI (dart:ffi) + flutter_rust_bridge (stubs)
- Audio nativo multiplataforma (media_kit/mpv + rodio/cpal/symphonia)
- Escalable para YouTube, WebDAV, Subsonic/Navidrome, Google Drive
- Preparado para .deb (Linux), .apk (Android) y .exe (Windows)

## Capas

### Dart (lib/)
- `services/`: AudioService (media_kit), RustFfi (lofty), YouTubeService, MusicWatcher
- `providers/`: Estado global (Player, Library, Playlist, Search)
- `ui/`: Pantallas, widgets, tema, layouts
- `bridge/`: Stubs de flutter_rust_bridge

### Rust (rust/crates/nexora_core)
- `models/`: Track, LocalTrack, TrackType (equivale a modelos C++)
- `audio/`: AudioEngine, AudioPlayer (equivale a AudioEngine + IAudioBackend + MiniaudioBackend)
- `library/`: LibraryScanner (lofty para metadatos)
- `favorites/`: FavoritesManager
- `playlist/`: PlaylistManager (álbumes)
- `search/`: SearchEngine
- `ffi/`: Funciones FFI para Dart
- `api/`: API flutter_rust_bridge (stubs)

## Comunicación Dart ↔ Rust
- FFI directo: `dart:ffi` + `DynamicLibrary.open('libnexora_core.so')`
- Funciones: `nexora_ffi_init`, `nexora_ffi_duration_ms`, `nexora_ffi_artist`, `nexora_ffi_album`, `nexora_ffi_title`, `nexora_ffi_artwork_base64`, etc.

## Empaquetado
- Linux: `.deb` via `scripts/package.sh linux`
- Android: `.apk` via `flutter build apk`
- Windows: `.exe` via `flutter build windows`