<p align="center">
  <h1 align="center">Registro de Cambios</h1>
  <p align="center"><strong>Historial de modificaciones, mejoras y correcciones de Harmony</strong></p>
</p>

---

## Información general

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es/1.1.0/) y este proyecto adhiere a [Versionado Semántico](https://semver.org/lang/es/) (`MAJOR.MINOR.PATCH`).

### Tipos de cambios

- **Añadido:** Nuevas características o funcionalidades
- **Cambiado:** Cambios en funcionalidades existentes
- **Obsoleto:** Características que se eliminarán próximamente
- **Eliminado:** Características eliminadas
- **Corregido:** Corrección de errores
- **Seguridad:** Parches de seguridad

---

## [26.10.28]

### Añadido
- Integración de `NexoraWindowHeader`, `NexoraActionBar` y `NexoraFooterBar` desde NexoraUi-Kit.
- Reproducción de música desde YouTube integrada de forma transparente.
- Vista de Cari AI con reproducción secuencial de voz.
- Pantallas de Notificaciones y Cuenta/Perfil.

### Cambiado
- Rediseño completo de la barra inferior de reproducción (estilo Spotify).
- Rediseño de la pantalla de inicio con secciones horizontales responsivas.
- Barra lateral rediseñada con cuadrícula y álbumes.

---
## [Sin publicar]

### Añadido

- Migración completa de C++/CMake a Flutter + Dart + Rust
- Motor de audio real con `media_kit` (mpv) + backend Rust (rodio/cpal/symphonia)
- Soporte para WASAPI (Windows), PipeWire/PulseAudio/ALSA (Linux)
- Escaneo de biblioteca con extracción de metadatos via `lofty` (duración, artista, álbum, carátula)
- Interfaz Flutter con Material 3, tema monocromático (claro/oscuro)
- Layout dual: desktop (sidebar + topbar + contenido + panel derecho + bottombar) y móvil
- Favoritos con persistencia en SharedPreferences
- Playlists (álbumes) con vista en grid y detalle con tabla de pistas
- Búsqueda local + integración YouTube (youtube_explode_dart) con streaming en tiempo real
- Watcher de sistema de archivos para recarga automática de biblioteca
- Auto-actualizador usando GitHub Releases (sudo apt install)
- Bindings Rust-Dart mediante FFI (dart:ffi) + flutter_rust_bridge (stubs)
- Arquitectura modular: UI desacoplada del core Rust
- Empaquetado multiplataforma: `.deb` (Linux), `.apk` (Android), `.exe` (Windows)
- Icono oficial Harmony para Android, Linux y Windows
- Documentación adaptada al estándar HarmonyTemplate

### Cambiado

- Reestructuración completa del proyecto
- README, CONTRIBUTING, CHANGELOG y SECURITY adaptados al formato Harmony

### Eliminado

- Código C++ completo (`src/`, `CMakeLists.txt`, `cmake/`)
- Dependencias CMake/CPack
- `third_party/miniaudio.h`

---

## [2026.10.27] - 2026-10-27

### Añadido

- Estructura base del proyecto Harmony
- Licencia PolyForm Noncommercial License 1.0.0
- Documentación inicial

---

[Sin publicar]: https://github.com/Harmony-Company/Harmony/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/Harmony-Company/Harmony/releases/tag/v0.1.0
