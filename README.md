# Harmony

Reproductor de música multiplataforma desarrollado por Nexora Labs Co.

## Características

- Arquitectura modular (Core/UI separados)
- Soporte multiplataforma (Linux, Windows)
- Motor de audio con miniaudio (WASAPI/PulseAudio/ALSA/PipeWire)
- Preparado para fuentes en la nube (WebDAV, Subsonic/Navidrome, Google Drive)
- Licencia PolyForm Noncommercial License 1.0.0

## Compilación

### Linux

```bash
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

### Windows (con MSVC)

```bash
mkdir build && cd build
cmake .. -G "Visual Studio 17 2022" -A x64
cmake --build . --config Release
```

## Empaquetado

### .deb (Linux)

```bash
cd build
cpack -G DEB
```

### .exe (Windows con NSIS)

```bash
cd build
cpack -G NSIS
```

## Arquitectura

Ver [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) para más detalles.
