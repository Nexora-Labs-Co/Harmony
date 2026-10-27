# Arquitectura de Harmony

## Principios
- Separación clara entre Core (Rust) y UI (Flutter/Dart)
- Inyección de dependencias vía `provider`
- Extensibilidad para fuentes remotas (YouTube, WebDAV, Subsonic/Navidrome)
- Multiplataforma (Linux, Windows, Android)

## Componentes

### Core (Rust) — `rust/crates/nexora_core`
- `models/`: Track, LocalTrack, TrackType
- `audio/`: AudioEngine, AudioPlayer (rodio/cpal/symphonia)
- `library/`: LibraryScanner (lofty para metadatos)
- `favorites/`: FavoritesManager
- `playlist/`: PlaylistManager (álbumes)
- `search/`: SearchEngine
- `ffi/`: Funciones FFI para Dart (duración, artista, álbum, título, carátula base64)

### UI (Flutter) — `lib/`
- `services/`: AudioService (media_kit), RustFfi, YouTubeService, MusicWatcher
- `providers/`: PlayerProvider, LibraryProvider, PlaylistProvider, SearchProvider
- `ui/screens/`: MainShell (móvil), DesktopShell (desktop)
- `ui/widgets/`: TrackTile, CachedArtwork, PlayerBar, DesktopBottomBar, etc.
- `ui/theme/`: AppTheme (paleta monocromática)
- `ui/layouts/`: ResponsiveLayout

### Servicios externos
- YouTube: búsqueda y streaming via `youtube_explode_dart`
- Watcher: `package:watcher` para monitoreo de carpeta de música

## Flujo de datos
1. `LibraryProvider` escanea `~/Music` → `AudioService.scanLibrary` → enriquece con FFI (lofty).
2. `MusicWatcher` observa cambios y recarga automáticamente.
3. `PlayerProvider` gestiona la cola, play/pause/seek/volume, shuffle/repeat.
4. `media_kit` (mpv) reproduce audio local y streams de YouTube.
5. `SearchProvider` busca en biblioteca local + YouTube en paralelo.