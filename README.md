# Nexora Music Player

Reproductor de música multiplataforma desarrollado con **Flutter + Dart + Rust**.

## Stack Tecnológico

- **UI**: Flutter 3.x (Material 3) - Multiplataforma nativo
- **Core/Audio/Library**: Rust (seguro, eficiente)
- **Bindings**: flutter_rust_bridge 2.4.0
- **Audio**: cpal + rodio + symphonia (WASAPI/PipeWire/ALSA/Pulse)
- **Metadata**: lofty
- **Base de datos**: rusqlite

## Arquitectura

```
nexora_app/     -> UI Flutter (Dart)
rust_builder/   -> Glue para flutter_rust_bridge
rust/crates/    -> Core en Rust (audio, library, models)
```

Equivalente funcional a `AudioEngine`, `LocalTrack`, `IAudioBackend` pero implementado en Rust.

## Desarrollo

### Requisitos
- Flutter SDK >= 3.3.0
- Rust >= 1.75
- flutter_rust_bridge_codegen

### Generar bindings
```bash
cd nexora_app
flutter pub get
cargo install flutter_rust_bridge_codegen@2.4.0
flutter_rust_bridge_codegen generate
```

### Ejecutar
```bash
cd nexora_app
flutter run -d linux
# o
flutter run -d windows
```

### Build Linux
```bash
cd nexora_app
flutter build linux --release
```

### Build Windows
```bash
cd nexora_app
flutter build windows --release
```

### Generar .deb
```bash
# Tras flutter build linux
cd packaging/linux
# Usar estructura DEBIAN/ con control + nexora.desktop
dpkg-deb --build nexora_0.1.0_amd64
```

### Generar .exe (Windows)
Usar Inno Setup o NSIS con `build/windows/x64/runner/Release/`

## Licencia

PolyForm Noncommercial License 1.0.0 - Gratuito para uso no comercial.
```