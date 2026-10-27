<p align="center">
  <a href="https://nexora.dev">
    <img src="assets/Harmony-Github.svg" alt="Harmony Preview" style="border-radius: 20px;" width="100%" />
  </a>
</p>

<p align="center">
  <h1 align="center">Harmony</h1>
  <p align="center"><strong>Reproductor de música multiplataforma con Flutter + Dart + Rust</strong></p>
  <p align="center">Ligero, modular y eficiente. Arquitectura limpia con núcleo en Rust y UI en Flutter para máxima portabilidad entre Linux, Windows y Android.</p>
</p>

<p align="center">
  <img alt="PolyForm Noncommercial 1.0.0" src="https://img.shields.io/badge/License-PolyForm--Noncommercial--1.0.0-blue?style=flat-square" />
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter" />
  <img alt="Rust" src="https://img.shields.io/badge/Rust-1.75+-000000?style=flat-square&logo=rust" />
  <img alt="Version" src="https://img.shields.io/badge/Version-26.10.27-22C55E?style=flat-square" />
  <img alt="Platforms" src="https://img.shields.io/badge/Platforms-Linux%20%7C%20Windows%20%7C%20Android-blue?style=flat-square" />
</p>

---

## Tabla de Contenidos

- [Estado del proyecto](#estado-del-proyecto)
- [Acerca de](#acerca-de)
- [Características principales](#características-principales)
- [Tecnologías y Stack](#tecnologías-y-stack)
- [Requisitos previos](#requisitos-previos)
- [Instalación y Configuración](#instalación-y-configuración)
- [Uso](#uso)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Empaquetado](#empaquetado)
- [Hoja de ruta](#hoja-de-ruta)
- [Contribuir](#contribuir)
- [Seguridad](#seguridad)
- [Licencia](#licencia)

---

## Estado del proyecto

> **Estado actual:** Activo / En desarrollo (Beta 26.10.27).

## Acerca de

**Harmony** es un reproductor de música multiplataforma desarrollado por **Harmony Labs Co.** Diseñado con una arquitectura híbrida que separa completamente la lógica de audio (Rust) de la interfaz (Flutter/Dart), permitiendo máxima portabilidad, rendimiento nativo y facilidad de extensión hacia fuentes en la nube (YouTube, WebDAV, Subsonic/Navidrome).

## Características principales

- **Arquitectura híbrida:** UI en Flutter/Dart + Lógica pesada en Rust (audio, metadatos, playlists, favoritos, búsqueda).
- **Audio nativo multiplataforma:** Reproducción real con `media_kit` (mpv) + backend Rust (cpal/rodio/symphonia).
- **Decodificación universal:** Soporte para MP3, FLAC, OGG, WAV, M4A, OPUS, AAC.
- **Metadatos con Lofty:** Extracción de título, artista, álbum, duración y carátula (artwork) desde archivos locales.
- **Biblioteca local:** Escaneo automático de `~/Music` con watcher de sistema de archivos (sin bucles).
- **Favoritos:** Persistencia en SharedPreferences, toggle desde la barra inferior y lista dedicada.
- **Playlists (Álbumes):** Crear, renombrar, eliminar, añadir pistas. Vista en grid.
- **Búsqueda:** Local (título/artista/álbum) + búsqueda global en YouTube.
- **Streaming YouTube:** Búsqueda y reproducción en tiempo real de pistas de YouTube vía `youtube_explode_dart`.
- **Interfaz dual:** Layout desktop (sidebar + topbar + contenido + panel derecho + bottombar) y móvil (navegación inferior).
- **Tema monocromático:** Paleta pura (#090c02 / #ebf5ee + grises neutros), modo claro/oscuro.
- **Empaquetado nativo:** `.deb` (Linux), `.apk` (Android), `.exe` (Windows).

## Tecnologías y Stack

| Componente | Tecnología |
|------------|------------|
| UI | Flutter 3.x + Dart |
| Lógica nativa | Rust (cdylib via FFI) |
| Audio | media_kit (mpv) + rodio/cpal/symphonia |
| Metadatos | lofty (Rust) |
| Base de datos | rusqlite (Rust) |
| Estado | provider (Dart) |
| Persistencia | shared_preferences (Dart) |
| Búsqueda externa | youtube_explode_dart |
| Watcher | package:watcher |

## Requisitos previos

- Flutter SDK 3.x
- Rust toolchain 1.75+
- Linux: `libmpv2`, `libgtk-3-0`
- Android: Android SDK 36, JDK 21
- Windows: Visual Studio (C++ build tools)

## Instalación y Configuración

```bash
# Clonar
git clone https://github.com/Harmony-Labs-Co/Harmony.git
cd Harmony

# Dependencias Flutter
flutter pub get

# Compilar Rust
cd rust && cargo build -p nexora_core && cd ..

# Ejecutar (Linux)
flutter run -d linux
```

## Uso

- La app escanea `~/Music` automáticamente al iniciar.
- Usa la barra de búsqueda para buscar en tu biblioteca o en YouTube.
- Haz clic en una pista para reproducirla.
- Usa los controles de la barra inferior para play/pause, volumen, shuffle y repeat.

## Estructura del proyecto

```
Harmony/
├── lib/                    # Código Flutter/Dart
│   ├── main.dart
│   ├── services/           # AudioService, RustFfi, YouTubeService, MusicWatcher
│   ├── providers/          # Player, Library, Playlist, Search providers
│   ├── ui/                 # Screens, widgets, theme, layouts
│   └── bridge/             # Bridge stubs (flutter_rust_bridge)
├── rust/                   # Núcleo Rust (audio, metadata, library, favorites, playlists, search, ffi)
├── rust_builder/           # Glue para flutter_rust_bridge
├── android/                # Plataforma Android
├── linux/                  # Plataforma Linux
├── windows/                # Plataforma Windows
├── scripts/                # Scripts de empaquetado
├── assets/                 # Iconos e imágenes
├── docs/                   # Documentación adicional
├── pubspec.yaml
└── README.md
```

## Empaquetado

```bash
# Linux (.deb)
./scripts/package.sh linux

# Android (APK)
./scripts/package.sh android

# Windows (.exe)
./scripts/package.sh windows

# Todos
./scripts/package.sh all
```

## Hoja de ruta

- [x] Migración a Flutter + Rust
- [x] Reproductor de audio real (media_kit)
- [x] Metadatos con lofty (duración, carátula, artista)
- [x] Favoritos con persistencia
- [x] Playlists (álbumes)
- [x] Búsqueda local + YouTube
- [x] Layout desktop + móvil
- [ ] Integración WebDAV / Subsonic / Navidrome
- [ ] Letras sincronizadas
- [ ] Soporte macOS / iOS

## Contribuir

Ver [CONTRIBUTING.md](CONTRIBUTING.md).

## Seguridad

Ver [SECURITY.md](SECURITY.md).

## Licencia

PolyForm Noncommercial License 1.0.0 — ver [LICENSE](LICENSE).