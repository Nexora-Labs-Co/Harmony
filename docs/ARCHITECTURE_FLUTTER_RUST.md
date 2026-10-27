# Arquitectura Nexora - Flutter + Dart + Rust

## Principios
- UI en Flutter/Dart, lógica pesada en Rust
- Bindings seguros con flutter_rust_bridge
- Audio nativo multiplataforma (cpal/rodio/symphonia)
- Escalable para WebDAV/Subsonic/Google Drive
- Preparado para .deb (Linux) y .exe (Windows)

## Capas

### Dart (nexora_app)
- `ui/`: Pantallas, widgets, tema
- `services/`: AudioService (proxy a Rust)
- `providers/`: Estado global
- `models/`: Tipos Dart (generados/reflejados)

### Rust (rust/crates/nexora_core)
- `models/`: Track, LocalTrack, TrackType (equivale a modelos C++)
- `audio/`: AudioEngine, AudioPlayer (equivale a AudioEngine + IAudioBackend + MiniaudioBackend)
- `library/`: Scanner con lofty para metadata
- `api.rs`: Funciones expuestas a Flutter
- `utils/`: Paths, helpers

### Glue
- `rust_builder/`: Integración Flutter + Rust

## Flujo
1. Flutter llama a `AudioService`
2. `AudioService` invoca funciones via `bridge_generated.dart`
3. `flutter_rust_bridge` llama a `nexora_core::api`
4. `AudioEngine` usa `cpal/rodio/symphonia` nativo
```