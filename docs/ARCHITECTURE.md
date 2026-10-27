# Arquitectura de Nexora

## Principios
- Separación clara entre Core (lógica) y UI (presentación)
- Inyección de dependencias
- Extensibilidad para fuentes remotas
- Multiplataforma

## Componentes

### Core
- `audio/AudioEngine`: Orquestador del motor de audio
- `audio/IAudioBackend`: Interfaz para backends de audio
- `audio/backends/MiniaudioBackend`: Implementación con miniaudio
- `models/Track`: Interfaz base para pistas
- `models/LocalTrack`: Implementación para pistas locales

### Backend
Preparado para integraciones con WebDAV, Subsonic/Navidrome, Google Drive

### UI
Capa de presentación desacoplada del core
