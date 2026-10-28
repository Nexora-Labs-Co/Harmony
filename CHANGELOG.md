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

## [Sin publicar]

### Añadido

- Migración completa de C++/CMake a Flutter + Dart + Rust
- Motor de audio nativo con `cpal`, `rodio` y `symphonia`
- Soporte para WASAPI (Windows), PipeWire/PulseAudio/ALSA (Linux)
- Escaneo de biblioteca con extracción de metadatos via `lofty`
- Interfaz Flutter con Material 3, tema claro/oscuro
- Bindings Rust-Dart mediante `flutter_rust_bridge` v2.4.0
- Arquitectura modular: UI desacoplada del core Rust
- Preparado para empaquetado `.deb` (Linux) y `.exe` (Windows)
- Soporte para fuentes futuras: WebDAV, Subsonic/Navidrome, Google Drive
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
